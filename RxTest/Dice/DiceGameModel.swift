//
//  GameModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/09.
//

import Foundation
import RealmSwift
import UIKit

class DiceGameModel: GameModel {
    let dices = MutableSet<DiceModel>()
}

extension DiceGameModel {    
    
    static func makeGame(diceNumbere:Int, playerName:String) {
        let game = DiceGameModel()
        for _ in 1...diceNumbere {
            game.dices.insert(DiceModel.random)
            game.player = PlayerModel.makePlayer(name: playerName)
        }

        let realm = try! Realm()
        realm.beginWrite()
        realm.add(game)
        try! realm.commitWrite()
    }
    
    var dicesStrValue:String {
        var result:String = ""
        for dice in dices {
            if result.isEmpty == false {
                result += ","
            }
            result += "\(dice.number)"
        }
        return result
    }
    
    var sum:Int {
        return dices.sum(ofProperty: "number")
    }
    
    func delete() {
        let realm = try! Realm()
        realm.beginWrite()
        for dice in dices {
            realm.delete(dice)
        }
        realm.delete(self)
        try! realm.commitWrite()
    }
}
