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
    var erc4337Helper: ERC4337Helper
    
    init(schemaId: String, erc4337Helper: ERC4337Helper) {
        self.schemaId = schemaId
        self.erc4337Helper = erc4337Helper
    }
    
    func initialize() async throws {
        self.ispContract = try EthereumContract(ABI.MPCRECOVERYABI)
    }
    
    
    func attestMPCAccount(recipient: String, mpcAddress: String) async throws -> String {
        let schemaData = try ABIEncoder.abiEncode([EthereumAddress(Data(hex: mpcAddress))!])
        
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
        
        
        return try await erc4337Helper.writeSmartContract(
            to: "0x3eb98dc9c9ae546f80a692af3885c259cce633ac",
            data
        )
    }
    
    func claimMPCAccount(signer: Signer) async throws -> Bool {
        
        let data = try ABIEncoder.abiEncode([0xdead.web3.hexString.sha3(.keccak256)]).sha3(.keccak256)
        let signature = try await signer.signMessage(data)
        
        let alchemyKey = ProcessInfo.processInfo.environment["alchmeyKey"]!
        let rpcUrl =  URL(string: "https://eth-sepolia.g.alchemy.com/v2/\(alchemyKey)")!
        let web3 = try await Web3(provider: Web3HttpProvider(url: rpcUrl, network: Networks.fromInt(11155111)))
        
        let contract = web3.contract(
            ABI.MPCRECOVERYABI,
            at: EthereumAddress(Data(hex: "0x1B1c81155ae76c3e775403C787EA492FC5853ed6"))
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
        guard let isClaimable = result?.first?.value else {
            throw "Attestation not found"
        }
        
        return isClaimable as! Bool
    }
}
