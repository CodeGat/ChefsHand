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
        
        
        
        self.urlField.delegate = self
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
