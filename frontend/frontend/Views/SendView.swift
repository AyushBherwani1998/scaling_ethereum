//
//  SendView.swift
//  sage-wallet
//
//  Created by Aashish Methani on 19/04/24.
//

import SwiftUI
import UIKit
import SimpleToast


private let toastOptions = SimpleToastOptions(
    alignment: .top,
    hideAfter: 3,
    backdrop: Color.black.opacity(0.3),
    animation: .default,
    modifierType: .slide
    
)

struct SendView: View {
    @StateObject var viewModel: MainViewModel
    @State var senderAddress = ""
    @State var value = ""
    @State var gasPrice = "0.00"
    @State private var showToast = false
    @State private var txnState = true
    @State var hash: String = ""
    
    var body: some View {
        if viewModel.isLoaderVisible {
            LoaderView(loadingMessage: $viewModel.loaderText)
        } else {
            VStack{
                
                VStack(alignment: .leading){
                    Text("Send to").font(.title2)
                    HStack{
                        TextField("Enter address", text: $senderAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                            .padding(.trailing, 12)
                        
                        Button("Paste"){
                            if let pastedText = UIPasteboard.general.string {
                                senderAddress = pastedText
                            }
                        }
                    }
                }.padding(.top, 16).padding(.bottom,48)
                
                
                VStack(alignment: .leading){
                    Text("Amt in ETH").font(.title2)
                    HStack{
                        TextField("0.00", text: $value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .font(.system(size: 44))
                            .padding(.trailing,12)
                        
                        Text("ETH").foregroundStyle(Color.gray)
                        
                        
                    }
                }.padding(.top, 16).padding(.bottom,56)
                
                Spacer()
                
                HStack{
                    Text("Gas Price")
                    let gasStr = String.hexadecimalToDecimal(gasPrice)
                    Text  (gasStr + " WEI")
                }.padding(.bottom).frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                Button {
                    viewModel.sendTransaction(
                        address: senderAddress,
                        value: value
                    ) { result, error in
                        if(result != nil) {
                            self.hash = result!
                            showToast.toggle()
                        }
                    }
                } label: {
                    Text("Send ETH")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .padding(2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                
                
            }
            .simpleToast(isPresented: $showToast, options: toastOptions){
                Link(destination: URL(string: "https://sepolia.etherscan.io/tx/\(hash)")!, label: {
                    Text("Transaction submitted successfully")
                        .padding(20)
                        .background(Color.green)
                        .foregroundColor(Color.black)
                        .cornerRadius(14)
                        .frame(maxWidth: .infinity)
                })
            }
            
            .padding()
            .onAppear{
                viewModel.loadGasPrice{
                    gasPrice in
                    self.gasPrice = gasPrice
                    
                }
            }.alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text(viewModel.alertContent))
            })
            
            
        }
    }
    
}

#Preview {
    SendView(viewModel: MainViewModel())
}
