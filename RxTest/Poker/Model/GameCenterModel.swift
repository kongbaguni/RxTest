//
//  GameCenterModel.swift
//  RxTest
//
//  Created by Changyul Seo on 2021/07/22.
//

import Foundation
import RealmSwift
class GameCenterModel: Object {
    @objc dynamic var uuid:UUID = UUID()
    override static func primaryKey() -> String? {
        return "uuid"
    }

    @objc dynamic var name:String = ""    
}


