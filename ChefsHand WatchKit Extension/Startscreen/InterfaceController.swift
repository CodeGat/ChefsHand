//
//  InterfaceController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 6/7/21.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var recipeTable: WKInterfaceTable!
    @IBAction func resetUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "recipes")
    }
    let session = WCSession.default
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let defaults = UserDefaults.standard
        let selectedRow = recipeTable.rowController(at: rowIndex) as! RecipeRowController
        
        let recipes: [Any] = defaults.array(forKey: "recipes")!
        var structuredRecipes: [Recipe.StructuredRecipe] = []
        do {
            structuredRecipes =  try recipes.map { try Recipe.StructuredRecipe(from: $0)}
        } catch {
            print("Couldn't convert all recipes to StructuredRecipes: \(error)")
        }
        
        for structuredRecipe in structuredRecipes where structuredRecipe.name == selectedRow.name {
            Recipe.shared.setRecipe(given: structuredRecipe)
        }
    }

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        guard let recipes: [Any] = UserDefaults.standard.array(forKey: "recipes") else {
            print("No recipes to add to the table!")
            return
        }
        recipeTable.setNumberOfRows(recipes.count, withRowType: "Recipe Row")
        
        for (index, recipe) in recipes.enumerated() {
            let controller: RecipeRowController = recipeTable.rowController(at: index) as! RecipeRowController
            do {
                let structuredRecipe = try Recipe.StructuredRecipe(from: recipe)
                controller.name = structuredRecipe.name
            } catch {
                print("Couldn't load recipe name: \(error)")
            }

        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func tapSendDataToiPhone() {
        let data: [String: Any] = ["watch": "This is from my watch!" as String]
        session.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Recipe.shared.setRecipe(given: applicationContext["recipe"] as Any)
        
        addRecipeToUserCollection(applicationContext["recipe"] as Any)
    }
    
    func addRecipeToUserCollection(_ recipe: Any) {
        let defaults = UserDefaults.standard
        var newRecipes: [Any] = defaults.array(forKey: "recipes") ?? []
        newRecipes.append(recipe)
        defaults.setValue(newRecipes, forKey: "recipes")
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let recipe = message["recipe"] as Any
        Recipe.shared.setRecipe(given: recipe)
        label.setText("A new recipe is availible!")
        addRecipeToUserCollection(recipe)
    }
}
