//
//  RecipeRowController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 20/7/21.
//

import WatchKit

class RecipeRowController: NSObject {
    @IBOutlet weak var recipeLabel: WKInterfaceLabel!
    
    enum RowType {
        case cached, phone, more
    }
    
    var name: String? {
        didSet {
            guard let name = name else {return}
            recipeLabel.setText(name)
        }
    }
    var type: RowType?
}
