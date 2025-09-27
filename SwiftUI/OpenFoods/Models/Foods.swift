//
//  Foods.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-25.
//

/// A container object representing a collection of food items returned by the OpenFoods service,
/// along with metadata about the overall number of results.
/// 
/// This type is `Codable` and is intended to model a typical paginated or aggregated API response
/// where the current page of results is provided in `foods`, while `totalCount` communicates the
/// total number of matching items available on the server (which may be greater than `foods.count`).
///
/// - SeeAlso: `Food`
/// - Note: Properties have sensible defaults (`foods` is empty and `totalCount` is `0`) so the
///         instance is usable even before decoding.

/// Coding keys mapping between JSON keys and the corresponding properties on `Foods`.
/// 
/// - `foods`: The JSON array of individual food records.
/// - `totalCount`: The JSON integer describing the total number of available food records
///                 for the given request or query.

/// Creates a new `Foods` instance by decoding from the given decoder.
/// 
/// This initializer decodes the `foods` array and the `totalCount` value from the keyed container
/// using the `CodingKeys` mapping.
/// 
/// - Parameter decoder: The decoder to read data from.
/// - Throws: A `DecodingError` if required keys are missing or if values are of an unexpected type.
/// - SeeAlso: `init()`

/// The list of decoded `Food` items included in this response segment.
/// 
/// - Default: An empty array.
/// - SeeAlso: `Food`

/// The total number of food records that match the request on the server.
/// 
/// This value may exceed the number of items present in `foods`, for example when results are
/// paginated.
/// 
/// - Default: `0`
class Foods: Codable {
    private enum CodingKeys: String, CodingKey {
        case foods,  totalCount
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init()

        let container               = try decoder.container(keyedBy: CodingKeys.self)
        self.foods                     = try container.decode(Array<Food>.self, forKey: .foods)
        self.totalCount                 = try container.decode(Int.self, forKey: .totalCount)
    }


    
        var foods                    = [Food]()
        var totalCount               : Int = 0
    
}
