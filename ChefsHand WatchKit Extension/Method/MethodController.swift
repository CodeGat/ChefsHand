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
        
    }
    
    override func willActivate() {
        let steps: [Recipe.StructuredRecipe.Step] = Recipe.shared.getRecipe().method
        methodTable.setNumberOfRows(steps.count, withRowType: "Method Row")
        
        for (index, step) in steps.enumerated() {
            let rowController  = methodTable.rowController(at: index) as! MethodRowController
            let recipe: Recipe.StructuredRecipe = Recipe.shared.getRecipe()
            let recipeRow: Recipe.StructuredRecipe.Step = recipe.method[index]
            
            rowController.methodLabel.setText(step.instruction)
            
            if (recipeRow.cookingTimes.count > 0){
                rowController.methodTimer.setDate(NSDate(timeIntervalSinceNow: TimeInterval(recipeRow.cookingTimes[0].time)) as Date)
            }
            
        }
    }
}
