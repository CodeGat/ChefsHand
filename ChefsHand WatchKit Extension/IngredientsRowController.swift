//
//  IngredientsRowController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import WatchKit

class IngredientsRowController: NSObject {
    @IBOutlet weak var ingredientsLabel: WKInterfaceLabel!
    @IBOutlet weak var ingredientGroup: WKInterfaceGroup!
    
    var ingredient: String? {
        didSet {
            guard let ingredient = ingredient else {return}
            self.ingredientsLabel.setText(ingredient)
        }
    }
}
