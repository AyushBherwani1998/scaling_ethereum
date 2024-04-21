//
//  HomeView.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI
import SimpleToast
import CodeScanner


private let toastOptions = SimpleToastOptions(
    alignment: .top,
    hideAfter: 8,
    backdrop: Color.black.opacity(0.3),
    animation: .default,
    modifierType: .slide
    
)

struct HomView: View {
    @StateObject var viewModel: MainViewModel
    @State private var attestCode = "44"
    @State private var hash = ""
    
    @State private var showToast = false
    @State var toastStr = "None"
    
    @State var isPresentingScanner = false
    @State private var scannedCode: String = ""
    
    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = "\(code)"
                    self.isPresentingScanner = false
                }
            }
        )
    }
    
    
    var body: some View {
        
       if(!viewModel.isAccountReady) {
           LoaderView(loadingMessage: $viewModel.loaderText)
        }else {
            VStack {
                Image("sage-logo")
                    .resizable()
                    .frame(width: 88, height: 49)
                    .padding(.bottom, 24)
                VStack{
                    Text(String(format: "%.4f", NSDecimalNumber(decimal: viewModel.balance).floatValue))
                        .font(.system(size:44))
                        .fontWeight(.semibold)
                    
                    Text(String.addressAbbreivation(
                        address: viewModel.erc4337Helper.address
                    ))
                    .padding(.bottom, 4).font(Font.title)
                    
                    
                    
                    
                }
                
                HStack(alignment: .top){
                    NavigationLink(destination: {
                        SendView(viewModel: viewModel)
                    }, label: {
                        
                        VStack{
                            Image(systemName: "arrow.up.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                                .foregroundStyle(.white)
                                .frame( maxWidth: 56,maxHeight: 56)
                                .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 36, height: 36)))
                            
                            Text("Send")
                                .foregroundStyle(.white)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .font(.system(size:13))
                        }.padding()
                        
                        
                    })
                    
                    Button{
                        UIPasteboard.general.string = viewModel.erc4337Helper.address
                        showToast.toggle()
                        toastStr="Your address is copied to the clipboard"
                        
                    } label: {
                        VStack{
                            Image(systemName: "arrow.down.circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                                .foregroundStyle(.white)
                                .frame( maxWidth: 56,maxHeight: 56)
                                .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 36, height: 36)))
                            
                            Text("Recieve")
                                .foregroundStyle(.white)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .font(.system(size:13))
                        }
                    }
                    .padding()
                    
                    Button{
                        
                        self.isPresentingScanner = true
                        
                    } label: {
                        VStack{
                            Image(systemName: "qrcode")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                                .foregroundStyle(.white)
                                .frame( maxWidth: 56,maxHeight: 56)
                                .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 36, height: 36)))
                            
                            Text("Wallet Connect")
                                .foregroundStyle(.white)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .font(.system(size:13))
                        }
                    }
                    .sheet(isPresented: $isPresentingScanner){
                        self.scannerSheet
                    }
                    .padding()
                    
                    Button{
                        viewModel.createMPCAttestationFactor {
                            attestCode, hash in
                            showToast.toggle()
                            self.hash = hash
                            toastStr = "Your wallet attestation code is " + attestCode
                        }
                        
                    } label: {
                        VStack{
                            Image(systemName: "plus.viewfinder")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                                .foregroundStyle(.white)
                                .frame( maxWidth: 56,maxHeight: 56)
                                .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 36, height: 36)))
                            
                            Text("Attest device")
                                .foregroundStyle(.white)
                                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                                .font(.system(size:13))
                        }
                    }
                    .padding()
                }.multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                .frame(alignment: .top)
                
                Text("Recent Transactions")
                    .padding(.top, 24)
                    .font(.system(size:21))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                    .fontWeight(.medium)
                    .padding()
                
//                VStack{
//                    Text("You don't have any new transactions")
//                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
//                    
//                    
//                }
//                .frame( maxWidth: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                ScrollView {
                    ForEach(viewModel.transactions, id: \.hash) {
                        transaction in
                        
                        HStack(spacing: 20){
                            Image(systemName:"checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.green)
                            VStack(spacing: 4){
                                Text(transaction.name)
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text(String.addressAbbreivation(
                                    address: transaction.hash
                                ))
                                    .font(.subheadline)
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                
                                
                            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                            
                        }
                        .padding(16)
                        
                        .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }.padding()
                
                
            }
            .simpleToast(isPresented: $showToast, options: toastOptions){
                Link(destination: URL(string: "https://sepolia.etherscan.io/tx/\(hash)")!, label: {
                    Text(toastStr)
                    .padding(20)
                    .frame(maxWidth: 358)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(14)
                })
            }.alert(isPresented: $viewModel.showAlert, content: {
                Alert(title: Text(viewModel.alertContent))
            })
        }
    }
}
