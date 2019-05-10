//
//  Item.swift
//  ShoppingList
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import Foundation
//made a coredata entity called item, gave it some attributes. Now we can use an extension and convenience init to make it more workable
extension Item{
    
    //gonna give it a quantity propery later
    
    convenience init(name: String){
        //every item we put on our list is gonna start as not obtained so we can always initialize them that way.
        //I cn do that by setting a defult value in the CoreData model.
        self.init(context: CoreDataStack.context)
        self.name = name
        self.quantity = 1
    }
}
