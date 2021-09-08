//
//  TabMenuController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 6/9/21.
//

import UIKit
import CoreData

class TabMenuController: UITabBarController {
    var context: NSManagedObjectContext?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Couldn't find AppDelegate in TabMenuController -> Couldn't instantiate CoreData")
        }
        self.context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("Preparing for a segue...")
        if let nextVC = segue.destination as? SendToWatchController, let validContext = context {
            print("sent context to STWC")
            nextVC.context = validContext
        }
        if let nextVC = segue.destination as? RecipeTableViewController, let validContext = context {
            print("sent context to RTVC")
            nextVC.context = validContext
        }
        print("finished prepare")
    }

}
