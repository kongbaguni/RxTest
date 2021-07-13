//
//  GameModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/09.
//

import Foundation
import RealmSwift
import UIKit

class GameModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var timeStamp:Date = Date()
    
    @objc dynamic var red:Float = .random(in: 0.0...0.5)
    @objc dynamic var green:Float = .random(in: 0.0...0.5)
    @objc dynamic var blue:Float = .random(in: 0.0...0.5)

    let dices = MutableSet<DiceModel>()
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension GameModel {
    var color:UIColor {
        .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
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
