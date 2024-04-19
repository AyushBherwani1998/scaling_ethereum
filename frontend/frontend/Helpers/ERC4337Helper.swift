//
//  ERC4337Helper.swift
//  frontend
//
//  Created by Ayush B on 13/04/24.
//

import Foundation
import userop_swift
import Web3SwiftMpcProvider
import Web3Core
import BigInt
import web3swift

class ERC4337Helper {
    var account: SimpleAccountBuilder!
    var privateKey: Data
    var ethereumTssAccount: EthereumTssAccount
    var tssUncompressedPublicKey: String
    var isUsingTssSignature: Bool
    var isAccountCreated: Bool
    
    var address: String!
    
    private var client: Client!
    
    init(privateKey: Data, ethereumTssAccount: EthereumTssAccount, tssUncompressedPublicKey: String, isUsingTssSignature: Bool, isAccountCreated: Bool) {
        self.privateKey = privateKey
        self.ethereumTssAccount = ethereumTssAccount
        self.tssUncompressedPublicKey = tssUncompressedPublicKey
        self.isUsingTssSignature = isUsingTssSignature
        self.isAccountCreated = isAccountCreated
    }
    
    
    func initialize() async throws {
        var signer: Signer!
        
        if(isUsingTssSignature) {
            signer = MPCSigner(privateKey: ethereumTssAccount, publicKey: tssUncompressedPublicKey)
        } else {
            signer = SimpleSigner(privateKey: privateKey)
        }
        
        let alchemyKey = ProcessInfo.processInfo.environment["alchmeyKey"]!
        let rpcUrl =  URL(string: "https://eth-sepolia.g.alchemy.com/v2/\(alchemyKey)")!
        let bundlerRpc = URL(string: "https://public.stackup.sh/api/v1/node/ethereum-sepolia")!
        let entryPoint = EthereumAddress(Data(hex: "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"))!
        
        self.client = try await Client(
            rpcUrl: rpcUrl,
            chainId: 11155111,
            overrideBundlerRpc: bundlerRpc,
            entryPoint: entryPoint
        )
        
        self.account = try await SimpleAccountBuilder(
            signer: signer,
            rpcUrl: rpcUrl,
            chainId: 11155111,
            bundleRpcUrl: bundlerRpc,
            entryPoint: entryPoint,
            factory: EthereumAddress(Data(hex: "0x9406cc6185a346906296840746125a0e44976454"))!
        )
        
        self.address = account.sender.address
        
        if(isAccountCreated) {
            self.account.sender = EthereumAddress(Data(hex: address))!
        }
    }
    
    func createAccount() async throws -> String {
      return try await sendUserOP()
    }
    
    
    
    func transferEth(to: String, value: String) async throws -> String {
        let valueInWei = try TorusWeb3Utils.toWei(ether: value)
        try await account.execute(
            to: EthereumAddress(Data(hex: to))!,
            value: BigUInt.init(stringLiteral: valueInWei.description),
            data: Data()
        )
        
        return try await sendUserOP()
    }
    
    func writeSmartContract(to: String, _ data: Data, value: String = "0") async throws -> String {
        let valueInWei = try TorusWeb3Utils.toWei(ether: value)
        try await account.execute(
            to: EthereumAddress(Data(hex: to))!,
            value: BigUInt.init(stringLiteral: valueInWei.description),
            data: data
        )
        
        return try await sendUserOP()
    }
    
     private func sendUserOP() async throws -> String {
        let response = try await client.sendUserOperation(builder: account)
        let eventLog = try await response.wait()
        return eventLog!.transactionHash.hexString
    }
}
