//
//  Pictures.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import Foundation
/// A model representing a food item that can be encoded to and decoded from JSON.
///
/// Food encapsulates server-provided metadata such as a unique identifier, display
/// name, like state, image URL, a textual description, the country of origin, and
/// the last time the record was updated. It also exposes convenient computed
/// properties for presenting a flag emoji derived from the country code and a
/// human‑readable date string derived from the raw update timestamp.
///
/// Conforms to: `Codable`.
///
/// Typical JSON payload:
/// ```json
/// {
///   "id": 123,
///   "name": "Jollof Rice",
///   "isLiked": true,
///   "photoURL": "https://example.com/images/jollof.jpg",
///   "description": "A West African rice dish…",
///   "countryOfOrigin": "NG",
///   "lastUpdatedDate": "2025-08-10T14:23:11Z"
/// }
/// ```

/// Coding keys that map incoming/outgoing JSON fields to `Food`'s properties.
///
/// Expected JSON schema:
/// - `id`: Integer unique identifier
/// - `name`: String name of the food item
/// - `isLiked`: Boolean like/favorite state
/// - `photoURL`: String URL to an image
/// - `description`: String description of the food
/// - `countryOfOrigin`: Two-letter ISO 3166‑1 alpha‑2 country code (e.g., "US", "NG")
/// - `lastUpdatedDate`: ISO‑8601 UTC timestamp string (e.g., "2025-08-10T14:23:11Z")

/// Creates a new `Food` by decoding from the given decoder.
///
/// - Parameter decoder: The decoder to read data from.
/// - Throws: An error if decoding fails or if required values are missing or malformed.
/// - Note: This initializer expects `lastUpdatedDate` to be an ISO‑8601 UTC timestamp
///         in the form `"yyyy-MM-dd'T'HH:mm:ss'Z'"`.

/// A stable, unique identifier for the food item (as provided by the backend/service).

/// The user‑visible name of the food item.

/// Whether the current user has marked this food item as liked/favorited.

/// The absolute or relative URL string of an image representing the food item.
///
/// - Important: This is a raw string; convert it to `URL` and validate before network usage.

/// A human‑readable description of the food item.

/// The country code the food originates from.
///
/// - Important: Expected to be a two‑letter ISO 3166‑1 alpha‑2 country code (e.g., "US", "NG", "JP").
/// - SeeAlso: `flagEmoji`

/// A raw timestamp string indicating when this record was last updated, as received from the backend.
///
/// - Format: `"yyyy-MM-dd'T'HH:mm:ss'Z'"` (ISO‑8601, UTC).
/// - SeeAlso: `formattedDate`

/// A Unicode flag emoji derived from `countryOfOrigin`.
///
/// Builds a regional indicator flag by transforming each letter of the country code
/// into its corresponding regional indicator symbol.
///
/// - Returns: A flag emoji string when `countryOfOrigin` is a valid two‑letter code;
///            otherwise, a best‑effort string that may be empty or not render as a flag.

/// A localized, human‑readable representation of `lastUpdatedDate`.
///
/// Attempts to parse `lastUpdatedDate` using the format `"yyyy-MM-dd'T'HH:mm:ss'Z'"`.
/// On success, returns a date string with `.medium` date style and `.short` time style
/// in the user's current locale and time zone. If parsing fails, returns the original
/// `lastUpdatedDate` unchanged.
///
/// - Example result: “Aug 10, 2025 at 2:23 PM”
class Food: Codable {
    private enum CodingKeys: String, CodingKey {
        case id,  name, isLiked, photoURL, description, countryOfOrigin, lastUpdatedDate
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()

        let container               = try decoder.container(keyedBy: CodingKeys.self)
        self.id                     = try container.decode(Int.self, forKey: .id)
        self.name                   = try container.decode(String.self, forKey: .name)
        self.isLiked                  = try container.decode(Bool.self, forKey: .isLiked)
        self.photoURL                 = try container.decode(String.self, forKey: .photoURL)
        self.description                    = try container.decode(String.self, forKey: .description)
        self.countryOfOrigin            = try container.decode(String.self, forKey: .countryOfOrigin)
        self.lastUpdatedDate            = try container.decode(String.self, forKey: .lastUpdatedDate)
    }


    
        var id                    : Int = 0
        var name                  : String = ""
        var isLiked               : Bool = false
        var photoURL              : String = ""
        var description           : String = ""
        var countryOfOrigin       : String = ""
        var lastUpdatedDate       : String = ""
    
    
    var flagEmoji: String {
         let base: UInt32 = 127397
         var emoji = ""
         for scalar in countryOfOrigin.unicodeScalars {
             if let unicodeScalar = UnicodeScalar(base + scalar.value) {
                 emoji.append(String(unicodeScalar))
             }
         }
         return emoji
     }
     
     var formattedDate: String {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
         
         if let date = formatter.date(from: lastUpdatedDate) {
             let displayFormatter = DateFormatter()
             displayFormatter.dateStyle = .medium
             displayFormatter.timeStyle = .short
             return displayFormatter.string(from: date)
         }
         return lastUpdatedDate
     }
    
    
}
