//
//  RockTableViewController.swift
//  RockDock
//
//  Created by Stephen Buck on 9/2/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import UIKit

class RockTableViewController: UITableViewController {

    // MARK: Properties
    
    var rocks = [Rock]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // Load any saved rocks, otherwise load sample data.
        if let savedRocks = loadRocks() {
            rocks += savedRocks
        } else {
            loadSampleRocks()
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
            }
    
    func loadSampleRocks() {
        
        let owner = "DD6C5847-76ED-437D-934C-BEA65A6B96DA" //created 9/12/2016
        
        for i in 1...1 {
           
        let photo1 = UIImage(named: "rock1")!
            let rock1 = Rock(name: "Bumpeee\(i)", photo: photo1, rating: 4, owner: owner )!
        
        let photo2 = UIImage(named: "rock2")!
            let rock2 = Rock(name: "Lumpeee\(i)", photo: photo2, rating: 5, owner: owner)!
        
        let photo3 = UIImage(named: "rock3")!
            let rock3 = Rock(name: "Sunue\(i)", photo: photo3, rating: 3, owner: owner)!
        
        rocks += [rock1, rock2, rock3]
        }
        
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberofrowsinsection:\(rocks.count)")
        return rocks.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RockTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RockTableViewCell

        
        
        // Fetches the appropriate rock for the data source layout.
        let rock = rocks[indexPath.row]

        // Configure the cell...
        cell.nameLabel.text = rock.name
        cell.photoImageView.image = rock.photo
        cell.ratingControl.rating = rock.rating
        cell.ratingControl.updateButtonSelectionStates()
        //print ("rock.rating \(rock.rating)")
        //print ("cell.ratingControl.rating \(cell.ratingControl.rating)")
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete the row from the data source
            rocks.remove(at: indexPath.row)
            
            // Save the rocks.
            saveRocks()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowDetail" {
            let rockDetailViewController = segue.destination as! RockViewController
            // Get the cell that generated this segue.
            if let selectedRockCell = sender as? RockTableViewCell {
                let indexPath = tableView.indexPath(for: selectedRockCell)!
                let selectedRock = rocks[indexPath.row]
                rockDetailViewController.rock = selectedRock
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new rock.")
        }
    }
    
    
    @IBAction func unwindToRockList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? RockViewController, let rock = sourceViewController.rock {
        
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
            
                // Update an existing rock.
                rocks[selectedIndexPath.row] = rock
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
        } else {
            
            // Add a new rock.
            let newIndexPath = IndexPath(row: rocks.count, section: 0)
            rocks.append(rock)
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            
            // Save the rocks.
            saveRocks()
    }
    }
    
    // MARK: NSCoding
    func saveRocks() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(rocks, toFile: Rock.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save rocks...")
        }
    }
    
    func loadRocks() -> [Rock]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Rock.ArchiveURL.path) as? [Rock]
    }

}
