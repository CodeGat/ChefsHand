//
//  File.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 22/8/21.
//

import Foundation

class UserDefaultsRecipe: UserDefaultSavable {
    static let shared = UserDefaultsRecipe()
    private var recipe: Recipe?
    private var hasChanges: Bool = false
    private let defaults = UserDefaults.standard

    func getRecipe() -> Recipe? {
        return recipe
    }
    
    func recipeExists() -> Bool {
        return recipe != nil
    }
    
    func setRecipe(givenData data: Any) {
        do {
            recipe = try Recipe(from: data)
        } catch {
            print(error)
        }
        hasChanges = false
        defaults.storeRecipe(recipe!)
    }
    
    func setRecipe(givenRecipe recipe: Recipe) {
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

extension UserDefaults {
    func retrieveRecipe() -> Recipe? {
        guard let recipe : Any = self.object(forKey: "recipe") else {
            print("couldn't find 'recipe' key when retrieving key")
            return nil
        }
        do {
            return try Recipe(from: recipe)
        } catch {
            print("Couldn't convert recipe: \(error)")
            return nil
        }
    }
    
    func storeRecipe(_ recipe: Recipe) {
        self.setValue(recipe.dictionary, forKey: "recipe")
    }
    
    func recipeKeyExists() -> Bool {
        return self.object(forKey: "recipe") != nil
    }
}
