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
    
    fileprivate var gameModel:GameModel? {
        if let dice = diceModel {
            let list = try! Realm().objects(GameModel.self).filter({ game in
                return game.dices.contains(dice)
            })
            return list.last
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
        backgroundColor = gameModel?.color
    }
}
