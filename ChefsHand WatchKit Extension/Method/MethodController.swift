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
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let selectedRow = methodTable.rowController(at: rowIndex) as! MethodRowController
        let selectedRowStep: Recipe.StructuredRecipe.Step = Recipe.shared.getRecipe().method[rowIndex]
        
        Recipe.shared.setRecipeStepIsDone(at: rowIndex, to: !selectedRowStep.isDone)
        setMethodRowVisuals(using: selectedRow, to: !selectedRowStep.isDone)
        if (rowIndex < methodTable.numberOfRows - 1 && !selectedRowStep.isDone) {
            methodTable.scrollToRow(at: rowIndex + 1)
        }
        
    }
    
    override func willActivate() {
        let steps: [Recipe.StructuredRecipe.Step] = Recipe.shared.getRecipe().method
        methodTable.setNumberOfRows(steps.count, withRowType: "Method Row")
        
        for (index, step) in steps.enumerated() {
            let rowController  = methodTable.rowController(at: index) as! MethodRowController
            
            let attributedString = NSMutableAttributedString(string: step.instruction)
            for cookingTimer in step.cookingTimes {
                let start: Int = cookingTimer.timeDefStart
                let length: Int = cookingTimer.timeDefEnd - start
                let range = NSRange(location: start, length: length)
                attributedString.addAttribute(.foregroundColor, value: UIColor.orange, range: range)
            }
            rowController.methodLabel.setAttributedText(attributedString)
        }
    }
    
    func setMethodRowVisuals(using rowController: MethodRowController, to isDone: Bool) {
        if (isDone) {
            rowController.methodGroup.setBackgroundColor(UIColor(white: 0.1, alpha: 0.5))
            rowController.methodLabel.setTextColor(UIColor(white: 1, alpha: 0.5))
        } else {
            rowController.methodGroup.setBackgroundColor(UIColor(white: 0.32, alpha: 0.5))
            rowController.methodLabel.setTextColor(UIColor(white: 1, alpha: 1))
        }
    }
}
