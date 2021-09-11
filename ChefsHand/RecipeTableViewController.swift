//
//  RecipeTableControllerTableViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 12/8/21.
//

import UIKit
import RealmSwift
import WatchConnectivity

class RecipeTableViewController: UITableViewController {
    var realmHandler = RealmManager.shared
    var connectivityHandler = WatchConnectivityManager.shared
    var realmResults: Results<RealmRecipe>?
    var realmToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        connectivityHandler.phoneDelegate = self
        
        self.realmResults = realmHandler.read(RealmRecipe.self)?.sorted(byKeyPath: "name")
        self.realmToken = realmResults?.observe { change in
            switch(change){
            case .initial:
                self.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map{ IndexPath(row: $0, section: 0)}, with: .fade)
                self.tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 0)}, with: .fade)
                self.tableView.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0)}, with: .fade)
                self.tableView.endUpdates()
            case .error(let error):
                print(error)
            }
        }

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Downloads"
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipes = realmHandler.read(RealmRecipe.self) else {fatalError("Couldn't read RealmRecipes")}
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecipeTableCell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeTableCell
        print(indexPath.debugDescription)
        let recipe = realmHandler.read(RealmRecipe.self, at: indexPath.row)!
        cell.updateInfo(using: recipe)

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            realmHandler.delete(RealmRecipe.self, at: indexPath.row)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RecipeTableViewController: PhoneConnectivityDelegate {
    func recievedMessage(session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?) {
        //handle msg
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

class RecipeTableCell: UITableViewCell {
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeLocationLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    
    func updateInfo(using recipe: RealmRecipe) {
        self.recipeTitleLabel?.text = recipe.name
        self.recipeLocationLabel?.text = recipe.location
        if let imageData = recipe.image {
            self.recipeImage?.image = UIImage(data: imageData)
        }
    }
}
