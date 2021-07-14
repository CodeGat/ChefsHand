//
//  CurrentRecipe.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import Foundation

class Recipe {
    struct StructuredRecipe: Codable {
        var ingredients: [String]
        var method: [Step]
    }

    struct Step: Codable {
        var instruction: String
        var cookingTimes: [CookingTimer]
    }

    struct CookingTimer: Codable {
        let time: Int
        let timeDefStart: Int
        let timeDefEnd: Int
    }

    static let shared = Recipe()
    private var recipe: StructuredRecipe = StructuredRecipe(ingredients: [], method: [])
    private var recipeIsNew: Bool = false
    
    func getRecipe() -> StructuredRecipe {
        return recipe
    }
    
    func setRecipe(given data: Any) {
        do {
            recipe = try StructuredRecipe(from: data)
        } catch {
            print(error)
        }
    }
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
