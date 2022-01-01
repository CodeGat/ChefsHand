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
    var realm: Realm?
    var connectivityHandler = WatchConnectivityManager.shared
    var realmResults: Results<RealmRecipe>?
    var realmToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        connectivityHandler.phoneDelegate = self
        
        self.realm = try! Realm()
        
        self.realmResults = realm?.objects(RealmRecipe.self).sorted(byKeyPath: "name")
        self.realmToken = realmResults?.observe { change in //MARK: Should I use the results..?
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEditableRecipeSegue",
           let destination = segue.destination as? EditableRecipeViewController,
           let cell = sender as? RecipeTableCell,
           let cellIx = tableView.indexPath(for: cell),
           let recipe: RealmRecipe = (realmResults?.objects(at: IndexSet(integer: cellIx.row))[0]) {
            destination.navigationItem.title = "Editing: " + recipe.name
            destination.configure(with: recipe)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipes = self.realmResults else {fatalError("Couldn't read RealmRecipes")}
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecipeTableCell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeTableCell
        print("cell is: \(cell.primaryKey?.debugDescription ?? "nothing")")
        let recipe: RealmRecipe = (realmResults?.objects(at: IndexSet(integer: indexPath.row))[0])!
        //let recipe = (realm?.object(ofType: RealmRecipe.self, forPrimaryKey: cell.primaryKey))! //MARK: If first then cell won't have the id!
        cell.updateInfo(using: recipe)

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let cell: RecipeTableCell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeTableCell
            
            print(cell.primaryKey?.description)
            
            try! self.realm?.write{
                let recipeToBeDeleted: RealmRecipe = (self.realm?.object(ofType: RealmRecipe.self, forPrimaryKey: cell.primaryKey))!
                realm?.delete(recipeToBeDeleted)
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
        let connectivityRealm = try! Realm()
        let recipes = connectivityRealm.objects(RealmRecipe.self)
        
        if let numRecipeNamesRequest = message["recipeNamesRequest"] as? Int {
            let index: Int = numRecipeNamesRequest < recipes.count ? numRecipeNamesRequest : recipes.count
            let recipeNames: [String] = recipes[..<index].map{$0.name}
            let recipeNamesMessage: [String: [String]] = ["recipeNamesResponse": recipeNames]
            
            guard let reply = replyHandler else {return}
            reply(recipeNamesMessage)
        }
        if let recipeName = message["recipeRequest"] as? String {
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
    var primaryKey: ObjectId!
    
    func updateInfo(using recipe: RealmRecipe) {
        self.primaryKey = recipe._id
        self.recipeTitleLabel?.text = recipe.name
        self.recipeLocationLabel?.text = recipe.location
        if let imageData = recipe.image {
            self.recipeImage?.image = UIImage(data: imageData)
        }
    }
}
