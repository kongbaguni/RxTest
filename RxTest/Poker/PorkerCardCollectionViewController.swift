//
//  PorkerCardCollectionViewController.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/14.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa


class PorkerCardCollectionViewController: UICollectionViewController {

    
    let disposeBag = DisposeBag()
    
    
    var cardDecks:Results<CardDeckModel> {
        return try! Realm().objects(CardDeckModel.self).sorted(byKeyPath: "timeStamp",ascending: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "honors_spade-14").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.menuPopup))
        
        Observable.collection(from: cardDecks)
            .subscribe { [weak self] event in
                self?.collectionView.reloadData()
            }.disposed(by: disposeBag)
    }
    
    @objc func menuPopup() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(.init(title: "make cards", style: .default, handler: { _ in
            CardDeckModel.makeDeck(useJoker: false)
        }))
        vc.addAction(.init(title: "make cards with joker", style: .default, handler: { _ in
            CardDeckModel.makeDeck(useJoker: true)
        }))
        vc.addAction(.init(title: "delete all cards", style: .default, handler: { _ in
            CardModel.clear()
        }))
        vc.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
   
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        cardDecks.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cardDecks[section].cards.count
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! PokerCardCollectionViewCell
        let card = cardDecks[indexPath.section].cards[indexPath.row]
        cell.imageView.image = card.image
        cell.backgroundColor = cardDecks[indexPath.section].color
        return cell
    }
    
}


class PokerCardCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}
