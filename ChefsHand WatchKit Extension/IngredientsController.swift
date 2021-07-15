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
    var isSelected: Bool = false
    
    //TODO: maybe use a click region?
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = ingredientsTable.rowController(at: rowIndex) as! IngredientsRowController
        
        if (isSelected) {
            isSelected = false
            selectedRow.ingredientGroup.setBackgroundColor(UIColor(white: 0.1, alpha: 0.5))
        } else {
            isSelected = true
            selectedRow.ingredientGroup.setBackgroundColor(UIColor(white: 0.33, alpha: 0.5))
        }
    }
    
    override func willActivate() {
        let ingredients: [String] = Recipe.shared.getRecipe().ingredients
        ingredientsTable.setNumberOfRows(ingredients.count, withRowType: "Ingredients Row")
        
        for (index, ingredient) in ingredients.enumerated() {
            let row = ingredientsTable.rowController(at: index) as! IngredientsRowController
            row.ingredientsLabel.setText(ingredient)
        }
    }
}
