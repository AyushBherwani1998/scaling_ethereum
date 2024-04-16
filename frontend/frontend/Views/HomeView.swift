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

struct Bal: Decodable {
    var result: String
}

struct HomView: View {
    @State var balance: String = "0.0"
    
    var body: some View {
        
        VStack {
            Image("sage-logo")
                .resizable()
                .frame(width: 88, height: 49)
                .padding(.bottom, 24)
            VStack{
                Text(prefixAddress+"..."+suffixAddress)
                    .padding(.bottom, 4)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                
                
                Button(action: {
                    Task {
                        let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api-sepolia.etherscan.io/api?module=account&action=balance&address=" + address + "&tag=latest&apikey=NMDU6G1SBPRCYCA2HHNH6AV6JE5RWCIG55")!)
                        let decodedResponse = try? JSONDecoder().decode(Bal.self, from: data)
                        balance = decodedResponse?.result ?? ""
                    }
                }) {
                    let floatBal = (Float(balance) ?? 0) * pow(10, -18)
                    Text(String(format: "%.3f", floatBal) + " ETH")
                        .font(.system(size:44))
                        .fontWeight(.semibold)
                }
                .buttonStyle(PlainButtonStyle())
              
                    
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
//                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 12)))
//                        .border(Color.red)
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
//                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8, height: 12)))
//                        .border(Color.red)
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






#Preview {
    home_view()
}
