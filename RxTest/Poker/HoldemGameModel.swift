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
    
    @objc dynamic var red:Float = .random(in: 0.0...0.5)
    @objc dynamic var green:Float = .random(in: 0.0...0.5)
    @objc dynamic var blue:Float = .random(in: 0.0...0.5)

    let cards = MutableSet<CardModel>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension HoldemGameModel {
    var color:UIColor {
        .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
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
    
    
    enum Ranking:Int,CaseIterable {
        case royalStraightFlush = 0
        case straightFlush = 1
        case fourOfAKind = 2
        case fullHouse = 3
        case flush = 4
        case straight = 5
        case threeOfAKind = 6
        case twoPair = 7
        case onePair = 8
        case highCard = 9
    }

    var ranking:Ranking {
        var cardarr:[[CardModel?]] = [
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil],
            [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]
        ]
        
        for card in cards {
            var index:[(Int,Int)]? {
                var f:Int {
                    switch card.cardFamily! {
                    case .club:
                        return 0
                    case .diamond:
                        return 1
                    case .heart:
                        return 2
                    case .spade:
                        return 3
                    }
                }

                switch card.cardType {
                case .ace:
                    return [(f,0),(f,13)]
                case .king:
                    return [(f,12)]
                case .queen:
                    return [(f,11)]
                case .junior:
                    return [(f,10)]
                default:
                    return [(f,card.cardIndex - 1)]
                }
            }
            for idx in index ?? [] {
                cardarr[idx.0][idx.1] = card
            }
        }
        
        var set:[Set<CardModel>] = []
        for arr in cardarr {
            var cset = Set<CardModel>()
            for c in arr {
                if let card = c {
                    cset.insert(card)
                }
            }
            set.append(cset)
        }
        
        let cntA = set[0].count
        let cntB = set[1].count
        let cntC = set[2].count
        let cntD = set[3].count
        
        if cntA == 5 || cntB == 5 || cntC == 5 || cntD == 5 {
            var count = 0
            for set in cardarr {
                for card in set {
                    if card != nil {
                        count += 1
                    }
                    else {
                        count = 0
                    }
                    
                    if count == 5 {
                        if card?.cardType == .ace {
                            return .royalStraightFlush
                        }
                        return .straightFlush
                    }
                }
            }
            return .flush
        }
        print("----------------")
        print("\(set)")
        print("\(cntA) \(cntB) \(cntC) \(cntD)")
        
        return .highCard
    }
    
}
