//
//  ShoppingListTableViewController.swift
//  ShoppingList
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
class ShoppingListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ItemController.shared.fetchController.delegate = self
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //we want one section for each section in our fetchController's fetch. Remember it sorts by the only descriptor we defined. It's optional so we coalesce to 0.
        return ItemController.shared.fetchController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //so for this one, the function passes us  section to look in already. So we can just use that and then ask how many objects are in tht section of the fetch results and viola
        return ItemController.shared.fetchController.sections?[section].numberOfObjects ?? 0
    }
    //set the titles of each section, if there's sections.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if ItemController.shared.fetchController.sections?.count != 1{
            return section == 0 ? "I want it" : "I got it"
        } else {
            //so if there's only one section we wanna title it based on whether or not that section is for obtained or unobtained items
            //just grab the first cell
            let targetIndex = IndexPath(row: 0, section: 0)
            //if theres nothing in the section why name it anyway
            let targetItem = ItemController.shared.fetchController.object(at: targetIndex)
            return targetItem.obtained ? "I got it" : "I want it"
        }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {return UITableViewCell()}
        //this will be easier than last time
        cell.delegate = self
        let cellItem = ItemController.shared.fetchController.object(at: indexPath)
        cell.update(withItem: cellItem)
        //THATS IT, i you do anything else youll break it again
        return cell
     }
 
    
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //becuse the delegate functions down below will actually handle removing rows, we only need this one to remove items from the context.
            let targetItem = ItemController.shared.fetchController.object(at: indexPath)
            ItemController.shared.deleteItem(target: targetItem)
        }
     }
 
    
    //MARK: Alert Popup
    //Putting this in the ViewController because I feel like if i have the viewcontroller call the itemcontroller to create the item, thats still good MVC?
    func showPopup(){
        //so the itemController has this alert controller instance. We can access it here and show it
        let popup = ItemController.shared.addItemPopup //make a shorthand
        self.present(popup, animated: true, completion: nil)
    }
    
    //MARK: IBActions
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        showPopup()
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

//Get that protocol bb
//We have to do this so edits from the table view can effect the fetch results.
extension ShoppingListTableViewController: NSFetchedResultsControllerDelegate{
    //this calls when the content of the fetchcontroller will change
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //and we have to tell the tableview its aboutt to get edited
        tableView.beginUpdates()
    }
    //This happens when the changes are done being done
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //And again we have to let the table view know the editing is done.
        tableView.endUpdates()
    }
    //So this one runs any time the contents of the results controller change. And it tells us what type of change happens, and we can switch on that.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .delete:
            guard let indexPath = indexPath else {return}
            //This function actually handles deleting the rows appropriately, so our tableview data source function doesnt have to
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else {return}
            tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    //This function runs when the number of sections in the results changes. And it'll do that a lot.
    //This'll add or remove sections to the table view to keep up.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
}
//Add the extension to be the cell's delegate. The Cellegate, if you will.
extension ShoppingListTableViewController: ItemTableViewCellDelegate{
    func cellButtonTapped(sender: ItemTableViewCell) {
        //first up, grab the index e're working with. Base it on who had us call this.
        guard let index = tableView.indexPath(for: sender) else {return}
        //then figure out what item we're dealing with
        let targetItem = ItemController.shared.fetchController.object(at: index)
        //now do stuff to that object
        ItemController.shared.toggleObtained(forItem: targetItem)
        //and finally update the cell
        sender.update(withItem: targetItem)
        //this handles the button. Which is where iw as stuck before.
    }
    func stepperChanged(sender: ItemTableViewCell){
        guard let index = tableView.indexPath(for: sender) else {return}
        let targetItem = ItemController.shared.fetchController.object(at: index)
        targetItem.quantity = Int16(Int(sender.quantityStepper.value))
        sender.update(withItem: targetItem)
    }
}
