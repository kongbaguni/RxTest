//
//  CardModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/14.
//

import Foundation
import RealmSwift
class CardModel: Object {
    @objc dynamic var id:String = "\(UUID().uuidString)_\(Date().timeIntervalSince1970)"
    @objc dynamic var value:String = ""
    @objc dynamic var timeStamp:Date = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
 
extension CardModel {
    
    static func clear() {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(realm.objects(CardModel.self))
        try! realm.commitWrite()
    }
    
    static func makeCardFullSet(useJoker:Bool)->[CardModel] {
        var result:[CardModel] = []
        let realm = try! Realm()
        realm.beginWrite()
        for family in CardFamily.allCases {
            for type in CardType.allCases {
                let id = "\(family.rawValue)_\(type.rawValue)"
                let card = realm.create(CardModel.self, value: ["value":id], update: .all)
                result.append(card)
            }
        }
        if useJoker {
            for _ in 1...2 {
                let joker = realm.create(CardModel.self, value: ["value":"joker"], update: .all)
                result.append(joker)
            }
        }
        try! realm.commitWrite()
        return result
    }
    
    enum CardFamily:String, CaseIterable {
        case spade = "S"
        case heart = "H"
        case diamond = "D"
        case club = "C"
    }
    
    enum CardType:String, CaseIterable {
        case ace = "a"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eught = "8"
        case nine = "9"
        case ten = "10"
        case junior = "j"
        case queen = "q"
        case king = "k"
    }
    
    var cardIndex:Int {
        switch cardType {
        case .ace:
            return 1
        case .junior:
            return 11
        case .queen:
            return 12
        case .king:
            return 13
        default:
            return cardType?.rawValue.integerValue ?? 0
        }
    }
    
    var cardFamily:CardFamily? {
        let list = value.components(separatedBy: "_")
        if list.count == 2 {
            let txt = list.first!
            return CardFamily(rawValue: txt)
        }
        return nil
    }
    
    var cardType:CardType? {
        let list = value.components(separatedBy: "_")
        if list.count == 2 {
            let txt = list.last!
            return CardType(rawValue: txt)
        }
        return nil
    }
    
    var image:UIImage? {
        if cardFamily == nil {
            return #imageLiteral(resourceName: "joker")
        }
        return UIImage(named: value)
    }
}
