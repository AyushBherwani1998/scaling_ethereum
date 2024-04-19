//
//  AttestationHelper.swift
//  frontend
//
//  Created by Ayush B on 13/04/24.
//

import Foundation
import Web3Core
import BigInt
import TorusUtils
import userop_swift
import web3swift

class AttestationHelper {
    let schemaId: String
    var ispContract: EthereumContract!
    var erc4337Helper: ERC4337Helper?
    var thresholdKeyHelper: ThresholdKeyHelper
    
    init(schemaId: String, erc4337Helper: ERC4337Helper?, thresholdKeyHelper: ThresholdKeyHelper) {
        self.schemaId = schemaId
        self.erc4337Helper = erc4337Helper
        self.thresholdKeyHelper = thresholdKeyHelper
    }
    
    func initialize() async throws {
        self.ispContract = try EthereumContract(ABI.MPCRECOVERYABI)
    }
    
    
    func attestMPCAccount(recipient: String) async throws -> String {
        let schemaData = try ABIEncoder.abiEncode([12])
        
        guard let data = ispContract.method(
            "attestMPCAccount",
            parameters: [
                EthereumAddress(Data(hex: recipient))!,
                schemaData
            ],
            extraData: nil
        ) else {
            throw "Failed to encode data"
        }
        
        
        guard let hash = try await erc4337Helper?.writeSmartContract(
            to: "0xa448B7Cefcff60B835126306858F65C14a3a691D",
            data
        ) else {
            throw "ERC4337 Account not found"
        }
        
        try await thresholdKeyHelper.createAttestationFactor(salt: 12)
        return hash
    }
    
    func claimMPCAccount(signer: Signer, salt: UInt) async throws {
        
        let data = try ABIEncoder.abiEncode([0xdead.web3.hexString.sha3(.keccak256)]).sha3(.keccak256)
        let signature = try await signer.signMessage(data)
        
        let alchemyKey = ProcessInfo.processInfo.environment["alchmeyKey"]!
        let rpcUrl =  URL(string: "https://eth-sepolia.g.alchemy.com/v2/\(alchemyKey)")!
        let web3 = try await Web3(provider: Web3HttpProvider(url: rpcUrl, network: Networks.fromInt(11155111)))
        
        let contract = web3.contract(
            ABI.MPCRECOVERYABI,
            at: EthereumAddress(Data(hex: "0xa448B7Cefcff60B835126306858F65C14a3a691D"))
        )!
        
        let addressData = await signer.getAddress().addressData
        let address = EthereumAddress(addressData)!
        
        let mpcRecovery = contract.createReadOperation(
            "claimMPCAccount",
            parameters: [
                data,
                signature,
                address
            ],
            extraData: Data()
        )
        
        mpcRecovery!.transaction.from = address
        
        
        let result = try await mpcRecovery?.callContractMethod()
        guard let attestationObject = result?.first?.value else {
            throw "Attestation not found"
        }
        
        guard let data = (attestationObject as! [Any]).last else {
            throw "Invalid Data"
        }
        
        
        
        let factorKeySalt = ABIDecoder.decodeSingleType(type: .uint(bits: 256), data: data as! Data)
        
        if (factorKeySalt.value as! BigUInt).description == salt.description {
            try await thresholdKeyHelper.recoverWithAttestation(salt: salt)
        } else {
            throw "Not a valid claim"
        }
    }
}
