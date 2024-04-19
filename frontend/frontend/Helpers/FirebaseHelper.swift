//
//  FirebaseHelper.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct FirebaseHelper {
    static func loginWithGoogle() async throws -> AuthDataResult {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw RuntimeError("Couldn't locate Google clientId")
            }
            
            
            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration
            
            
            guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                throw RuntimeError("Couldn't locate a Scene")
            }
            
            
            let googleResult = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: windowScene.keyWindow!.rootViewController!
            )
            
            let authDataResult = try await authenticateFirebaseUser(for: googleResult)
            return authDataResult
        } catch let error {
            print(error.localizedDescription)
            throw error
        }
    }
    
    static private func authenticateFirebaseUser(for user: GIDSignInResult?) async throws -> AuthDataResult {
        
        guard let idToken = user?.user.idToken else {
            throw RuntimeError("idToken not available")
        }
        
        guard let accessToken = user?.user.accessToken else {
            throw RuntimeError("accessToken not available")
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        return try await Auth.auth().signIn(with: credential)
    }
}
