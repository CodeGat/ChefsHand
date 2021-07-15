//
//  MethodRowController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 15/7/21.
//

import WatchKit

class MethodRowController: NSObject {
    @IBOutlet weak var methodLabel: WKInterfaceLabel!
    @IBOutlet weak var separator: WKInterfaceSeparator!
    @IBOutlet weak var methodTimer: WKInterfaceTimer!
    
    @IBAction func handleLongPress(_ sender: Any) {
        print("From MethodRowController, ", sender)
    }
    @IBOutlet weak var longPressToTimers: WKLongPressGestureRecognizer!
    var step: Recipe.StructuredRecipe.Step? {
        didSet {
            guard let step = step else {return}
            self.methodLabel.setText(step.instruction)
        }
    }
    
    var cookingTimer: Recipe.StructuredRecipe.CookingTimer? {
        didSet {
            guard let cookingTimer = cookingTimer else {return}
            self.methodTimer.setDate(NSDate(timeIntervalSinceNow: TimeInterval(cookingTimer.time)) as Date)
        }
    }
}
