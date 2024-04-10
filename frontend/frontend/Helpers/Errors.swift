//
//  Errors.swift
//  frontend
//
//  Created by Ayush B on 10/04/24.
//

import Foundation

public struct RuntimeError: Error {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
