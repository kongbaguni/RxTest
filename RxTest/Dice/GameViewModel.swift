//
//  GameViewModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/09.
//

import Foundation
import RxRealm
import RealmSwift
import RxSwift

struct GameViewModel {
    var list:Results<DiceGameModel> {
        return try! Realm().objects(DiceGameModel.self).sorted(byKeyPath: "timeStamp")
    }
    
    var observerbleList:Observable<Results<DiceGameModel>> {
        return Observable.collection(from: list)
    }
    
    func makeGame(diceNumber:Int) {
        DiceGameModel.makeGame(diceNumbere: diceNumber, playerName: .randomPlayerName)
    }      
    
}
