//
//  EditableRecipeViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 30/12/21.
//

import UIKit

class EditableRecipeViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var ingredientField: UITextField!
    @IBOutlet weak var methodField: UITextField!
    
    var recipe: RealmRecipe?
    
    func configure(with recipe: RealmRecipe) {
        self.recipe = recipe
    }
    
    override func viewDidLoad() {
        titleField.text = recipe?.name
        ingredientField.text = extractIngredientsFromRecipe()
        methodField.text = extractMethodFromRecipe()
    }
    
    func extractIngredientsFromRecipe() -> String {
        var ingredients: String = ""
        
        self.recipe?.ingredients.forEach{ingredient in
            ingredients.append(ingredient.text + "\n")
        }
        
        return ingredients
    }
    
    func extractMethodFromRecipe() -> String {
        var method: String = ""
        
        self.recipe?.method.forEach{step in
            method.append(step.text + "\n")
        }
        
        return method
    }
}
