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
import PopupDialog


class PorkerCardCollectionViewController: UICollectionViewController {

    let disposeBag = DisposeBag()
    
    enum ListType {
        case newCard
        case inTrash
    }
    
    var listType:ListType = .newCard
    
    var cardSets:Results<CardSetModel> {
        return try! Realm().objects(CardSetModel.self).sorted(byKeyPath: "timeStamp",ascending: false)
    }
    
    var trashCards:Results<CardTrashModel> {
        return try! Realm().objects(CardTrashModel.self).sorted(byKeyPath: "timeStamp",ascending: false)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch listType {
        case .newCard:
            navigationItem.rightBarButtonItem = .init(image: #imageLiteral(resourceName: "honors_spade-14").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.menuPopup))
        case .inTrash:
            navigationItem.rightBarButtonItem = nil 
        }
        
        Observable.collection(from: cardSets)
            .subscribe { [weak self] event in
                switch event {
                case .next(_):
                    self?.collectionView.reloadData()
                case .completed:
                    break
                case .error(let error):
                    print(error.localizedDescription)
                }
            }.disposed(by: disposeBag)
    }
    
    
    @objc func menuPopup() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(.init(title: "make cards", style: .default, handler: { _ in
            CardSetModel.makeDeck(useJoker: false)
        }))
        vc.addAction(.init(title: "make cards with joker", style: .default, handler: { _ in
            CardSetModel.makeDeck(useJoker: true)
        }))
        vc.addAction(.init(title: "delete all cards", style: .default, handler: { _ in
            CardModel.clear()
            CardSetModel.clear()
        }))
        vc.addAction(.init(title: "cancel", style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
   
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch listType {
        case .newCard:
            return cardSets.count
        case .inTrash:
            return trashCards.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch listType {
        case .newCard:
            return cardSets[section].cards.count
        case .inTrash:
            return trashCards[section].cards.count
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch listType {
        case .newCard:
            if let card = cardSets[indexPath.section].dropRandomCard() {
                let popup = PopupDialog(title: nil, message: nil, image: card.image)
                popup.view.backgroundColor = .clear
                present(popup, animated: true, completion: nil)
                CardTrashModel.discard(cards: [card])
            }
        default:
            break
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "card", for: indexPath) as! PokerCardCollectionViewCell
        switch listType {
        case .newCard:
            let card = cardSets[indexPath.section].cards[indexPath.row]
            cell.imageView.image = card.image
        case .inTrash:
            let card = trashCards[indexPath.section].cards[indexPath.row]
            cell.imageView.image = card.image
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? PokerCardCollectionViewSectionHeader {
            
            switch listType {
            case .newCard:
                header.label.text = "\(cardSets[indexPath.section].timeStamp)"
                header.backgroundColor = cardSets[indexPath.section].color
                
            case .inTrash:
                header.label.text = "\(trashCards[indexPath.section].timeStamp)"
                header.backgroundColor = trashCards[indexPath.section].color
            }
            return header
        }
        return .init()
    }
    
    
}

class PokerCardCollectionViewSectionHeader : UICollectionReusableView {
    @IBOutlet weak var label:UILabel!
}

class PokerCardCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var imageView:UIImageView!
}
