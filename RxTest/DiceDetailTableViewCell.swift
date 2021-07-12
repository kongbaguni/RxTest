//
//  DiceDetailTableViewCell.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/12.
//

import UIKit
import RealmSwift

class DiceDetailTableViewCell: UITableViewCell {

    var diceId:Int? = nil
    
    fileprivate var diceModel:DiceModel? {
        if let id = diceId {
            return try! Realm().object(ofType: DiceModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var diceImageView: UIImageView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let dice = diceModel else {
            return
        }
        
        titleLabel.text = "\(dice.timeStamp)"
        diceImageView.image = dice.image
    }
}
