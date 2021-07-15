//
//  CurrentRecipe.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import Foundation

class Recipe {
    struct StructuredRecipe: Codable {
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
    
    func setRecipeIngredientIsDone(at rowIndex: Int, to value: Bool) {
        recipe.ingredients[rowIndex].isDone = value
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
