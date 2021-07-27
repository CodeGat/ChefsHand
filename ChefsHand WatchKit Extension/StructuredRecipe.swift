//
//  CurrentRecipe.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import Foundation

class Recipe {
    struct StructuredRecipe: Codable, Equatable {
        static func == (lhs: Recipe.StructuredRecipe, rhs: Recipe.StructuredRecipe) -> Bool {
            return lhs.name == rhs.name
        }
        
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



    static let shared = Recipe()
    private var recipe: StructuredRecipe?
    private var hasChanges: Bool = false
    private let defaults = UserDefaults.standard
    
    func getRecipe() -> StructuredRecipe? {
        return recipe
    }
    
    func recipeExists() -> Bool {
        return recipe != nil
    }
    
    func setRecipe(givenData data: Any) {
        do {
            recipe = try StructuredRecipe(from: data)
        } catch {
            print(error)
        }
        hasChanges = false
        defaults.storeRecipe(recipe!)
    }
    
    func setRecipe(givenRecipe recipe: StructuredRecipe) {
        self.recipe = recipe
        hasChanges = false
        defaults.storeRecipe(recipe)
    }
    
    func storeRecipeChanges() {
        if hasChanges {
            defaults.storeRecipe(recipe!)
            hasChanges = false
        }
    }
    
    func setRecipeIngredientIsDone(at rowIndex: Int, to value: Bool) {
        recipe!.ingredients[rowIndex].isDone = value
        hasChanges = true
    }
    
    func setRecipeStepIsDone(at rowIndex: Int, to value: Bool) {
        recipe!.method[rowIndex].isDone = value
        hasChanges = true
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

extension UserDefaults {
    func retrieveRecipe() -> Recipe.StructuredRecipe? {
        guard let recipe : Any = self.object(forKey: "recipe") else {
            print("couldn't find 'recipe' key when retrieving key")
            return nil
        }
        do {
            return try Recipe.StructuredRecipe(from: recipe)
        } catch {
            print("Couldn't convert recipe: \(error)")
            return nil
        }
    }
    
    func storeRecipe(_ recipe: Recipe.StructuredRecipe) {
        self.setValue(recipe.dictionary, forKey: "recipe")
    }
    
    func recipeKeyExists() -> Bool {
        return self.object(forKey: "recipe") != nil
    }
}
