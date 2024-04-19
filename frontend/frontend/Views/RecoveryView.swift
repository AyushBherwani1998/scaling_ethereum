//
//  RecoveryView.swift
//  frontend
//
//  Created by Ayush B on 19/04/24.
//

import SwiftUI

struct RecoveryView: View {
    @StateObject var viewModel: MainViewModel
    @State var attestation: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(
                    header: Text("MPC Account Recovery")
                ) {
                    TextField(
                        "Please enter your attestation number",
                        text: $attestation
                    )
                    
                    Button(
                        action: {
                            viewModel.claimAccount(salt: attestation)
                        }, label: {
                            Text("Claim Account")
                        }
                    )
                }
            }
        }
        
    }
}
