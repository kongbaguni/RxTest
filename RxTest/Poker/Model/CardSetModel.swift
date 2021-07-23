//
//  CardSetModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/14.
//

import Foundation
import RealmSwift
class CardSetModel: Object {
    @objc dynamic var uuid:UUID = UUID()
    @objc dynamic var timeStamp:Date = Date()
    
    @objc dynamic var red:Float = .random(in: 0.0...0.5)
    @objc dynamic var green:Float = .random(in: 0.0...0.5)
    @objc dynamic var blue:Float = .random(in: 0.0...0.5)

    let cards = MutableSet<CardModel>()
    
    override static func primaryKey() -> String? {
        return "uuid"
    }
}

extension CardSetModel {
    static func clear() {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(CardSetModel.self))
        }
    }
    var color:UIColor {
        .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
    static func makeDeck(useJoker:Bool) {
        let newDeck = CardSetModel()
        newDeck.cards.insert(objectsIn: CardModel.makeCardFullSet(useJoker: useJoker))
        let realm = try! Realm()
        try! realm.write {
            realm.add(newDeck)
        }
    }
    
    func dropRandomCard()->CardModel? {
        let realm = try! Realm()
        if let card = cards.randomElement() {
            realm.beginWrite()
            cards.remove(card)
            if cards.count == 0 {
                realm.delete(self)
            }
            try! realm.commitWrite()
            return card
        }
        return nil
    }
}
