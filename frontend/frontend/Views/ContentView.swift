//
//  ContentView.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            if(viewModel.isLoggedIn) {
                HomeView()
            } else {
                LoginView(viewModel: viewModel)
            }
        }.onAppear {
            viewModel.initialize()
        }
    }
}

