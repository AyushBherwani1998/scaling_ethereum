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
    
   public static func hexadecimalToDecimal(_ hex: String) -> String {
        let hexDigits: [Character: Int] = ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15]
        var decimalValue = 0
        
        let hexString = hex.uppercased()

        for char in hexString.dropFirst(2) {
            guard let digitValue = hexDigits[char] else {

                return "0.00"
            }
            decimalValue = decimalValue * 16 + digitValue
        }
        
        return String(decimalValue)
    }
}
