//
//  DiceViewModel.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/02.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

struct DiceViewModel {
    var list:Results<DiceModel> {
        return try! Realm().objects(DiceModel.self).sorted(byKeyPath: "timeStamp")
    }
    
    var observerbleList:Observable<Results<DiceModel>> {
        return Observable.collection(from: list)
        
    }
    
    func insertDice() {
        _ = DiceModel.random
    }
    
    func removeDice(id:Int) {
        let realm = try! Realm()
        if let model = realm.object(ofType: DiceModel.self, forPrimaryKey: id) {
            realm.beginWrite()
            realm.delete(model)
            try! realm.commitWrite()
        }
    }
    
    func removeAll() {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(list)
        realm.delete(realm.objects(GameModel.self))
        try! realm.commitWrite()
    }
}
