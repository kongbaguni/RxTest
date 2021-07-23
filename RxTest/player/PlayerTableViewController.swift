//
//  PlayerTableViewController.swift
//  RxTest
//
//  Created by Changyul Seo on 2021/07/23.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

class PlayerTableViewController: UITableViewController {

    var players:Results<PlayerModel> {
        try! Realm().objects(PlayerModel.self)
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Observable.collection(from: try! Realm().objects(HoldemGameModel.self)).subscribe { [unowned self]event in
            switch event {
            case .next(_):
                tableView.reloadData()
            default:
                break
            }
        }.disposed(by: disposeBag)
        
        Observable.collection(from: try! Realm().objects(DiceGameModel.self)).subscribe { [unowned self] event in
            switch event {
            case .next(_):
                tableView.reloadData()
            default:
                break
            }
        }.disposed(by: disposeBag)
        Observable.collection(from: players).subscribe { [unowned self] event in
            switch event {
            case .next(_):
                tableView.reloadData()
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = players[indexPath.row]
        cell.textLabel?.text = data.name
        cell.detailTextLabel?.text = "\(data.games.count) \(data.diceGames.count) \(data.holdemGames.count)"
        return cell
    }

}
