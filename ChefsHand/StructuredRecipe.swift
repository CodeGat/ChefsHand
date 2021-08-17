//
//  StructuredRecipe.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 17/8/21.
//

import Foundation

struct StructuredRecipe: Codable {
    var name: String
    var ingredients: [Ingredient]
    var method: [Step]
    
    struct Ingredient: Codable {
        var text: String
        var isDone: Bool
    }
    
    struct Step: Codable {
        var instruction: String
        var isDone: Bool
        var cookingTimes: [CookingTimer]
    }
    
    struct CookingTimer: Codable {
        let time: Int
        let timeDefStart: Int
        let timeDefEnd: Int
    }
}

struct TasteRecipe: Decodable {
    var recipeInstructions: [String]
    var recipeIngredient: [String]
}

extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
