//
//  Decodable+Extension.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

extension Decodable {
    static func decode(data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
