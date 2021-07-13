//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
import SwiftSoup

struct Recipe {
    var ingredients: [String]
    var method: [Step]
}

struct Step {
    var instruction: String
    var cookingTimes: [CookingTimer]
}

struct CookingTimer {
    let time: Int
    let timeDefStart: String.Index
    let timeDefEnd: String.Index
}

struct TasteRecipe: Codable {
    var recipeInstructions: [String]
    var recipeIngredient: [String]
}

class ViewController: UIViewController {
    var session: WCSession?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    
    @IBAction func tapSendDataToWatch(_ sender: Any){
        let recipeUrl = urlField.text
        
        let steps: Recipe? = createRecipe(from: recipeUrl)
        
        
        if let validSession = self.session, validSession.isReachable {
            let data: [String: Any] = ["recipe": steps as Any]
            validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
    }
    
    func createRecipe(from urlString: String?) -> Recipe? {
        var tasteRecipe: TasteRecipe?
        guard let url = URL(string: urlString ?? "") else {
            showErrorAlert("URL wasn't valid, check the URL and try again")
            return nil
        }
        do {    
            let html: String = try String(contentsOf: url, encoding: .ascii)
            let decoder = JSONDecoder()
            
            let doc: Document = try SwiftSoup.parse(html)
            let recipeElement: Element = try doc.select("script[data-schema-entity=recipe]").first()!
            let recipeString: String = recipeElement.data()
            let recipeData: Data = recipeString.data(using: .utf8)!
            tasteRecipe = try decoder.decode(TasteRecipe.self, from: recipeData)
        } catch {
            print(error)
        }
        
        let ingredients = tasteRecipe!.recipeIngredient
        var steps: [Step] = []
        for instruction: String in tasteRecipe!.recipeInstructions {
            steps.append(Step(instruction: instruction, cookingTimes: getCookingTimes(of: instruction)))
        }
        
        return Recipe(ingredients: ingredients, method: steps)
    }
    
    func getCookingTimes(of instruction: String) -> [CookingTimer] {
        var cookingTimers: [CookingTimer] = []
        
        print("For ", instruction, ": ")
        
        do {
            let regex = try NSRegularExpression(pattern: #"[0-9]+ (h(ou)?rs?|min(ute)?s?|sec(ond)?s?)"#, options: [])
            let matches = regex.matches(in: instruction, options: [], range: NSRange(location: 0, length: instruction.count))
            guard let match = matches.first else {return []}
            
            for rangeIndex in 0..<match.numberOfRanges {
                let matchRange = match.range(at: rangeIndex)
                if let substringRange = Range(matchRange, in: instruction) {
                    print(instruction[substringRange])
                    let cookingTime: CookingTimer = CookingTimer(time: 999, timeDefStart: substringRange.lowerBound, timeDefEnd: substringRange.upperBound)
                }
            }
        } catch {
            print(error)
        }
        
        print("\n\n\n")
        
        return cookingTimers
    }
    
    func showErrorAlert(_ messsage: String) {
        let alert = UIAlertController(title: "Error", message: messsage, preferredStyle:   UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureWatchKitSession()
    }
    
    func configureWatchKitSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
}

//todo: make an extension for Recipie generics

extension ViewController: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session between watch and iPhone was deactivated")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]){
        print("got message: \(message)")
        DispatchQueue.main.async {
            if let value = message["watch"] as? String {
                self.label.text = value
            }
        }
    }
}


