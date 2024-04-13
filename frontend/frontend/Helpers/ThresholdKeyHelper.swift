//
//  ThresholdKeyHelper.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import TorusUtils
import tkey_mpc_swift
import CommonSources
import FetchNodeDetails
import Web3SwiftMpcProvider

class ThresholdKeyHelper {
    var verifier: String!
    var verifierId: String!
    var signatures: [[String: String]]!
    var torusUtils: TorusUtils!
    var nodeDetails: AllNodeDetailsModel!
    var tssEndPoints: Array<String>!
    var thresholdKey: ThresholdKey!
    var totalShares: Int!
    var threshold: Int!
    var requiredShares: Int!
    var keyDetails: KeyDetails!
    var address: String!
    var ethereumAccount: EthereumTssAccount!
    var activeFactor: String!
    var publicKey: String!
    
    func retriveMPCAccount(torusKey: TorusKey, verifierId: String, idToken: String) async throws {
        do {
            guard let postboxkey = torusKey.finalKeyData?.privKey else {
                throw RuntimeError("Not able to retrive private key")
            }
            
            verifier = "scaling-ethereum"
            self.verifierId = verifierId
            
            guard let sessionData = torusKey.sessionData else {
                throw RuntimeError("Failed to retrive session data")
            }
            
            let sessionTokenData = sessionData.sessionTokenData
            
            signatures = sessionTokenData.map { token in
                return [
                    "data": Data.init(hex: token!.token).base64EncodedString(),
                    "sig": token!.signature
                ]
            }
            
            guard let storage_layer = try? StorageLayer(
                enable_logging: true,
                host_url: "https://metadata.tor.us",
                server_time_offset: 2
            ) else {
                throw RuntimeError("Failed to create storage layer")
            }
            
            torusUtils = TorusUtils(
                enableOneKey: true,
                network: .sapphire(.SAPPHIRE_MAINNET),
                clientId: ProcessInfo.processInfo.environment["web3AuthId"]!
            )
            
            let nodeDetailsManager = NodeDetailManager(
                network: TorusNetwork.sapphire(SapphireNetwork.SAPPHIRE_MAINNET)
            )
            
            nodeDetails = try await nodeDetailsManager.getNodeDetails(
                verifier: verifier, verifierID: verifierId
            )
            
            tssEndPoints = nodeDetails!.torusNodeTSSEndpoints
            
            
            guard let service_provider = try? ServiceProvider(
                enable_logging: true,
                postbox_key: postboxkey,
                useTss: true,
                verifier: verifier,
                verifierId: verifierId,
                nodeDetails: nodeDetails
            ) else {
                throw RuntimeError( "Failed to create service provider")
            }
            
            let rss_comm = try RssComm()
            guard let thresholdKeyLocal = try? ThresholdKey(
                storage_layer: storage_layer,
                service_provider: service_provider,
                enable_logging: true,
                manual_sync: false,
                rss_comm: rss_comm
            ) else {
                throw RuntimeError("Failed to create threshold key")
            }
            
            thresholdKey = thresholdKeyLocal
            
            guard let keyDetailsLocal = try? await thresholdKey.initialize(
                never_initialize_new_key: false,
                include_local_metadata_transitions: false
            ) else {
                throw RuntimeError( "Failed to get key details")
            }
            
            keyDetails = keyDetailsLocal
            
            totalShares = Int(keyDetails.total_shares)
            threshold = Int(keyDetails.threshold)
            requiredShares = Int(keyDetails.required_shares)
            
            if(requiredShares > 0) {
                try await existingUser()
            } else {
                try await newUser()
            }
            
            
        } catch let error {
            throw error
        }
    }
    
    private func newUser() async throws {
        do {
            let factorKey = try PrivateKey.generate()
            try await _createDeviceFactor(factorKey: factorKey)
            guard (try? await thresholdKey.reconstruct()) != nil else {
                throw RuntimeError(
                    "Failed to reconstruct key. \(keyDetails.required_shares) more share(s) required."
                )
            }
            
            activeFactor = factorKey.hex
            
            try await prepareEthTssAccout(factorKey: factorKey.hex)
        } catch let error {
            throw error
        }
    }
    
