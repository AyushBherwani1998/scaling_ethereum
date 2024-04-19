//
//  SendView.swift
//  sage-wallet
//
//  Created by Aashish Methani on 19/04/24.
//

import SwiftUI
import UIKit
import SimpleToast


struct GasPrice: Decodable {
    var result: String
}

private let toastOptions = SimpleToastOptions(
    alignment: .top,
    hideAfter: 3,
    backdrop: Color.black.opacity(0.3),
    animation: .default,
    modifierType: .slide
    
)

struct SendView: View {
    @State var SenderAddress = ""
    @State var EthAmt = ""
    @State var Gas = "0.00"
    @State private var showToast = false
    @State private var txnState = true

    var body: some View {
        
        VStack{
    
            VStack(alignment: .leading){
                Text("Send to")
                    .font(.title2)
                HStack{
                    TextField("Enter address", text: $SenderAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .padding(.trailing,12)
                    Button("Paste"){
                        
                        if let pastedText = UIPasteboard.general.string {
                            SenderAddress = pastedText
                            
                        }
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom,48)
            
            
            VStack(alignment: .leading){
                Text("Amt in ETH")
                    .font(.title2)
                HStack{
                    TextField("0.00", text: $EthAmt)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .font(.system(size: 44))
                        .padding(.trailing,12)
                    Text("ETH")
                        .foregroundStyle(Color.gray)
                            
                
                }
            }
            .padding(.top, 16)
            .padding(.bottom,56)
            
            Spacer()
            
            HStack{
                Text("Gas Price")
                let gasStr = hexadecimalToDecimal(Gas)
                Text  (gasStr + " WEI")
            }
            .padding(.bottom)
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            
            Button {
                if txnState{
                    showToast.toggle()
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
            Text("Transaction submitted successfully")
                .padding(20)
                .background(Color.green)
                .foregroundColor(Color.black)
                .cornerRadius(14)
        }
            
        .padding()
        .onAppear{
            Task {
                let (data, _) = try await URLSession.shared.data(from: URL(string:"https://api-sepolia.etherscan.io/api?module=proxy&action=eth_estimateGas&data=0x60fe47b10000000000000000000000000000000000000000000000000000000000000004&to=0x272c31fC25E4e609CbCC9E7a9e6171b4B39feAca&value=0x0&gasPrice=0x51da038cc&gas=0x186A0&apikey=NMDU6G1SBPRCYCA2HHNH6AV6JE5RWCIG55")!)
                let decodedResponse = try? JSONDecoder().decode(GasPrice.self, from: data)
                Gas = decodedResponse?.result ?? ""
            }
        }
        
    
    }
        
}

func hexadecimalToDecimal(_ hex: String) -> String {
    let hexDigits: [Character: Int] = ["0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15]
    var decimalValue = 0
    
    let hexString = hex.uppercased()

    for char in hexString.dropFirst(2) {
        guard let digitValue = hexDigits[char] else {

            return "0.00"
        }
        decimalValue = decimalValue * 16 + digitValue
    }
    
    return String(decimalValue)
}


#Preview {
    SendView()
}
