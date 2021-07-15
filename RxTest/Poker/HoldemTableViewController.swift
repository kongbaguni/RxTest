//
//  HoldemTableViewController.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

class HoldemTableViewController: UITableViewController {
    @IBOutlet weak var playerButton: UIButton!
    @IBOutlet weak var dealerButton: UIButton!
    
    var games:Results<HoldemGameModel> {
        try! Realm().objects(HoldemGameModel.self).sorted(byKeyPath: "timeStamp", ascending: false)
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerButton.rx.tap.bind { _ in
            HoldemGameModel.make(playerId: "player")
        }.disposed(by: disposeBag)
        
        dealerButton.rx.tap.bind { _ in
            HoldemGameModel.make(playerId: "dealer")
        }.disposed(by: disposeBag)
        
        Observable.collection(from: games)
            .subscribe { [weak self] event in
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "game", for: indexPath) as! HoldemTableViewCell
        let game = games[indexPath.row]
        for (idx,card) in game.cards.enumerated() {
            cell.imageViews[idx].image = card.image
        }
        cell.titleLabel.text = game.playerId
        return cell
    }

}


class HoldemTableViewCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var imageViews: [UIImageView]!
}
