//
//  BettingModel.swift
//  RxTest
//
//  Created by Changyul Seo on 2021/07/22.
//

import Foundation
import RealmSwift
class BankTransactionModel: Object {
    @objc dynamic var uuid:UUID = UUID()
    @objc dynamic var value:Int = 0
    @objc dynamic var owner:PlayerModel? = nil
    @objc dynamic var game:GameModel? = nil
    override static func primaryKey() -> String? {
        return "uuid"
    }
}
