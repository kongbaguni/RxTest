//
//  CardDeckModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/14.
//

import Foundation
import RealmSwift
class CardDeckModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var timeStamp:Date = Date()
    
    @objc dynamic var red:Float = .random(in: 0.0...0.5)
    @objc dynamic var green:Float = .random(in: 0.0...0.5)
    @objc dynamic var blue:Float = .random(in: 0.0...0.5)

    let cards = MutableSet<CardModel>()
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension CardDeckModel {
    var color:UIColor {
        .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    static func makeDeck(useJoker:Bool) {
        let newDeck = CardDeckModel()
        newDeck.cards.insert(objectsIn: CardModel.makeCardFullSet(useJoker: useJoker))
        let realm = try! Realm()
        try! realm.write {
            realm.add(newDeck)
        }
    }
}
