//
//  LoaderView.swift
//  sage-wallet
//
//  Created by Aashish Methani on 20/04/24.
//

import SwiftUI

struct LoaderView: View {
    @State private var isLoading = false
    @Binding var loadingMessage: String
       
       var body: some View {
           VStack {
               if isLoading {
                   ProgressView(loadingMessage)
                       .progressViewStyle(CircularProgressViewStyle())
                       .padding()
               } else {
                   Text(loadingMessage)
                       .onAppear() {
                           isLoading.toggle()
                       }
               }
           }
       }
   }

 

   struct ContentView_Previews: PreviewProvider {
       static var previews: some View {
           ContentView(viewModel: MainViewModel())
       }
   }
