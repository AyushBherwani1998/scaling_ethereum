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

        let signature = try EthereumAccount(
            keyStorage: key as EthereumSingleKeyStorageProtocol
        ).signMessage(message: data)
        
        return signature.web3.hexData!
    }
}