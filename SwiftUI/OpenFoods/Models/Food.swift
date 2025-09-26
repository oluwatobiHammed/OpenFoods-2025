//
//  Pictures.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//
import Foundation
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
