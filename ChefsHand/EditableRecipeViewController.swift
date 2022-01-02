//
//  EditableRecipeViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 30/12/21.
//

import UIKit

class EditableRecipeViewController: UIViewController {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var ingredientsInput: UITextView!
    @IBOutlet weak var methodInput: UITextView!
    
    var recipe: RealmRecipe?
    
    func configure(with recipe: RealmRecipe) {
        self.recipe = recipe
    }
    
    override func viewDidLoad() {
        self.titleField.text = recipe?.name
        self.ingredientsInput.text = extractIngredientsFromRecipe()
        self.methodInput.text = extractMethodFromRecipe()
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


extension UITextView {
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        self.resignFirstResponder()
    }
}
