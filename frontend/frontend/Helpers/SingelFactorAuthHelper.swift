//
//  SingelFactorAuthHelper.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation
import SingleFactorAuth
import TorusUtils

class SingleFactorAuthHelper {
    private var singleFactorAuth: SingleFactorAuth!
    
    init() {
        let singleFactorAuthArgs = SingleFactorAuthArgs(
            web3AuthClientId: ProcessInfo.processInfo.environment["web3AuthId"]!,
            network: .SAPPHIRE_MAINNET
        )
        
        self.singleFactorAuth = SingleFactorAuth(
            singleFactorAuthArgs: singleFactorAuthArgs
        )
    }
    
    func loginWithJWT(verifierId: String, idToken: String) async throws -> TorusKey {
        return try await  singleFactorAuth.getTorusKey(loginParams: LoginParams(
            verifier: "scaling-ethereum",
            verifierId: verifierId,
            idToken: idToken
        ))
    }
}
