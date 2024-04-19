//
//  MPCSigner.swift
//  frontend
//
//  Created by Ayush B on 11/04/24.
//

import Foundation
import userop_swift
import Web3Core
import Web3SwiftMpcProvider

struct MPCSigner: Signer {
    private let privateKey: EthereumTssAccount
    private let publicKey: String

    init(privateKey: EthereumTssAccount, publicKey: String) {
        self.privateKey = privateKey
        self.publicKey = publicKey
    }

    func getAddress() async -> EthereumAddress {
        return EthereumAddress(privateKey.address.asData()!)!
    }

    func getPublicKey() async throws -> Data {
        return Data(hex: publicKey)
    }

    func signMessage(_ data: Data) async throws -> Data {
        let result = try privateKey.signMessage(message: data)
        return result.web3.hexData!
    }
}

struct SimpleSigner: Signer {
    private let privateKey: Data

    init(privateKey: Data) {
        self.privateKey = privateKey
    }

    func getAddress() async -> EthereumAddress {
        try! await Utilities.publicToAddress(getPublicKey())!
    }

    func getPublicKey() async throws -> Data {
        Utilities.privateToPublic(privateKey)!
    }

    func signMessage(_ data: Data) async throws -> Data {
        let compressedSignature = try String.sign(data: data, key: privateKey.hexString)
        return compressedSignature
    }
}
