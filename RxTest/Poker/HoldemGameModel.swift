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

    let dealerCards = MutableSet<CardModel>()
    let comunitiCards = MutableSet<CardModel>()
    let playerCards =  MutableSet<CardModel>()
    
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
        if cardSet.cards.count < (5 + 2 + 2 + 2) {
            CardTrashModel.discard(cards: cardSet.cards.shuffled())
            realm.beginWrite()
            realm.delete(cardSet)
            try! realm.commitWrite()            
            make(playerId: playerId)
            return
        }
        
        let game = HoldemGameModel()
        game.dealerCards.insert(cardSet.dropRandomCard()!)
        game.dealerCards.insert(cardSet.dropRandomCard()!)
        
        game.playerCards.insert(cardSet.dropRandomCard()!)
        game.playerCards.insert(cardSet.dropRandomCard()!)
        
        for _ in 1...5 {
            game.comunitiCards.insert(cardSet.dropRandomCard()!)
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

    fileprivate func getCardArrForRanking(a:CardModel,b:CardModel)->[[CardModel]] {
        if comunitiCards.count < 3 {
            return []
        }

        let c = comunitiCards[0]
        let d = comunitiCards[1]
        let e = comunitiCards[2]
        var result = [[a,b,c,d,e]]
        
        if comunitiCards.count > 3 {
            let f = comunitiCards[3]
            for arr in [[a,b,c,d,f],[a,b,c,e,f],[a,b,d,e,f]] {
                result.append(arr)
            }
            if comunitiCards.count > 4 {
                let g = comunitiCards[4]
                for arr in [[a,b,c,d,g],[a,b,c,e,g],[a,b,c,f,g],[a,b,d,f,g],[a,b,e,f,g]] {
                    result.append(arr)
                }
            }
        }
        return result
    }
    
    fileprivate var playerCardArrForRanking:[[CardModel]] {
        if let a = playerCards.first, let b = playerCards.last {
            return getCardArrForRanking(a: a, b: b)
        }
        return []
    }
    
    fileprivate var dealerCardArrForRanking:[[CardModel]] {
        if let a = dealerCards.first, let b = dealerCards.last {
            return getCardArrForRanking(a: a, b: b)
        }
        return []
    }
    
    fileprivate func getRanking(cards:[CardModel])->Ranking {
        /** 인덱스 순으로 정렬 (스트레이트 검출용)*/
        var cardarrAny:[[CardModel]] = [[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
        
        /** 족보별로 정렬*/
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
                cardarrAny[idx.1].append(card)
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
        
        let cardCount = set.map{$0.count}
        if cardCount.contains(5) {
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

        var count = 0
        for card in cardarrAny {
            if card.count > 0 {
                count += 1
                if count == 5 {
                    return .straight
                }
            } else {
                count = 0
            }
        }
        
        var dic:[Int:Set<CardModel>] = [:]
        for arr in cardarr {
            for c in arr {
                if let card = c {
                    if dic[card.cardIndex] == nil {
                        dic[card.cardIndex] = Set<CardModel>()
                    }
                    dic[card.cardIndex]?.insert(card)
                }
            }
        }
        
        for value in dic {
            var have3 = 0
            var have2 = 0
            if value.value.count == 4 {
                return .fourOfAKind
            }
            if value.value.count == 3 {
                have3 += 1
            }
            if value.value.count == 2 {
                have2 += 1
            }
            if have3 == 1 && have2 == 1 {
                return .fullHouse
            }
            if have3 == 1 {
                return .threeOfAKind
            }
            if have2 == 2 {
                return .twoPair
            }
            if have2 == 1 {
                return .onePair
            }
        }
        
        return .highCard
    }
    
    var playerRanking:(Ranking,[CardModel]) {
        var list:[(Ranking,[CardModel])] = []
        for arr in playerCardArrForRanking {
            list.append((getRanking(cards: arr),arr))
        }
        list.sort { a, b in
            return a.0.rawValue < b.0.rawValue
        }
        return list.first!
    }
    
    var dealerRanking:(Ranking,[CardModel]) {
        var list:[(Ranking,[CardModel])] = []
        for arr in dealerCardArrForRanking {
            list.append((getRanking(cards: arr),arr))
        }
        list.sort { a, b in
            return a.0.rawValue < b.0.rawValue
        }
        return list.first!
    }
}
