//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
import SwiftSoup
import CoreData

class SendToWatchController: UIViewController {
    var connectivityHandler = WatchConnectivityManager.shared
    var context: NSManagedObjectContext?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBAction func tapSendDataToWatch(_ sender: Any){
        let recipeUrl = urlField.text
        let recipe: StructuredRecipe? = createRecipe(from: recipeUrl)
        
        if let validRecipe = recipe {
            
            saveToDataStore(validRecipe)
            
            let data: [String: Any] = ["recipe": validRecipe.dictionary as Any]
            
            print("About to send")
            
            connectivityHandler.sendMessage(message: data, replyHandler: nil, errorHandler: {error in
                print("In STWC there was an error sending the message: \(error)")
            })
            
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
        
        self.urlField.resignFirstResponder()
    }
    
    func saveToDataStore(_ recipe: StructuredRecipe) {
        guard let validContext = context else {
            fatalError("Context not found")
        }
        
        let _: NSManagedObject = recipe.convertToNSManagedObject(usingContext: validContext)
        
        do {
            try validContext.save()
        } catch {
            fatalError("Context failed to save! \(error)")
        }
    }
    
    func createRecipe(from urlString: String?) -> StructuredRecipe? {
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
        let recipeIngredients: [StructuredIngredient] = ingredients.map { StructuredIngredient(text: $0, isDone: false) }
        print(recipeIngredients)
        
        var steps: [StructuredStep] = []
        for instruction: String in tasteRecipe!.recipeInstructions {
            steps.append(StructuredStep(instruction: instruction, isDone: false, cookingTimes: getCookingTimes(in: instruction)))
        }
        
        return StructuredRecipe(name: tasteRecipeName, ingredients: recipeIngredients, method: steps)
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
                    let cookingTime: Int = getCookingTimeInSeconds(of: cookingTimeString)
                    let cookingTimer = CookingTimer(time: cookingTime, timeDefStart: matchRange.lowerBound, timeDefEnd: matchRange.upperBound)
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
        connectivityHandler.phoneDelegate = self
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        
        self.urlField.delegate = self
    }
    
    // MARK: do we need to move this to other controller?
//    func configureWatchKitSession() {
//        if WCSession.isSupported() {
//            session = WCSession.default
//            session?.delegate = self
//            session?.activate()
//        }
//    }
}

//extension SendToWatchController: WCSessionDelegate {
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("Session in SendToWatchController did become inactive")
//    }
//
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("Session in SendToWatchController did become deactivated")
//    }
//
//    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
//        print("Activation in SendToWatchController did complete with \(activationState)")
//    }
//
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//       if let numRecipeNamesRequest = message["recipeNamesRequest"] as? Int, let recipes: [CoreRecipe] = fetchedResultContainer.fetchedObjects {
//            let index: Int = numRecipeNamesRequest < recipes.count ? numRecipeNamesRequest : recipes.count
//            let recipeNames: [String] = recipes[..<index].map{$0.name!}
//            let recipeNamesMessage: [String: [String]] = ["recipeNamesResponse": recipeNames]
//            replyHandler(recipeNamesMessage)
//        }
//        print("message recieved in STWC")
//    }
//
//}

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
