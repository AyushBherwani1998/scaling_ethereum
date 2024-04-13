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

class AttestationHelper {
    let schemaId: String
    var ispContract: EthereumContract!
    var erc4337Helper: ERC4337Helper
    
    init(schemaId: String, erc4337Helper: ERC4337Helper) {
        self.schemaId = schemaId
        self.erc4337Helper = erc4337Helper
    }
    
    func initialize() async throws {
        self.ispContract = try EthereumContract(ABI.ISPABI)
    }
   
    
    func attestMPCAccount(recipient: String, mpcAddress: String, attester: String) async throws -> String {
        let schemaData = try ABIEncoder.abiEncode([EthereumAddress(Data(hex: mpcAddress))!])
        
        guard let data = ispContract.method(
            "attest((uint64,uint64,uint64,uint64,address,uint64,uint8,bool,bytes[],bytes),string,bytes,bytes)",
            parameters: [
                [
                    UInt("14")!,
                    UInt.zero,
                    UInt.zero,
                    UInt.zero,
                    EthereumAddress(Data(hex: attester))!,
                    UInt.zero,
                    UInt.zero,
                    false,
                    [EthereumAddress(Data(hex: recipient))!],
                    schemaData.bytes
                ],
                EthereumAddress(Data(hex: attester))!.address,
                "0x".web3.hexData!.bytes,
                "0x".web3.hexData!.bytes,
            ],
            extraData: nil
        ) else {
            throw "Failed to encode data"
        }
        
        return try await erc4337Helper.writeSmartContract(
            to: "0x878c92FD89d8E0B93Dc0a3c907A2adc7577e39c5", data
        )
    }
}
