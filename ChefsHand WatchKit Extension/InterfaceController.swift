//
//  InterfaceController.swift
//  ChefsHand WatchKit Extension
//
//  Created by Tommy Gatti on 6/7/21.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController {
    
    struct Recipe: Decodable {
        var ingredients: [String]
        var method: [Step]
    }

    struct Step: Decodable {
        var instruction: String
        var cookingTimes: [CookingTimer]
    }

    struct CookingTimer: Decodable {
        let time: Int
        let timeDefStart: Int
        let timeDefEnd: Int
    }

    @IBOutlet weak var label: WKInterfaceLabel!
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    @IBAction func tapSendDataToiPhone() {
        let data: [String: Any] = ["watch": "This is from my watch!" as String]
        session.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Activation state is: \(activationState)")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("Watch got a response!")
        do {
            let recipe = try Recipe(from: message["recipe"] as Any)
            self.label.setText(recipe.ingredients[0])
        } catch {
            print(error)
        }
    }
}

extension Decodable {
  init(from: Any) throws {
    let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
    let decoder = JSONDecoder()
    self = try decoder.decode(Self.self, from: data)
  }
}
