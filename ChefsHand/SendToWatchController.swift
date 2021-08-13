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
    var name: String
    var ingredients: [Ingredient]
    var method: [Step]
    
    struct Ingredient: Encodable {
        var text: String
        var isDone: Bool
    }
    
    struct Step: Encodable {
        var instruction: String
        var isDone: Bool
        var cookingTimes: [CookingTimer]
    }
    
    struct CookingTimer: Encodable {
        let time: Int
        let timeDefStart: Int
        let timeDefEnd: Int
    }
}

struct TasteRecipe: Decodable {
    var recipeInstructions: [String]
    var recipeIngredient: [String]
}

class SendToWatchController: UIViewController {
    var session: WCSession?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBAction func tapSendDataToWatch(_ sender: Any){
        let recipeUrl = urlField.text
        
        let recipe: Recipe? = createRecipe(from: recipeUrl)
        
        if let validSession = self.session, let validRecipe = recipe {
            let data: [String: Any] = ["recipe": validRecipe.dictionary as Any]
            if (validSession.isReachable){
                validSession.sendMessage(data, replyHandler: nil, errorHandler: {(error) -> Void in print{":( error: \(error.localizedDescription)"}})
            } else {
                do {
                    try validSession.updateApplicationContext(data)
                } catch {
                    print("Something happened when updating application context: \(error.localizedDescription)")
                }
                
            }
        }
    }
    
    func createRecipe(from urlString: String?) -> Recipe? {
        var tasteRecipeName: String = "Recipe"
        var tasteRecipe: TasteRecipe?
        
        guard let url = URL(string: urlString ?? "") else {
            showErrorAlert("URL wasn't valid, check the URL and try again")
            return nil
        }
        do {
            let html: String = try String(contentsOf: url, encoding: .ascii)
            let decoder = JSONDecoder()
            let doc: Document = try SwiftSoup.parse(html)
            
            let nameElement: Element = try doc.select("title").first()!
            tasteRecipeName = try nameElement.text()
            
            let recipeElement: Element = try doc.select("script[data-schema-entity=recipe]").first()!
            let recipeString: String = recipeElement.data()
            let recipeData: Data = recipeString.data(using: .utf8)!
            tasteRecipe = try decoder.decode(TasteRecipe.self, from: recipeData)
        } catch {
            print(error)
        }
        
        let ingredients: [String] = tasteRecipe!.recipeIngredient
        let recipeIngredients: [Recipe.Ingredient] = ingredients.map { Recipe.Ingredient(text: $0, isDone: false) }
        print(recipeIngredients)
        
        var steps: [Recipe.Step] = []
        for instruction: String in tasteRecipe!.recipeInstructions {
            steps.append(Recipe.Step(instruction: instruction, isDone: false, cookingTimes: getCookingTimes(in: instruction)))
        }
        
        return Recipe(name: tasteRecipeName, ingredients: recipeIngredients, method: steps)
    }
    
    func getCookingTimes(in instruction: String) -> [Recipe.CookingTimer] {
        var cookingTimers: [Recipe.CookingTimer] = []
        
        do {
            let regex = try NSRegularExpression(pattern: #"[0-9]+ ?(h(ou)?r|min(ute)?|sec(ond)?)s?"#, options: []) //TODO: only integers
            let matches = regex.matches(in: instruction, options: [], range: NSRange(location: 0, length: instruction.count))
            
            for match in matches {
                let matchRange: NSRange = match.range(at: 0) // get the first match (the largest one)
                if let substringRange: Range = Range(matchRange, in: instruction) {
                    let cookingTimeString: String = String(instruction[substringRange])
                    let cookingTime: Int = getCookingTimeInSeconds(of: cookingTimeString)
                    let cookingTimer = Recipe.CookingTimer(time: cookingTime, timeDefStart: matchRange.lowerBound, timeDefEnd: matchRange.upperBound)
                    cookingTimers.append(cookingTimer)
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

extension SendToWatchController: WCSessionDelegate {
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
