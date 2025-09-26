//
//  Sha256+String.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//




import CryptoKit
import Foundation

// MARK: - String Extension for URL Hashing
extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
