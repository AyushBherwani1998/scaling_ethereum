//
//  CurvegridHelper.swift
//  frontend
//
//  Created by Ayush B on 20/04/24.
//

import Foundation

class CurveGridHelper {
    
    func payFees(address: String) async throws -> Bool {
        let url = URL(string: "https://jic5c4zd4fb43it4jmtvaodogq.multibaas.com/api/v0/chains/ethereum/hsm/submit")!
        var request = URLRequest(url: url)
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiaWF0IjoxNzEzNjIyOTEyLCJqdGkiOiJhOTY2NDAzYS1lYTNjLTRmOTUtYjViOC1hOTI2OTIxZTgyMGEifQ.xiU6taCizLJjUfVrqJ5flHerGe_VRpgZZnW7wPX8rfc", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let body = [
            "tx": [
                "gas": 41000,
                "from": "0xC85518Cda16af0c0460eD6c23EBdc5421Dd23298",
                "value": "1000000000000000",
                "to": address,
                "data": "0x00",
                "type": 0,
            ]
        ]
        
        
        let data = try JSONSerialization.data(withJSONObject: body)
        let (responseData, response) = try await URLSession.shared.upload(for: request, from: data
        )
    
        let transactionHistory = try JSONDecoder().decode(
            CurveGridHSMResponse.self, from: responseData
        )
        
        return transactionHistory.result.submitted
    }
}



// MARK: - CurveGridHSMResponse
struct CurveGridHSMResponse: Codable {
    let status: Int
    let message: String
    let result: Result
}

// MARK: - Result
struct Result: Codable {
    let tx: Tx
    let submitted: Bool
}

// MARK: - Tx
struct Tx: Codable {
    let nonce: Int
    let gasPrice, gasFeeCap, gasTipCap: String
    let gas: Int
    let from, to, value, data: String
    let hash: String
    let type: Int
}
