//
//  MainViewModel.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import SwiftUI
import TorusUtils
import userop_swift
import Web3Core
import tkey_mpc_swift

class MainViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showAlert: Bool = false
    @Published var isLoaderVisible: Bool = false
    
    var alertContent: String = ""
    var erc4337Helper: ERC4337Helper!
    var attestationHelper: AttestationHelper!
    
    private var singleFactorAuthHelper: SingleFactorAuthHelper!
    private var thresholdKeyHelper: ThresholdKeyHelper!
    private var torusKey: TorusKey!
    private var oAuthSigner: Signer!
    
    func initialize() {
        self.singleFactorAuthHelper = SingleFactorAuthHelper.init()
        self.thresholdKeyHelper = ThresholdKeyHelper()
    }
    
    func login() {
        Task {
            do {
                let authDataResult = try await FirebaseHelper.loginWithGoogle()
                let idToken = try await authDataResult.user.getIDTokenResult(
                    forcingRefresh: true
                )
                
                guard let email = authDataResult.user.email else {
                    throw RuntimeError("No Email attached for Web3Auth verification")
                }
                
                self.torusKey = try await singleFactorAuthHelper.loginWithJWT(
                    verifierId: email, idToken: idToken.token
                )
                
                
                try await thresholdKeyHelper.retriveMPCAccount(
                    torusKey: torusKey,
                    verifierId: email,
                    idToken: idToken.token
                )
                
                self.oAuthSigner = SimpleSigner(privateKey: torusKey.finalKeyData!.privKey!.web3.hexData!)
                
                self.erc4337Helper = ERC4337Helper.init(
                    privateKey: torusKey.finalKeyData!.privKey!.web3.hexData!,
                    ethereumTssAccount: thresholdKeyHelper.ethereumAccount,
                    tssUncompressedPublicKey: thresholdKeyHelper.publicKey,
                    isUsingTssSignature: false,
                    isAccountCreated: true
                )
                
                try await erc4337Helper.initialize()
                
                
                self.attestationHelper = AttestationHelper(schemaId: "0xe", erc4337Helper: erc4337Helper, thresholdKeyHelper: thresholdKeyHelper)
                try await attestationHelper.initialize()
                try await attestationHelper.attestMPCAccount(recipient: await oAuthSigner.getAddress().address)
                try await attestationHelper.claimMPCAccount(signer: oAuthSigner, salt: 12)
    
                toogleIsLoggedIn()
            } catch let error {
                print(error.localizedDescription)
                showAlertDialog(alertContent: error.localizedDescription)
            }
        }
    }
    
    private func showAlertDialog(alertContent: String) {
        self.alertContent = alertContent
        DispatchQueue.main.async {
            self.showAlert.toggle()
        }
    }
    
    private func toogleIsLoaderVisible() {
        DispatchQueue.main.async {
            self.isLoaderVisible.toggle()
        }
    }
    
    private func toogleIsLoggedIn() {
        DispatchQueue.main.async {
            self.isLoggedIn.toggle()
        }
    }
}
