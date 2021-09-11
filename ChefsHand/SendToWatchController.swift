//
//  ViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/7/21.
//

import UIKit
import WatchConnectivity
import RealmSwift

class SendToWatchController: UIViewController {
    var connectivityManager = WatchConnectivityManager.shared
    let realmManager = RealmManager.shared
    var realmResults: Results<RealmRecipe>?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var urlField: UITextField!
    @IBAction func tapSendDataToWatch(_ sender: Any){
        guard let urlString = urlField.text, let recipeUrl = URL(string: urlString) else {
            showErrorAlert("URL wasn't valid, check the URL and try again")
            return
        }
        do {
            let urlRecipe: URLRecipe = try URLRecipe(url: recipeUrl)
            let recipe: Recipe = urlRecipe.convertToTransferrableRecipe()
            let recipeMessage: [String: Any] = ["recipe": recipe.dictionary as Any]
            
            saveToDataStore(urlRecipe)
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
    
    func saveToDataStore(_ recipe: URLRecipe) {
        let realmRecipe = recipe.dbEncode()
        realmManager.create(realmRecipe)
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
        self.realmResults = realmManager.read(RealmRecipe.self)?.sorted(byKeyPath: "name")
        
        self.urlField.delegate = self
    }
}

extension SendToWatchController: PhoneConnectivityDelegate {
    func recievedMessage(session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?) {
        if let numRecipeNamesRequest = message["recipeNamesRequest"] as? Int, let recipes = self.realmResults {

            let index: Int = numRecipeNamesRequest < recipes.count ? numRecipeNamesRequest : recipes.count
            let recipeNames: [String] = recipes[..<index].map{$0.name}
            let recipeNamesMessage: [String: [String]] = ["recipeNamesResponse": recipeNames]

            guard let reply = replyHandler else {return}
            reply(recipeNamesMessage)
        }
        if let recipeName = message["recipeRequest"] as? String, let recipes = self.realmResults {
            guard let requestedRealmRecipe: RealmRecipe = recipes.first(where: {$0.name == recipeName}) else {return}

            let requestedRecipe: Recipe = requestedRealmRecipe.dbDecode()
            let requestedRecipeResponse: [String: Any] = ["recipeResponse": requestedRecipe.dictionary as Any]
            guard let reply = replyHandler else {return}
            reply(requestedRecipeResponse)
        }
    }
}

extension SendToWatchController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
