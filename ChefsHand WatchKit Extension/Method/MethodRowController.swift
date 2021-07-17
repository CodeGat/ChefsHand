//
//  MethodRowController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 15/7/21.
//

import WatchKit

protocol TableCellButtonTappable {
    func buttonTapped(at index: Int, inRow row: Int)
}

class MethodRowController: NSObject {
    @IBOutlet weak var methodLabel: WKInterfaceLabel!
    @IBOutlet weak var separator: WKInterfaceSeparator!
    @IBOutlet weak var methodTimer: WKInterfaceTimer!
    @IBOutlet weak var timerBtn: WKInterfaceButton!
    @IBOutlet weak var otherTimersBtn: WKInterfaceButton!
    
    @IBAction func switchTimer() {
//        let timeInterval: Date =
//        self.methodTimer.setDate(<#T##date: Date##Date#>)
    }
    
    @IBAction func timerStart() {
        self.methodTimer.start()
    }
    
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
