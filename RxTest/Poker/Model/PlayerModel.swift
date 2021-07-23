//
//  PlayerModel.swift
//  RxTest
//
//  Created by Changyul Seo on 2021/07/22.
//

import Foundation
import RealmSwift
class PlayerModel: Object {
    @objc dynamic var uuid:UUID = UUID()
    @objc dynamic var name:String = ""
    override static func primaryKey() -> String? {
        return "name"
    }
}

extension PlayerModel {    
    static func makePlayer(name:String)->PlayerModel {
        let realm = try! Realm()
        realm.beginWrite()
        let model = realm.create(PlayerModel.self, value: [
            "name":name
        ], update: .modified)
        try! realm.commitWrite()
        return model
    }
    
    var games:Results<GameModel> {
        let realm = try! Realm()
        return realm.objects(GameModel.self).filter("player = %@",self)
    }
    
    var holdemGames:Results<HoldemGameModel> {
        let realm = try! Realm()
        return realm.objects(HoldemGameModel.self).filter("player = %@",self)
    }
    
    var diceGames:Results<DiceGameModel> {
        let realm = try! Realm()
        return realm.objects(DiceGameModel.self).filter("player = %@",self)
    }
}


extension String {
    static var randomPlayerName:String {
        ["둘리","고길동","또치","손오공","저팔개","사오정","삼장법사"].randomElement()!
    }
}
