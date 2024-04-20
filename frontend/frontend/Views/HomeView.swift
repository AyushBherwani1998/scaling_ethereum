//
//  HomeView.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI
import SimpleToast
import CodeScanner



let address="0xcc89B59D28A2d63fD9134f9d843547942747b40f"
let result = address.split(separator: "")
let suffixAddress=result[38]+result[39]+result[40]+result[41]
let prefixAddress=result[0]+result[1]+result[2]+result[3]

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
    
    @State private var showToast = false
    @State var toastStr = "None"
    
    @State var isPresentingScanner = false
    @State var isShowingBottomSheet = false
    @State private var scannedCode: String = ""
    
    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    
                    self.scannedCode = "\(code)"
                    self.isPresentingScanner = false
                    self.isShowingBottomSheet = true
                }
            }
        )
    }
    
    
    var body: some View {
        
        if !viewModel.isAccountReady {
            ProgressView()
        } else {
            VStack {
                Image("sage-logo")
                    .resizable()
                    .frame(width: 88, height: 49)
                    .padding(.bottom, 24)
                VStack{
                    Text(viewModel.balance.description + " ETH")
                        .font(.system(size:44))
                        .fontWeight(.semibold)
                    
                    Text(String.addressAbbreivation(
                        address: viewModel.erc4337Helper.address
                    ))
                    .padding(.bottom, 4).font(Font.title)
                    
                    
                    
                    
                }
                
                HStack{
                    
                    Button{
                    } label: {
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
                        }
                    }
                    .padding()
                    Button{
                        
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
                    
                    .sheet(isPresented: $isShowingBottomSheet){
                        VStack{
                            
                            Text("Connecting to")
                                .padding(.top,32)
                                .font(.system(size: 32))
                                .padding(.bottom,32)
                                .fontWeight(.semibold)
                            
                            HStack{
                                Text("Protocol Name")
                                Spacer()
                                Text("Uniswap")
                            }.padding(.bottom,24)
                            
                            HStack{
                                Text("URL")
                                Spacer()
                                Text("www.uniswap.com")
                            }.padding(.bottom,24)
                            
                            HStack{
                                Text("Chains")
                                Spacer()
                                Text("Sepolia")
                            }.padding(.bottom,24)
                            
                            Spacer()
                            
                            Button {
                                //Wallet connect goes here
                                showToast.toggle()
                                toastStr = "Wallet Connected"
                                self.isShowingBottomSheet = false
                                
                            } label: {
                                Text("Connect")
                                    .frame(maxWidth: .infinity)
                                    .fontWeight(.semibold)
                                    .padding(2)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            
                        }
                        .padding()
                        
                        
                    }
                    .sheet(isPresented: $isPresentingScanner){
                        self.scannerSheet
                    }
                    
                    .padding()
                    
                    Button{
                        showToast.toggle()
                        toastStr = "Your wallet attestation code is " + attestCode
                        
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
                }
                .frame(alignment: .top)
                
                Text("Recent Transactions")
                    .padding(.top, 24)
                    .font(.system(size:21))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                    .fontWeight(.medium)
                    .padding()
                
                VStack{
                    
                    //Transaction logic to be added
                    
                        HStack(spacing: 20){
                            Image(systemName:"checkmark.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.green)
                            VStack(spacing: 4){
                                Text("Device attestation")
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                
                                Text("0x..231")
                                    .font(.subheadline)
                                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                                
                                
                            }.frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        
                    }
                    .padding(16)
                    
                    .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    
                    Text("You don't have any new transactions")
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    
                }
                .frame( maxWidth: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                
                
                Spacer()
                
                
            }
            .simpleToast(isPresented: $showToast, options: toastOptions){
                Text(toastStr)
                    .padding(20)
                    .frame(maxWidth: 358)
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(14)
            }
        }
    }
}
