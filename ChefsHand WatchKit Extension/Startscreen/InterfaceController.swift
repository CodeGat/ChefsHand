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
    let connectivityManager = WatchConnectivityManager.shared
    let recipeManager = UserDefaultsRecipe.shared
    let defaults = UserDefaults.standard
    var recipeNames = [String]()
    
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
            extensionDelegate.extendedRuntimeSession.invalidate()
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = recipeTable.rowController(at: rowIndex) as! RecipeRowController
        
        switch selectedRow.type {
        case .cached:
            recipeManager.setRecipe(givenRecipe: defaults.retrieveRecipe()!)
        case .more:
            loadRecipeNamesFromIphone()
        case .phone:
            loadRecipeIntoCacheFromIphone(named: selectedRow.name!)
        case .none:
            fatalError("uninitialised row type, exiting")
        }
    }

    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        connectivityManager.watchDelegate = self
        connectivityManager.startSession()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        refreshTable()
    }
    
    func loadRecipeNamesFromIphone() {
        let recipeNamesToRequest = recipeNames.count + 3
        connectivityManager.sendMessage(message: ["recipeNamesRequest": recipeNamesToRequest], replyHandler: {reply in
            self.recipeNames = reply["recipeNamesResponse"] as! [String]
            self.refreshTable()
        }, errorHandler: {error in
            print(error)
        })
    }
    
    func loadRecipeIntoCacheFromIphone(named name: String) {
        connectivityManager.sendMessage(message: ["recipeRequest": name], replyHandler: {reply in
            if let recipeResponse = reply["recipeResponse"] {
                UserDefaultsRecipe.shared.setRecipe(givenData: recipeResponse)
                self.refreshTable()
            }
        }, errorHandler: {error in
            print(error)
        })
    }

    func refreshTable() {
        var tableRowIx: Int = 0
        let cachedRecipesNum: Int = recipeManager.recipeExists() || defaults.recipeKeyExists() ? 1 : 0
        var phoneRecipesNum: Int = 0
        if recipeNames.count != 0 {
            if cachedRecipesNum != 0 {
                phoneRecipesNum = recipeNames.count - 1
            } else {
                phoneRecipesNum = recipeNames.count
            }
        }
        let numberOfRows: Int = 1 + cachedRecipesNum + phoneRecipesNum
        
        recipeTable.setNumberOfRows(Int(numberOfRows), withRowType: "Recipe Row")

        if let recipe: Recipe = recipeManager.getRecipe() {
            let cachedController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
            cachedController.name = recipe.name
            cachedController.type = .cached
            tableRowIx += 1
        } else if let recipe: Recipe = defaults.retrieveRecipe() {
            let cachedController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
            cachedController.name = recipe.name
            cachedController.type = .cached
            tableRowIx += 1
        }
        
        let cachedRecipeController: RecipeRowController? = recipeTable.rowController(at: 0) as? RecipeRowController // this will be the cached recipe row, if it exists
        for recipeName in recipeNames {
            if (recipeName != cachedRecipeController?.name) {
                let nameController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
                nameController.name = recipeName
                nameController.type = .phone
                tableRowIx += 1
            }
        }
        
        let moreController = recipeTable.rowController(at: tableRowIx) as! RecipeRowController
        moreController.name = "Load more..."
        moreController.type = .more
    }

    // MARK: reimplement applicationcontext in WatchConnectivityManager
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
//        Recipe.shared.setRecipe(givenData: applicationContext["recipe"] as Any)
//        refreshTable()
//    }
}

extension InterfaceController: WatchConnectivityDelegate {
    func recievedMessage(session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?) {
        if let recipeData = message["recipe"] {
            recipeManager.setRecipe(givenData: recipeData)
            label.setText("A new recipe is up - swipe to the right!")
            refreshTable()
        } else {
            print("got some other message")
        }
    }
    
    
}
