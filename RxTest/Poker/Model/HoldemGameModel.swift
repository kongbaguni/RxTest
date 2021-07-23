//
//  HoldemGameModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import Foundation
import RealmSwift

class HoldemGameModel: GameModel  {
    let dealerCards = MutableSet<CardModel>()
    let comunitiCards = MutableSet<CardModel>()
    let playerCards =  MutableSet<CardModel>()
    
}

extension HoldemGameModel {
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
        
        for _ in 1...3 {
            game.comunitiCards.insert(cardSet.dropRandomCard()!)
        }

        game.player = PlayerModel.makePlayer(name: playerId)
        realm.beginWrite()
        realm.add(game)
        try! realm.commitWrite()
    }
    
    fileprivate func insertCard() {
        if comunitiCards.count == 5 {
            return
        }
        let realm = try! Realm()
        guard let cardSet = realm.objects(CardSetModel.self).last else {
            CardSetModel.makeDeck(useJoker: false)
            return
        }
        CardTrashModel.discard(cards: [cardSet.dropRandomCard()!])
        let card = cardSet.dropRandomCard()!
        realm.beginWrite()
        comunitiCards.insert(card)
        try! realm.commitWrite()
    }
    
    func turn() {
        if comunitiCards.count == 3 {
            insertCard()
        }
    }
    
    func river() {
        if comunitiCards.count == 4 {
            insertCard()
        }        
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

    enum GameResult {
        case draw
        case playerWin
        case dealerWin
        case notSet
    }
    
    var gameResult:GameResult {
        if comunitiCards.count == 5  && playerCards.count == 2 && dealerCards.count == 2{
            if playerRanking.0.rawValue < dealerRanking.0.rawValue {
                return .playerWin
            }
            if playerRanking.0.rawValue > dealerRanking.0.rawValue {
                return .dealerWin
            }
            if playerRanking.1.kiker!.cardIndex > dealerRanking.1.kiker!.cardIndex {
                return .playerWin
            }
            if playerRanking.1.kiker!.cardIndex < dealerRanking.1.kiker!.cardIndex {
                return .dealerWin
            }
            return .draw
        }        
        return .notSet
    }
    
    struct CardSetForRanking {
        let cards:[CardModel]
        
        var kiker:CardModel? {
            let kiker = cards.sorted { a, b in
                return a.cardIndex < b.cardIndex
            }.last
            return kiker
        }
        
        var totalPoint:Int {
            var result = 0
            for card in cards {
                result += card.cardIndex
            }
            return result
        }
    }
    /** 랭킹 카드 조합 구하기*/
    fileprivate func getCardArrForRanking(a:CardModel,b:CardModel)->[CardSetForRanking] {
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
        var r:[CardSetForRanking] = []
        for arr in result {
            r.append(.init(cards: arr))
        }
        return r
    }
    
    fileprivate var playerCardArrForRanking:[CardSetForRanking] {
        if let a = playerCards.first, let b = playerCards.last {
            return getCardArrForRanking(a: a, b: b)
        }
        return []
    }
    
    fileprivate var dealerCardArrForRanking:[CardSetForRanking] {
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
        

        var have3 = 0
        var have2 = 0
        for value in dic {
            if value.value.count == 4 {
                return .fourOfAKind
            }
            if value.value.count == 3 {
                have3 += 1
            }
            if value.value.count == 2 {
                have2 += 1
            }
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

        
        return .highCard
    }
    
    var playerRanking:(Ranking,CardSetForRanking) {
        var list:[(Ranking,CardSetForRanking)] = []
        for arr in playerCardArrForRanking {
            list.append((getRanking(cards: arr.cards), arr))
        }
        list.sort { a, b in
            if a.0.rawValue == b.0.rawValue {
                return a.1.totalPoint > b.1.totalPoint
            }
            return a.0.rawValue < b.0.rawValue
        }
        print("player card 조합 키커 -----------")
        for c in list.map({$0.1.cards}) {
            print(c.map{$0.value})
        }
        print()
        print("---------------------------------")
        return list.first!
    }
    
    var dealerRanking:(Ranking,CardSetForRanking) {
        var list:[(Ranking,CardSetForRanking)] = []
        for arr in dealerCardArrForRanking {
            list.append((getRanking(cards: arr.cards),arr))
        }
        list.sort { a, b in
            if a.0.rawValue == b.0.rawValue {
                return a.1.totalPoint > b.1.totalPoint
            }
            return a.0.rawValue < b.0.rawValue
        }
        print("dealer card 조합 키커 -----------")
        for c in list.map({$0.1.cards}) {
            print(c.map{$0.value})
        }

        print("---------------------------------")
        return list.first!
    }
}
