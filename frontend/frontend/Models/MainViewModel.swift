//
//  MainViewModel.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import SwiftUI
import TorusUtils

class MainViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showAlert: Bool = false
    @Published var isLoaderVisible: Bool = false
    
    var alertContent: String = ""
    private var singleFactorAuthHelper: SingleFactorAuthHelper!
    private var torusKey: TorusKey!
    
    func initialize() {
        self.singleFactorAuthHelper = SingleFactorAuthHelper.init()
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
