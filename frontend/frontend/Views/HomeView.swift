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
                    Text(prefixAddress+"..."+suffixAddress)
                        .padding(.bottom, 4)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                    
                    
                    Text(String(viewModel.balance.formatted(format: "%.3f")) + " ETH")
                        .font(.system(size:44))
                        .fontWeight(.semibold)
                    
                }
                
                HStack{
                    
                    Button{
                    } label: {
                        VStack{
                            Image(systemName: "arrow.uturn.up.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                            Text("Send")
                            
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 72)
                        
                        .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
                        
                    }
                    .padding()
                    Button{
                    } label: {
                        VStack{
                            Image(systemName: "arrow.uturn.down.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.bottom, 2)
                                .padding(.top, 4)
                            Text("Receive")
                            
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: 72)
                        
                        .background(Color(red: 54 / 255, green: 54 / 255, blue: 56 / 255))
                                            .border(Color.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        
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
