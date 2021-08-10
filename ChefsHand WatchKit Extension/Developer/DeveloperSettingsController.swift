//
//  DeveloperSettingsInterfaceController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 10/8/21.
//

import WatchKit
import Foundation


class DeveloperSettingsController: WKInterfaceController {
    
    let defaults = UserDefaults.standard
    
    @IBAction func resetUserDefaults() {
        defaults.removeObject(forKey: "recipe")
    }
    
    @IBAction func dumpUserDefaults() {
        print(defaults.object(forKey: "recipe") ?? "none")
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
