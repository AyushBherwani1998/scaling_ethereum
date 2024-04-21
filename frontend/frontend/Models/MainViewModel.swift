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
    @Published var loaderText: String = ""
    @Published var showAlert: Bool = false
    @Published var isLoaderVisible: Bool = false
    @Published var isAccountReady: Bool = false
    @Published var isRecoveryRequired: Bool = false
    
    var alertContent: String = ""
    var balance: Decimal = 0
    var transactions: [TransactionHistory]!
    
    var erc4337Helper: ERC4337Helper!
    var attestationHelper: AttestationHelper!
    
    private var singleFactorAuthHelper: SingleFactorAuthHelper!
    private var thresholdKeyHelper: ThresholdKeyHelper!
    private var torusKey: TorusKey!
    private var oAuthSigner: Signer!
    private var chainHelper: ChainHelper!
    private var curveGridHelper: CurveGridHelper!
    
    func initialize() {
        self.singleFactorAuthHelper = SingleFactorAuthHelper.init()
        self.thresholdKeyHelper = ThresholdKeyHelper()
        self.chainHelper = ChainHelper()
        self.curveGridHelper = CurveGridHelper()
    }
    
    func login() {
        Task {
            do {
                toogleIsLoaderVisible()
                setLoaderText(text: "Login in with Google")
                let authDataResult = try await FirebaseHelper.loginWithGoogle()
                let idToken = try await authDataResult.user.getIDTokenResult(
                    forcingRefresh: true
                )
                
                guard let email = authDataResult.user.email else {
                    throw RuntimeError("No Email attached for Web3Auth verification")
                }
                setLoaderText(text: "Verifying the OAuth token")
                self.torusKey = try await singleFactorAuthHelper.loginWithJWT(
                    verifierId: email, idToken: idToken.token
                )
                
                self.oAuthSigner = SimpleSigner(privateKey: torusKey.finalKeyData!.privKey!.web3.hexData!)
                
                
                do {
                    setLoaderText(text: "Retrieving the MPC Account")
                    try await thresholdKeyHelper.retriveMPCAccount(
                        torusKey: torusKey,
                        verifierId: email,
                        idToken: idToken.token
                    )
                    
                    try await processLogin()
                    if thresholdKeyHelper.isNewUser {
                        setLoaderText(text: "Transfering 0.001 ETH from paymaster")
                        let isSuccess = try await curveGridHelper.payFees(address: erc4337Helper.address)
                        
                    }
                    toogleIsLoaderVisible()
                } catch {
                    toogleIsLoaderVisible()
                    DispatchQueue.main.async {
                        self.isRecoveryRequired = self.thresholdKeyHelper.requiredShares > 0
                    }
                }
                
            } catch let error {
                toogleIsLoaderVisible()
                print(error.localizedDescription)
                showAlertDialog(alertContent: error.localizedDescription)
            }
        }
    }
    
    private func processLogin() async throws {
        self.erc4337Helper = ERC4337Helper.init(
            privateKey: torusKey.finalKeyData!.privKey!.web3.hexData!,
            ethereumTssAccount: thresholdKeyHelper.ethereumAccount,
            tssUncompressedPublicKey: thresholdKeyHelper.publicKey,
            isUsingTssSignature: true,
            isAccountCreated: false
        )
        
        
        try await erc4337Helper.initialize()
        
        self.attestationHelper = AttestationHelper(schemaId: "0xe", erc4337Helper: erc4337Helper, thresholdKeyHelper: thresholdKeyHelper)
        try await attestationHelper.initialize()
        try await chainHelper.setUp()
        
        toogleIsLoggedIn()
        loadAccount()
    }
    
    func loadGasPrice(onSuccess: @escaping (String) -> ()) {
        Task {
            do {
                let gas = try await chainHelper.getGasPrice()
                onSuccess(gas)
            } catch let error {
                print(error.localizedDescription)
                showAlertDialog(alertContent: error.localizedDescription)
            }
            
        }
    }
    
    func sendTransaction(address: String, value: String,onSend: @escaping (String?, String?) -> ()) {
        Task {
            do {
                toogleIsLoaderVisible()
                setLoaderText(text: "Transfering \(value) to \(String.addressAbbreivation(address: address))")
                let hash = try await erc4337Helper.transferEth(
                    to: address,
                    value: value
                )
                toogleIsLoaderVisible()
                onSend(hash, nil)
                
            } catch let error {
                toogleIsLoaderVisible()
                print(error.localizedDescription)
                onSend(nil, error.localizedDescription)
            }
        }
    }
    
    func createMPCAttestationFactor(attestationId: @escaping (String, String) -> ()) {
        Task {
            do {
                toogleIsLoaderVisible()
                setLoaderText(text: "Creating attestation Factor Key for MPC Account")
                let recipient = await oAuthSigner.getAddress().address
                let (hash, salt) = try await attestationHelper.attestMPCAccount(
                    recipient: recipient
                )
                toogleIsLoaderVisible()
                attestationId(salt.description, hash)
            } catch let error {
                toogleIsLoaderVisible()
                print(error.localizedDescription)
                showAlertDialog(alertContent: error.localizedDescription)
            }
            
        }
    }
    
    func claimAccount(salt: String) {
        Task {
            do {
                toogleIsLoaderVisible()
                setLoaderText(text: "Claiming MPC Account using attestation")
                guard let saltInt: UInt = UInt(salt) else {
                    throw "Invalid salt"
                }
                
                self.attestationHelper = AttestationHelper(
                    schemaId: "0xe",
                    erc4337Helper: nil,
                    thresholdKeyHelper: thresholdKeyHelper
                )
                
                try await attestationHelper.initialize()
                
                try await attestationHelper.claimMPCAccount(signer: oAuthSigner, salt: saltInt)
                try await processLogin()
                toogleIsLoaderVisible()
            } catch let error {
                toogleIsLoaderVisible()
                print(error.localizedDescription)
                showAlertDialog(alertContent: error.localizedDescription)
            }
        }
    }
    
    func unique<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
    func loadAccount() {
        Task {
            do {
                setLoaderText(text: "Preparing Account")
                let balance = try await chainHelper.getBalance(address: erc4337Helper.address)
                let tranasctions = try await chainHelper.getTransactionHistory(
                    address: erc4337Helper.address
                )
                
            
                
                
                DispatchQueue.main.async {
                    self.balance = balance
                    self.transactions = Array(Set(tranasctions))
                    self.isAccountReady.toggle()
                    self.isRecoveryRequired = self.thresholdKeyHelper.requiredShares > 0
                }
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
    
    private func setLoaderText(text: String) {
        DispatchQueue.main.async {
            self.loaderText = text
        }
    }
    
    private func toogleIsLoggedIn() {
        DispatchQueue.main.async {
            self.isLoggedIn.toggle()
        }
    }
}
