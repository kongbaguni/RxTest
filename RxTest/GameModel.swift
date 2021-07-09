//
//  GameModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/09.
//

import Foundation
import RealmSwift
class GameModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var timeStamp:Date = Date()
    let dices = MutableSet<DiceModel>()
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension GameModel {
    static func makeGame(diceNumbere:Int) {
        let game = GameModel()
        for _ in 1...diceNumbere {
            game.dices.insert(DiceModel.random)
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
