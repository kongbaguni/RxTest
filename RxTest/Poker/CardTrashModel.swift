//
//  CardTrashModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import Foundation
import RealmSwift
class CardTrashModel: CardSetModel {
}

extension CardTrashModel {
    static func discard(cards:[CardModel]) {
        let realm = try! Realm()
        let model = CardTrashModel()
        model.cards.insert(objectsIn: cards)
        try! realm.write {
            realm.add(model)
        }
    }
}
