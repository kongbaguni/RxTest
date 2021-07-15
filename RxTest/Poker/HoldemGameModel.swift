//
//  HoldemGameModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import Foundation
import RealmSwift
class HoldemGameModel:Object  {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var timeStamp:Date = Date()
    @objc dynamic var playerId:String = ""
    
    let cards = MutableSet<CardModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension HoldemGameModel {
    static func make(playerId:String) {
        let realm = try! Realm()
        guard let cardSet = realm.objects(CardSetModel.self).last else {
            CardSetModel.makeDeck(useJoker: false)
            make(playerId: playerId)
            return
        }
        if cardSet.cards.count < 5 {
            CardTrashModel.discard(cards: cardSet.cards.shuffled())
            realm.beginWrite()
            realm.delete(cardSet)
            try! realm.commitWrite()            
            make(playerId: playerId)
            return
        }
        
        let game = HoldemGameModel()
        for _ in 1...5 {
            game.cards.insert(cardSet.dropRandomCard()!)
        }
        game.playerId = playerId
        realm.beginWrite()
        realm.add(game)
        try! realm.commitWrite()
    }
}
