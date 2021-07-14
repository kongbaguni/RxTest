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
    var list:Results<GameModel> {
        return try! Realm().objects(GameModel.self).sorted(byKeyPath: "timeStamp")
    }
    
    var observerbleList:Observable<Results<GameModel>> {
        return Observable.collection(from: list)
    }
    
    func makeGame(diceNumber:Int) {
        GameModel.makeGame(diceNumbere: diceNumber)
    }      
    
}
