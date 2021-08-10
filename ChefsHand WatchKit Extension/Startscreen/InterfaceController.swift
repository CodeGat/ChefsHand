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
    
    @IBAction func accessDeveloperSettings(_ sender: Any) {
        pushController(withName: "Developer Settings", context: nil)
    }
    
    @IBAction func cookingModeSwitched(_ value: Bool) {
        let extensionDelegate = WKExtension.shared().delegate as! ExtensionDelegate
        
        extensionDelegate.cookingModeSwitchState = value
        if value {
            extensionDelegate.extendedRuntimeSession.start()
        } else {
            print("invalidating extendedRuntimeSession")
            extensionDelegate.extendedRuntimeSession.invalidate()
        }
    }
    let session = WCSession.default
    let defaults = UserDefaults.standard
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = recipeTable.rowController(at: rowIndex) as! RecipeRowController
        
        switch selectedRow.type {
        case .cached:
            Recipe.shared.setRecipe(givenRecipe: defaults.retrieveRecipe()!)
        case .more:
            loadRecipeNamesFromIphone(amount: 5)
        case .phone:
            loadRecipeIntoCacheFromIphone(named: selectedRow.name!)
        case .none:
            fatalError("uninitialised row type, exiting")
        }
    }

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        refreshTable()
    }
    
    func loadRecipeNamesFromIphone(amount: Int) {
        print("stub loadRecipeNamesFromIphone")
    }
    
    func loadRecipeIntoCacheFromIphone(named name: String) {
        print("stub loadRecipeIntoCacheFromIphone")
    }
    
    // MARK: Need to decide on if retriving/getting recipe should be possibly nil or not (check Recipe.getRecipe)
    func refreshTable() {
        var tableRowIx: Int = 0
        
        recipeTable.setNumberOfRows(1 + (Recipe.shared.recipeExists() || defaults.recipeKeyExists() ? 1 : 0), withRowType: "Recipe Row")
        
        if let recipe: Recipe.StructuredRecipe = Recipe.shared.getRecipe() {
            let cachedController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
            cachedController.name = recipe.name
            cachedController.type = .cached
            tableRowIx += 1
        } else if let recipe: Recipe.StructuredRecipe = defaults.retrieveRecipe() {
            let cachedController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
            cachedController.name = recipe.name
            cachedController.type = .cached
            tableRowIx += 1
        }
        let moreController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
        moreController.name = "Load more..."
        moreController.type = .more
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        Recipe.shared.setRecipe(givenData: applicationContext["recipe"] as Any)
        refreshTable()
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        let recipe = message["recipe"] as Any
        Recipe.shared.setRecipe(givenData: recipe)
        label.setText("A new recipe is availible!")
        refreshTable()
    }
}
