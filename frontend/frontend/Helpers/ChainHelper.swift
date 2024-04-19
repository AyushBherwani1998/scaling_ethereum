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
}
