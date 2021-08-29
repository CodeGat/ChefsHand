//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
//import SwiftSoup
import CoreData

class SendToWatchController: UIViewController {
    var connectivityManager = WatchConnectivityManager.shared
    var context: NSManagedObjectContext?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBAction func tapSendDataToWatch(_ sender: Any){
        guard let urlString = urlField.text, let recipeUrl = URL(string: urlString) else {
            showErrorAlert("URL wasn't valid, check the URL and try again")
            return
        }
        let urlRecipe: URLRecipe = URLRecipe(url: recipeUrl)
        do {
            let recipe = try urlRecipe.convert()
            let recipeMessage: [String: Any] = ["recipe": recipe.dictionary as Any]
            
            print(recipeMessage)
            
            saveToDataStore(recipe)
            connectivityManager.sendMessage(message: recipeMessage, replyHandler: nil, errorHandler: {error in
                print("In STWC there was an error sending the message: \(error)")
            })
        } catch RecipeError.unknownHostError {
            showErrorAlert(description)
        } catch RecipeError.tasteRecipeUnconvertableError {
            showErrorAlert(description)
        } catch RecipeError.genericRecipeUnconvertableError(host: let host) {
            showErrorAlert("From \(host): " + description)
        } catch {
            showErrorAlert(error.localizedDescription)
        }
        
        self.urlField.resignFirstResponder()
            //MARK: if not reachable, send application context
//            if (validSession.isReachable){
//                validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
//            } else {
//                do {
//                    try validSession.updateApplicationContext(data)
//                } catch {
//                    print("Something happened when updating application context: \(error.localizedDescription)")
//                }
//
//            }
    }
    
    func saveToDataStore(_ recipe: Recipe) {
        guard let validContext = context else {
            fatalError("Context not found")
        }
        
        let _: NSManagedObject = recipe.convert(given: validContext)
        
        do {
            try validContext.save()
        } catch {
            fatalError("Context failed to save! \(error)")
        }
    }
    
    func getCookingTimes(in instruction: String) -> [CookingTime] {
        var cookingTimers = [CookingTime]()
        
        do {
            let regex = try NSRegularExpression(pattern: #"[0-9]+ ?(h(ou)?r|min(ute)?|sec(ond)?)s?"#, options: []) //TODO: only integers
            let matches = regex.matches(in: instruction, options: [], range: NSRange(location: 0, length: instruction.count))
            
            for match in matches {
                let matchRange: NSRange = match.range(at: 0) // get the first match (the largest one)
                if let substringRange: Range = Range(matchRange, in: instruction) {
                    let cookingTimeString: String = String(instruction[substringRange])
                    let cookingTime: Int = getCookingTimeInSeconds(of: cookingTimeString)
                    let cookingTimer = CookingTime(time: cookingTime, timeDefStart: matchRange.lowerBound, timeDefEnd: matchRange.upperBound)
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
        let alert = UIAlertController(title: "Error", message: messsage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connectivityManager.phoneDelegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        
        self.urlField.delegate = self
    }
}

extension Recipe: NSManagedObjectConvertable {
    func convert(given context: NSManagedObjectContext) -> NSManagedObject {
        let recipeObject = CoreRecipe.init(context: context)
        recipeObject.name = self.name
        recipeObject.location = self.location
        recipeObject.image = self.image
        
        for ingredient in self.ingredients {
            let ingredientObject = CoreIngredient(context: context)
            ingredientObject.text = ingredient.text
            ingredientObject.isDone = ingredient.isDone
            recipeObject.addToHasIngredient(ingredientObject)
        }
        
        for step in self.method {
            let stepObject = CoreStep(context: context)
            stepObject.text = step.text
            stepObject.isDone = step.isDone
            
            for cookingTime in step.cookingTimes {
                let cookingTimeObject = CoreCookingTime(context: context)
                cookingTimeObject.time = Int32(cookingTime.time)
                cookingTimeObject.timeDefStart = Int32(cookingTime.timeDefStart)
                cookingTimeObject.timeDefEnd = Int32(cookingTime.timeDefEnd)
                stepObject.addToHasCookingTime(cookingTimeObject)
            }
            recipeObject.addToHasStep(stepObject)
        }
        
        return recipeObject
    }
}

//todo: make an extension for Recipie generics
extension SendToWatchController: PhoneConnectivityDelegate {
    func recievedMessage(session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?) {
        print("STWC: Got message from WCM! - not doing anything with it.")
    }
}

extension SendToWatchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
