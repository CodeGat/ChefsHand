//
//  RecipeTableControllerTableViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 12/8/21.
//

import UIKit
import CoreData
import WatchConnectivity

class RecipeTableViewController: UITableViewController {
    fileprivate lazy var fetchedResultContainer: NSFetchedResultsController<CoreRecipe> = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CoreRecipe> = CoreRecipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    var connectivitySession = WatchConnectivityManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = "Downloads"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        do {
            try fetchedResultContainer.performFetch()
        } catch {
            fatalError("Failed to fetch recipes")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            try context.save()
        } catch {
            fatalError("Failed to save")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipes = fetchedResultContainer.fetchedObjects else {return 0}
        return recipes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecipeTableCell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as! RecipeTableCell
        
        cell.updateInfo(using: fetchedResultContainer, at: indexPath)

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let quoteToDelete = fetchedResultContainer.object(at: indexPath)
            quoteToDelete.managedObjectContext?.delete(quoteToDelete)
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

extension RecipeTableViewController: NSFetchedResultsControllerDelegate  {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type){
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableCell
                cell.updateInfo(using: fetchedResultContainer, at: indexPath)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
}

extension RecipeTableViewController: PhoneConnectivityDelegate {
    func recievedMessage(session: WCSession, message: [String : Any], replyHandler: (([String : Any]) -> Void)?) {
        //handle msg
        print("message recieved in RTVC")
        if let numRecipeNamesRequest = message["recipeNamesRequest"] as? Int, let recipes: [CoreRecipe] = fetchedResultContainer.fetchedObjects {
            let index: Int = numRecipeNamesRequest < recipes.count ? numRecipeNamesRequest : recipes.count
            let recipeNames: [String] = recipes[..<index].map{$0.name!}
            let recipeNamesMessage: [String: [String]] = ["recipeNamesResponse": recipeNames]
            
            guard let reply = replyHandler else {return}
            reply(recipeNamesMessage)
        }
    }
}

class RecipeTableCell: UITableViewCell {
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeLocationLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    
    func updateInfo(using controller: NSFetchedResultsController<CoreRecipe>, at indexPath: IndexPath) {
        let recipe = controller.object(at: indexPath)
        
        self.recipeTitleLabel?.text = recipe.name ?? "Unknown Recipe"
        self.recipeLocationLabel?.text = recipe.location ?? "Unknown Location"
        if let imageData = recipe.image {
            self.recipeImage?.image = UIImage(data: imageData)
        }
    }
}
