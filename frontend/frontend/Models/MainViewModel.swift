//
//  MainViewModel.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var showAlert: Bool = false
    @Published var isLoaderVisible: Bool = false
    
    var alertContent: String = ""
    
    func login() {
        Task {
            do {
                _ = try await FirebaseHelper.loginWithGoogle()
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
