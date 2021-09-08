//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
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
            let recipe: Recipe = try urlRecipe.convert()
            let recipeMessage: [String: Any] = ["recipe": recipe.dictionary as Any]
            
            saveToDataStore(recipe)
            connectivityManager.sendMessage(message: recipeMessage, replyHandler: nil, errorHandler: {error in
                print("In STWC there was an error sending the message: \(error)")
            })
        } catch let error as RecipeError {
            showErrorAlert(error.description)
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
    
    func showErrorAlert(_ messsage: String) {
        let alert = UIAlertController(title: "Error", message: messsage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connectivityManager.phoneDelegate = self
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        self.context = appDelegate.persistentContainer.viewContext
        
        self.urlField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Preparing for a segue (STWC)")
        if let nextVC = segue.destination as? RecipeTableViewController {
            print("Context sent to RTVC via STWC")
            nextVC.context = self.context
        }
    }
}

extension Recipe: NSManagedObjectCodable {
    static func convert(using coreRecipeObject: NSManagedObject) -> Recipe {
        let coreRecipe = coreRecipeObject as! CoreRecipe
        
        let coreIngredients = coreRecipe.hasIngredient?.array as! [CoreIngredient]
        
        let ingredients: [Ingredient] = coreIngredients.map{Ingredient(text: $0.text!, isDone: $0.isDone)}
        
        let coreSteps = coreRecipe.hasStep?.array as! [CoreStep]
        var steps = [Step]()
        for coreStep in coreSteps {
            let coreCookingTimes = coreStep.hasCookingTime?.array as! [CoreCookingTime]
            let cookingTimes: [CookingTime] = coreCookingTimes.map{CookingTime(time: Int($0.time), timeDefStart: Int($0.timeDefStart), timeDefEnd: Int($0.timeDefEnd))}
            
            steps.append(Step(text: coreStep.text!, isDone: coreStep.isDone, cookingTimes: cookingTimes))
        }
        
        return Recipe(name: coreRecipe.name!, location: coreRecipe.location, url: coreRecipe.url, image: coreRecipe.image, ingredients: ingredients, method: steps)
    }
    
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
