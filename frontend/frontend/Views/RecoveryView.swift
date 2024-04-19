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
                
                VStack(alignment: .leading){
                    Text("Enter your attestation code")
                        .font(.title2)
                    HStack{
                        TextField("0000", text: $attestation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .font(.system(size: 56))
                            .padding(.trailing,12)
                        
                        
                    }
                    Spacer()
                    
                    Button {
                        viewModel.claimAccount(salt: attestation)
                    } label: {
                        Text("Claim attestation")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                            .padding(2)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding(.top, 16)
                .padding(.bottom,56)
                .padding(.leading)
                .padding(.trailing)
          
            }
    
            }
        }
        
    }
}
