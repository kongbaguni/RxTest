//
//  GameInfoTableViewCell.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/12.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift

class GameInfoTableViewCell: UITableViewCell {
    var gameId:String? = nil
    
    var gameModel:GameModel? {
        if let id = gameId {
            return try! Realm().object(ofType: GameModel.self, forPrimaryKey: id)
        }
        return nil
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.dataSource = self
        if let time = gameModel?.timeStamp {
            titleLabel.text = "\(time)"
        }
        else {
            titleLabel.text = nil 
        }
        sumLabel.text = "합계 : \(gameModel?.sum ?? 0)"
        backgroundColor = gameModel?.color

        Observable.collection(from: try! Realm().objects(GameModel.self))
            .subscribe { [weak self]event in
                self?.collectionView.reloadData()

            }.disposed(by: disposeBag)
    }
}

extension GameInfoTableViewCell : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameModel?.dices.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "diceCell", for: indexPath) as! DiceCollectionViewCell
        if let list = gameModel?.dices {
            if indexPath.row < list.count {
                cell.imageView.image = list[indexPath.row].image
            }
        }
        return cell
    }
    
    
}

class DiceCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}