    private func existingUser() async throws {
        do {
          
            let metadataPublicKey = try keyDetails.pub_key.getPublicKey(
                format: .EllipticCompress
            )
            
            guard let factorPub = UserDefaults.standard.string(
                forKey: metadataPublicKey
            ) else {
               
                throw RuntimeError("Failed to find device share.")
            }
            
            var factorKey: String!
            
            factorKey = try KeychainInterface.fetch(key: factorPub)
            try await thresholdKey.input_factor_key(factorKey: factorKey)
            
            let pk = PrivateKey(hex: factorKey)
            activeFactor = factorKey
            
            
            
            guard let reconstructionDetails = try? await thresholdKey.reconstruct() else {
                throw RuntimeError(
                    "Failed to reconstruct key with available shares."
                )
            }
            
            try await prepareEthTssAccout(
                factorKey: factorKey
            )
            
        } catch let error {
            throw error
        }
    }
    
    private func _createDeviceFactor(factorKey: PrivateKey) async throws {
        do {
            let factorPub = try factorKey.toPublic()
            
            let tssIndex = Int32(2)
            let defaultTag = "default"
            
            try await TssModule.create_tagged_tss_share(
                threshold_key: thresholdKey,
                tss_tag: defaultTag,
                deviceTssShare: nil,
                factorPub: factorPub,
                deviceTssIndex: tssIndex,
                nodeDetails: self.nodeDetails!,
                torusUtils: self.torusUtils!
            )
            
            
            _ = try await TssModule.get_tss_pub_key(
                threshold_key: thresholdKey, tss_tag: defaultTag
            )
            
            var shareIndexes = try thresholdKey.get_shares_indexes()
            shareIndexes.removeAll(where: {$0 == "1"})
            
            try TssModule.backup_share_with_factor_key(
                threshold_key: thresholdKey,
                shareIndex: shareIndexes[0],
                factorKey: factorKey.hex
            )
            
            let description = [
                "module": "Device Factor key",
                "tssTag": defaultTag,
                "tssShareIndex": tssIndex,
                "dateAdded": Date().timeIntervalSince1970
            ] as [String: Codable]
            
            let jsonStr = try factorDescription(dataObj: description)
            
            try await thresholdKey.add_share_description(
                key: factorPub,
                description: jsonStr
            )
            
            let metadataPublicKey = try keyDetails.pub_key.getPublicKey(
                format: .EllipticCompress
            )
            
            
            UserDefaults.standard.set(factorPub, forKey: metadataPublicKey)
            
            guard let _ = try? KeychainInterface.save(
                item: factorKey.hex,
                key: factorPub
            ) else {
                throw RuntimeError("Failed to save factor key")
            }
        } catch let error {
            throw error
        }
    }
    
    private func retrieveDeviceFactor() throws {
        
    }
    
    private func factorDescription ( dataObj: [String: Codable] ) throws -> String {
        let json = try JSONSerialization.data(withJSONObject: dataObj)
        guard let jsonStr = String(data: json, encoding: .utf8) else {
            throw RuntimeError("Invalid data structure")
        }
        return jsonStr
    }
    
    private func prepareEthTssAccout(
        factorKey: String
    ) async throws {
        let tag = try TssModule.get_tss_tag(threshold_key: thresholdKey)
        let tssPublicKey = try await  TssModule.get_tss_pub_key(
            threshold_key: thresholdKey, tss_tag: tag
        )
        
        let keyPoint = try KeyPoint(address: tssPublicKey)
        
        let nonce = try TssModule.get_tss_nonce(
            threshold_key: thresholdKey, tss_tag: tag
        )
        
        
        let (tssIndex, tssShare) = try await TssModule.get_tss_share(
            threshold_key: thresholdKey,
            tss_tag: tag,
            factorKey: factorKey
        )
        
        let tssPublicAddressInfo = try await TssModule.get_dkg_pub_key(
            threshold_key: thresholdKey,
            tssTag: tag,
            nonce: nonce.description,
            nodeDetails: nodeDetails!,
            torusUtils: torusUtils!
        )
        
        
        let sigs: [String] = try signatures.map { String(
            decoding: try JSONSerialization.data(
                withJSONObject: $0
            ), as: UTF8.self)
        }
        
        self.publicKey = try keyPoint.getPublicKey(format: .FullAddress)
        
        let ethTssAccountParams = EthTssAccountParams(
            publicKey: publicKey,
            factorKey: factorKey,
            tssNonce: nonce,
            tssShare: tssShare,
            tssIndex: tssIndex,
            selectedTag: tag,
            verifier: verifier,
            verifierID: verifierId,
            nodeIndexes: tssPublicAddressInfo.nodeIndexes,
            tssEndpoints: tssEndPoints,
            authSigs: sigs
        )
        
        ethereumAccount = EthereumTssAccount(
            params: ethTssAccountParams
        )
        
        address = ethereumAccount.address.asString()
        print("MPC Public Address: \(String(describing: address))")
    }
}
