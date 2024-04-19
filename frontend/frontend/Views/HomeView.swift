//
//  HomeView.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import SwiftUI

let address="0xcc89B59D28A2d63fD9134f9d843547942747b40f"
let result = address.split(separator: "")
let suffixAddress=result[38]+result[39]+result[40]+result[41]
let prefixAddress=result[0]+result[1]+result[2]+result[3]

struct HomView: View {
    @StateObject var viewModel: MainViewModel
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
                    .padding()
                    
                    Button{
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
                
                Text("Recent Transactions")
                    .padding(.top, 24)
                    .font(.system(size:21))
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
                    .fontWeight(.medium)
                    .padding()
                
                VStack{
                    Text("You don't have any new transactions")
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    
                }
                .frame( maxWidth: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                
                
                
                Spacer()
                
                
            }
        }
    }
}
