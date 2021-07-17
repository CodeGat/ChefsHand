//
//  MethodController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 14/7/21.
//

import Foundation
import WatchKit

class MethodController: WKInterfaceController {
    @IBOutlet weak var methodTable: WKInterfaceTable!
    
    @IBAction func pushTimerScene() {
        pushController(withName: "Timers", context: Recipe.shared.getRecipe().method)
        
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = methodTable.rowController(at: rowIndex) as! MethodRowController
        print("tapped the rest of the stuff: \(selectedRow)")
        
    }
    
    override func willActivate() {
        let steps: [Recipe.StructuredRecipe.Step] = Recipe.shared.getRecipe().method
        methodTable.setNumberOfRows(steps.count, withRowType: "Method Row")
        
        for (index, step) in steps.enumerated() {
            let rowController  = methodTable.rowController(at: index) as! MethodRowController
            
            let recipe: Recipe.StructuredRecipe = Recipe.shared.getRecipe()
            let recipeRow: Recipe.StructuredRecipe.Step = recipe.method[index]
            
            let attributedString = NSMutableAttributedString(string: step.instruction)
            for cookingTimer in step.cookingTimes {
                let start: Int = cookingTimer.timeDefStart
                let length: Int = cookingTimer.timeDefEnd - start
                let range = NSRange(location: start, length: length)
                attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
            }
            rowController.methodLabel.setAttributedText(attributedString)
            
            if (recipeRow.cookingTimes.count > 0){
                rowController.methodTimer.setHidden(false)
                rowController.separator.setHidden(false)
                rowController.otherTimersBtn.setHidden(false)
                rowController.methodTimer.setDate(NSDate(timeIntervalSinceNow: TimeInterval(recipeRow.cookingTimes[0].time)) as Date)
            } else {
                rowController.methodTimer.setHidden(true)
                rowController.separator.setHidden(true)
                rowController.otherTimersBtn.setHidden(true)
            }
            
        }
    }
}
