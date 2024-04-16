//
//  PassKeyView.swift
//  frontend
//
//  Created by Aashish Methani on 16/04/24.
//

import SwiftUI
import LocalAuthentication



struct PassKeyView: View {
    @Binding var isUnlocked: Bool
    
    var body: some View {
        VStack {
            Spacer();
            if isUnlocked{
            
            }
            else{
                VStack{
                    Image(systemName: "faceid")
                        .font(.system(size: 48))
                        .padding(.bottom,24)
                    
                    Text("Setup FaceID for secure and easy access to your wallet")
                        .multilineTextAlignment(.center)
                    
                }
                
            }
            Spacer();
            Button {
                authenticate()
            } label: {
                Text("Create Passkey factor")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .padding(2)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        
    }
    
       
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Set up your passkeys for easier key management"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    isUnlocked = true
                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }
}
