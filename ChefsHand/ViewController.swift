//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
import SwiftSoup

struct Recipe: Encodable {
    var ingredients: [String]
    var method: [Step]
    
    //TODO: investigate Codable protocol instead of conversion
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [String: Any]()
        dict["ingredients"] = self.ingredients
        
        let steps: [Step] = self.method
        var dictSteps: [String: Any] = [String: Any]()
        for step: Step in steps {
            dictSteps["instruction"] = step.instruction
            
            let cookingTimers: [CookingTimer] = step.cookingTimes
            var dictCookingTimers: [String: Int] = [String: Int]()
            for cookingTimer: CookingTimer in cookingTimers {
                dictCookingTimers["time"] = cookingTimer.time
                dictCookingTimers["timeDefStart"] = cookingTimer.timeDefStart
                dictCookingTimers["timeDefEnd"] = cookingTimer.timeDefEnd
            }
            dictSteps["cookingTimes"] = dictCookingTimers
        }
        dict["method"] = dictSteps
        
        return dict
    }
}

struct Step: Encodable {
    var instruction: String
    var cookingTimes: [CookingTimer]
}

struct CookingTimer: Encodable {
    let time: Int
    let timeDefStart: Int
    let timeDefEnd: Int
}

struct TasteRecipe: Decodable {
    var recipeInstructions: [String]
    var recipeIngredient: [String]
}

class ViewController: UIViewController {
    var session: WCSession?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    
    @IBAction func tapSendDataToWatch(_ sender: Any){
        let recipeUrl = urlField.text
        
        let recipe: Recipe? = createRecipe(from: recipeUrl)
        print("Got a potential recipe")
        
        if let validSession = self.session, let validRecipe = recipe, validSession.isReachable {
            let data: [String: Any] = ["recipe": validRecipe.dictionary as Any]
            validSession.sendMessage(data, replyHandler: nil, errorHandler: {(error) -> Void in print{":( error: \(error.localizedDescription)"}})
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
            steps.append(Step(instruction: instruction, cookingTimes: getCookingTimes(in: instruction)))
        }
        
        return Recipe(ingredients: ingredients, method: steps)
    }
    
    func getCookingTimes(in instruction: String) -> [CookingTimer] {
        var cookingTimers: [CookingTimer] = []
        
        do {
            let regex = try NSRegularExpression(pattern: #"[0-9]+ ?(h(ou)?r|min(ute)?|sec(ond)?)s?"#, options: []) //TODO: only integers
            let matches = regex.matches(in: instruction, options: [], range: NSRange(location: 0, length: instruction.count))
            
            for match in matches {
                let matchRange: NSRange = match.range(at: 0) // get the first match (the largest one)
                if let substringRange: Range = Range(matchRange, in: instruction) {
                    let cookingTimeString: String = String(instruction[substringRange])
                    let cookingTime = getCookingTimeInSeconds(of: cookingTimeString)
                    cookingTimers.append(CookingTimer(time: cookingTime, timeDefStart: matchRange.lowerBound, timeDefEnd: matchRange.upperBound))
                }
            }
        } catch {
            print(error)
        }
        
        return cookingTimers
    }
    
    func getCookingTimeInSeconds(of timeString: String) -> Int {
        let timeComponents: [String] = timeString.components(separatedBy: " ")
        let time: Int = Int(timeComponents[0])!
        
        switch timeComponents[1] {
        case let unit where unit.contains("h"):
            return time * 60 * 60
        case let unit where unit.contains("m"):
            return time * 60
        default:
            return time
        }
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

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

