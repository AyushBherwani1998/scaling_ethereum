//
//  Extension.swift
//  frontend
//
//  Created by Ayush B on 13/04/24.
//

import Foundation
import web3


extension String: EthereumSingleKeyStorageProtocol {
    public func storePrivateKey(key: Data) throws {
        
    }
    
    public func loadPrivateKey() throws -> Data {
        guard let privKeyData = Data.init(hex: self) else {
            // Todo make custom error
            return Data()
        }
        return privKeyData
        
    }
}

extension String {
    public static func sign(data: Data, key: String) throws -> Data {
        let account = try EthereumAccount(
            keyStorage: key as EthereumSingleKeyStorageProtocol
        )
        
        
        
        let signature = try account.signMessage(message: data)
        
        return signature.web3.hexData!
    }
    
    public static func addressAbbreivation(address: String) -> String {
        let result = address.split(separator: "")
        let suffixAddress=result[38]+result[39]+result[40]+result[41]
        let prefixAddress=result[0]+result[1]+result[2]+result[3]
        return prefixAddress + "..." + suffixAddress
    }
}
