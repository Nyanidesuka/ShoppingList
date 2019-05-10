//
//  ItemController.swift
//  ShoppingList
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
//hello and welcome to my model controller.

class ItemController {
    
    //Alrighty so let's make that singleton, since we only want one item controller kicking around
    static let shared = ItemController()
    
    //This will be our alertController for the popup to add new items.
    let addItemPopup = UIAlertController(title: "Add a new Item:", message: nil, preferredStyle: .alert)
    
    //let's make that fetchboi
    var fetchController: NSFetchedResultsController<Item>
    
    //and then we init. Wherein we'll make this fetchboi actually work
    init(){
        //Step one: Gotta be able to tell the fetchboi what to fetch. For that, we need a request.
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //we set up a super basic one and now we can give it more to work with. Let's make a SortDescriptor first.
        let obtainedDescriptor = NSSortDescriptor(key: "obtained", ascending: true)
        //now that we have the SINGLE descriptor we want to sort our fetch by, we give it to the request. It takes an array.
        request.sortDescriptors = [obtainedDescriptor]
        //Now we hqve our request set up to we should have what we need to actually make this boi fetch.
        //Give it the request we made and then the conext we already have from the stack. Also a sectionnamekeypath but thats not crazy important rn
        let resultController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: "obtained", cacheName: nil)
        //then initialize our fetchController var to be a reference to the controller we created
        self.fetchController = resultController
        //THEN! We gotta actually fetch to load everything from the persistent store.
        do{
            try fetchController.performFetch()
        } catch {
            print("There ws an error loading from the persistent store. \(error.localizedDescription)")
        }
        //Now! We can set up our alert. We onlt wanna do this once. So we do it here.
        addItemPopup.addTextField { (newItemField) in
            newItemField.text = ""
        }
        //then we can add actions to it. Buttons.
        //button style default makes it normal blue.
        addItemPopup.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            //in here we can have it do some code when the user presses this action button. So we want to create a new item.
            //first we grab a ref to the text field, and theres only one. and we KNOW theres one.
            guard let nameField = self.addItemPopup.textFields?[0], let newName = nameField.text, !newName.isEmpty else {return}
            //after we make sure the name field isnt empty, we make a new item with a name that's the text they'd eneted.
            ItemController.shared.createItem(withName: newName)
            nameField.text = ""
        }))
        //That felt like a lot
        //still need to add a cancel action. .destructive to make it red text.
        addItemPopup.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (_) in
            guard let nameField = self.addItemPopup.textFields?[0]else {return}
            nameField.text = ""
        }))
    }
    
    //MARK: CRUD
    func createItem(withName name: String){
        //this actually is way easier with core data all we do is make a new instance
        let _ = Item(name: name)
        //and then we just save it
        saveToPersistentStore()
    }
    func deleteItem(target: Item){
        //so for this we can use a built-in method on core data entities
        target.managedObjectContext?.delete(target)
        //we ask the target what context it's in, then tell that context to delete the target.
        //could maybe also use CoreDataStack.context.delete(target)?
        saveToPersistentStore()
    }
    //this is KIND OF an update function so it belongs with the crud imo.
    func toggleObtained(forItem item: Item){
        item.obtained = !item.obtained
        saveToPersistentStore()
    }
    //We don't seem to use any other CRUD functions in this one.
    
    //MARK: Persistence
    //I'm just gonna define the save func now because im gonna use it in all the crud
    func saveToPersistentStore(){
        //so the save function for coredata can throw. A few ways we can handle it like a try? but i think do-try-catch is probably best practice?
        do{
            try CoreDataStack.context.save()
        } catch {
            print("There ws an error saving the context to the persistent container: \(error.localizedDescription)")
        }
    }
}
