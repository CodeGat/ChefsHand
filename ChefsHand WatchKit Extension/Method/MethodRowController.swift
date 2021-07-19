//
//  MethodRowController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 15/7/21.
//

import WatchKit

class MethodRowController: NSObject {
    @IBOutlet weak var methodLabel: WKInterfaceLabel!
    @IBOutlet weak var methodGroup: WKInterfaceGroup!
    
    var step: Recipe.StructuredRecipe.Step? {
        didSet {
            guard let step = step else {return}
            self.methodLabel.setText(step.instruction)
        }
    }
}
