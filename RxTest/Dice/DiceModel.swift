//
//  DiceModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/02.
//

import Foundation
import RealmSwift

class DiceModel : Object {
    @objc dynamic var id:Int = 0
    @objc dynamic var number:Int = 0
    @objc dynamic var timeStamp:Date = Date()

    override static func primaryKey() -> String? {
        return "id"
    }
}

extension DiceModel {
    var image:UIImage? {
        switch number {
        case 1:
            return #imageLiteral(resourceName: "dice 1")
        case 2:
            return #imageLiteral(resourceName: "dice 2")
        case 3:
            return #imageLiteral(resourceName: "dice 3")
        case 4:
            return #imageLiteral(resourceName: "dice 4")
        case 5:
            return #imageLiteral(resourceName: "dice 5")
        case 6:
            return #imageLiteral(resourceName: "dice 6")
        default:
            return nil
        }
    }

    var gameModel:GameModel? {
        let list = try! Realm().objects(DiceGameModel.self).filter({ game in
            return game.dices.contains(self)
        })
        return list.last
    }

    static var random:DiceModel {
        let realm = try! Realm()
        realm.beginWrite()
        let id = (realm.objects(DiceModel.self).sorted(byKeyPath: "id").last?.id ?? 0) + 1
        let model = realm.create(DiceModel.self, value: [
            "id":id,
            "number":Int.random(in: 1...6),
            "timeStamp":Date()
        ], update: .all)
        try! realm.commitWrite()
        return model
    }
    
}
