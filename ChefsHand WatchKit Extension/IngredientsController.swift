//
//  IngredientsController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import Foundation
import WatchKit

class IngredientsController: WKInterfaceController {
    @IBOutlet weak var ingredientsTable: WKInterfaceTable!
    
    override func willActivate() {
        let ingredients: [String] = Recipe.shared.getRecipe().ingredients
        ingredientsTable.setNumberOfRows(ingredients.count, withRowType: "Ingredients Row")
        
        for (index, ingredient) in ingredients.enumerated() {
            let row = ingredientsTable.rowController(at: index) as! IngredientsRowController
            row.ingredientsLabel.setText(ingredient)
        }
    }
}
