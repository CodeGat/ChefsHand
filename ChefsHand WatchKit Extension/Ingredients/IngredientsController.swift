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

    //TODO: maybe use a click region?
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = ingredientsTable.rowController(at: rowIndex) as! IngredientsRowController
        let selectedRowIngredient: Recipe.StructuredRecipe.Ingredient = Recipe.shared.getRecipe().ingredients[rowIndex]
        
        Recipe.shared.setRecipeIngredientIsDone(at: rowIndex, to: !selectedRowIngredient.isDone)
        
        changeIngredientRowVisual(using: selectedRow, to: !selectedRowIngredient.isDone)
    }
    
    override func willActivate() {
        let ingredients: [Recipe.StructuredRecipe.Ingredient] = Recipe.shared.getRecipe().ingredients
        ingredientsTable.setNumberOfRows(ingredients.count, withRowType: "Ingredients Row")
        
        for (index, ingredient) in ingredients.enumerated() {
            let rowController  = ingredientsTable.rowController(at: index) as! IngredientsRowController
            let recipe: Recipe.StructuredRecipe = Recipe.shared.getRecipe()
            let recipeRow: Recipe.StructuredRecipe.Ingredient = recipe.ingredients[index]
            
            rowController.ingredientsLabel.setText(ingredient.text)
            changeIngredientRowVisual(using: rowController, to: recipeRow.isDone)
        }
    }
    
    func changeIngredientRowVisual(using rowController: IngredientsRowController, to isDone: Bool) {
        if (isDone) {
            rowController.ingredientGroup.setBackgroundColor(UIColor(white: 0.1, alpha: 0.5))
            rowController.doneImage.setImage(UIImage(systemName: "checkmark.circle"))
            rowController.ingredientsLabel.setTextColor(UIColor(white: 1, alpha: 0.5))
        } else {
            rowController.ingredientGroup.setBackgroundColor(UIColor(white: 0.32, alpha: 0.5))
            rowController.doneImage.setImage(UIImage(systemName: "circle"))
            rowController.ingredientsLabel.setTextColor(UIColor(white: 1, alpha: 1))
        }
    }
}
