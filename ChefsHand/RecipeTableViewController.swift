//
//  RecipeTableControllerTableViewController.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 12/8/21.
//

import UIKit
import CoreData

class RecipeTableViewController: UITableViewController {
    
    var recipes: [NSManagedObject] = []
    var numOfRows = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        tableView.register(RecipeTableCell.self, forCellReuseIdentifier: "recipeCellIdentifier")
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreRecipe")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            recipes = result as! [NSManagedObject]
            numOfRows = result.count
            print("Result: \(result)")
        } catch {
            print("Failed: \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecipeTableCell = tableView.dequeueReusableCell(withIdentifier: "recipeCellIdentifier") as! RecipeTableCell
        let recipe = self.recipes[indexPath.row]
        
        cell.updateCell(using: recipe)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class RecipeTableCell: UITableViewCell {
    @IBOutlet weak var recipeTitleLabel: UILabel!
    @IBOutlet weak var recipeLocationLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    
    func updateCell(using recipe: NSManagedObject) {
        self.recipeTitleLabel?.text = recipe.value(forKey: "name") as? String ?? "Unknown Recipe"
        self.recipeLocationLabel?.text = recipe.value(forKey: "location") as? String ?? "Unknown Location"
        if let imageData = recipe.value(forKey: "image") as? Data {
            self.recipeImage?.image = UIImage(data: imageData)
        }
    }
}
