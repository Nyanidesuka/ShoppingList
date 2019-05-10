//
//  ItemTableViewCell.swift
//  ShoppingList
//
//  Created by Haley Jones on 5/10/19.
//  Copyright © 2019 HaleyJones. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    //for good MVC, we need this guy to have a delegate. That way it doesnt edit any data or anything. It just asks its boss.
    var delegate: ItemTableViewCellDelegate?
    
    //MARK: Outlets
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: Actions
    @IBAction func checkButtonPressed(_ sender: Any) {
        //if there's no delegate, dip. But there always should be.
        guard let boss = delegate else {return}
        //call the boss, my button was tapped. Use self to let them know which cell is reporting.
        boss.cellButtonTapped(sender: self)
        print("button Tapped")
    }
    @IBAction func stepperChanged(_ sender: UIStepper) {
        guard let boss = delegate else {return}
        boss.stepperChanged(sender: self)
    }
    
    
    //we can consolidate all the code that updates the cell with info from an item here so we can call it more easily later on.
    func update(withItem item: Item){
        //this function passes in an item and based on that we do these:
        itemLabel.text = item.name ?? ""
        quantityStepper.value = Double(item.quantity)
        quantityLabel.text = String(item.quantity)
        updateButton(withBool: item.obtained)
        ItemController.shared.saveToPersistentStore()
    }
    
    //function to make the button look right
    func updateButton(withBool: Bool){
        checkButton.setImage(UIImage(named: withBool ? "checkboxFull" : "checkboxEmpty"), for: .normal)
    }
}

//right here we make a protocol to define what a delegate for this cell should have
protocol ItemTableViewCellDelegate{
    func cellButtonTapped(sender: ItemTableViewCell)
    func stepperChanged(sender: ItemTableViewCell)
}
