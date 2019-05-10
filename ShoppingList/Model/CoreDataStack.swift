//
//  CoreDataStack.swift
//  ShoppingList
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
import CoreData

import CoreData
//ok lets set up the Core Data Stack
//We make it a class, i think, because it makes it easier to access. Coud be an enum or struct to be lighter?
class CoreDataStack{
    //so the stakc is gonna need a persistent container, where we'll keep everything. So here's one.
    //It's computed to give us the chance to define things more easily.
    static let container: NSPersistentContainer = {
        //we start by making an instance of NSPersistentContainer so we can build on it and eventually return it.
        //it has to have the name of our app EXACTLY.
        let persistentContainer = NSPersistentContainer(name: "ShoppingList")
        //Then we try to load the contents of the persistent store, if any. If there's an error, the completion handler gives us a chance to execute some code and passes us the error.
        persistentContainer.loadPersistentStores(completionHandler: { (_, error) in
            if let anError = error {
                //we just crash. EJECT!
                fatalError("There was an error loading from the persistent tore. \(anError)")
            }
        })
        //after all that setup is done (not even that much setup) we return this to set the class's container to be the instance we just built.
        return persistentContainer
    }()
    //And then down here, this is optional but it makes it less typing if we make a reference to the context with a static var. Just less typing later.
    static let context: NSManagedObjectContext = container.viewContext
}
//And thats it! The stack is ready to use.

