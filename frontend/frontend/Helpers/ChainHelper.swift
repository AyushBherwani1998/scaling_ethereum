//
//  ChainHelper.swift
//  frontend
//
//  Created by Ayush B on 17/04/24.
//

import Foundation
import web3swift
import Web3Core
import Web3SwiftMpcProvider
import BigInt

class ChainHelper {
    private var web3: Web3!
    
    func setUp() async throws {
        let alchemyKey = ProcessInfo.processInfo.environment["alchmeyKey"]!
        let rpcUrl =  URL(string: "https://eth-sepolia.g.alchemy.com/v2/\(alchemyKey)")!
        self.web3 = try await Web3(
            provider: Web3HttpProvider(url: rpcUrl, network: Networks.fromInt(11155111))
        )
    }
    
    func getBalance(address: String) async throws -> Decimal {
        let balance = try await web3.eth.getBalance(for: EthereumAddress(address)!)
        let ether = Decimal.init(string: balance.description)! / pow(10, 18)
        return ether
    }
    
    func getTransactionHistory(address: String) async throws -> [TransactionHistory] {
        let (data, _) = try await URLSession.shared.data(
            from: URL(
                string:"https://api-sepolia.etherscan.io/api?module=account&action=txlistinternal&address=" + address + "&tstartblock=0&endblock=99999999&page=1&offset=10&sort=asc&apikey=YourApiKeyToken"
            )!)
        
        let transactionHistory = try JSONDecoder().decode(
            TransactionHistoryResponse.self, from: data
        )
        
        return transactionHistory.result
    
    }
}





struct TransactionHistoryResponse: Codable {
    let status, message: String
    let result: [TransactionHistory]
}

struct TransactionHistory: Codable {
    let timeStamp: String
    let hash: String
    let from: String
    let value: String
    let contractAddress: String
    let type: TypeEnum
    let isError: String
    let errCode: String
    
    var isSuccessful: Bool {
        return isError == "0"
    }
    
    var isInitTransaction: Bool {
        return type == TypeEnum.create2
    }

    enum CodingKeys: String, CodingKey {
        case timeStamp, hash, from, value, contractAddress, type
        case isError, errCode
    }
}


enum TypeEnum: String, Codable {
    case call = "call"
    case create2 = "create2"
}
