//
//  Foods.swift
//  OpenFoods
//
//  Created by Oluwatobi Oladipupo on 2025-09-25.
//

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
