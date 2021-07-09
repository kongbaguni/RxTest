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
