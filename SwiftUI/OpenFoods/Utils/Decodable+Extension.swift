//
//  Decodable+Extension.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

extension Decodable {
    /// Decodes an instance of the conforming type from the provided JSON data.
    ///
    /// This is a convenience that uses a fresh `JSONDecoder()` with its default strategies to
    /// transform raw JSON bytes into a value of `Self`.
    ///
    /// - Parameter data: The raw `Data` containing a JSON representation of `Self`.
    /// - Returns: A fully decoded instance of `Self`.
    /// - Throws: Any error thrown by `JSONDecoder.decode(_:from:)`, most commonly a `DecodingError`
    ///   (e.g., `.dataCorrupted`, `.keyNotFound`, `.typeMismatch`, `.valueNotFound`) if the data
    ///   is not valid JSON for the expected shape.
    /// - Discussion: The method uses `JSONDecoder`'s default strategies:
    ///   - Key decoding: `.useDefaultKeys`
    ///   - Date decoding: `.deferredToDate`
    ///   - Data decoding: `.base64`
    ///
    ///   If you need custom decoding behavior (e.g., snake_case keys or custom date formats),
    ///   configure your own `JSONDecoder` and call `decode(_:from:)` directly.
    /// - Important: The top-level JSON must match the structure of `Self`.
    /// - SeeAlso: `JSONDecoder`, `Decodable`
    /// - Example:
    ///   ```swift
    ///   struct User: Decodable {
    ///       let id: Int
    ///       let name: String
    ///   }
    ///
    ///   let json = #"{"id": 1, "name": "Ava"}"#.data(using: .utf8)!
    ///   let user = try User.decode(data: json)
    ///   print(user.name) // "Ava"
    ///   ```
    static func decode(data: Data) throws -> Self {
        try JSONDecoder().decode(Self.self, from: data)
    }
}
