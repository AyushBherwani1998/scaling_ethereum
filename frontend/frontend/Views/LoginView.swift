//
//  LoginView.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        VStack{
            Spacer()
            Image("sage-logo")
            Spacer()
            
            
            Button {
                viewModel.login() 
            } label: {
                Text("Login with Google")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .padding(2)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
        }
        .padding()
    }
}

