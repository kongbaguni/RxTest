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
    
    var games:Results<HoldemGameModel> {
        try! Realm().objects(HoldemGameModel.self).sorted(byKeyPath: "timeStamp", ascending: false)
    }
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Holdem Test"
        playerButton.rx.tap.bind { _ in
            for player in ["둘리","고길동","또치"] {
                HoldemGameModel.make(playerId: player)
            }
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
        let dealerRanking = game.dealerRanking
        let playerRanking = game.playerRanking
        
        for btn in cell.buttons {
            btn.isHidden = true
        }
        for (idx,card) in game.comunitiCards.enumerated() {
            cell.buttons[idx].setImage(card.image, for: .selected)
            cell.buttons[idx].isHidden = false
        }
        for (idx,card) in game.dealerCards.enumerated() {
            cell.dealerButtons[idx].setImage(card.image, for: .selected)
        }
        for (idx,card) in game.playerCards.enumerated() {
            cell.playerButtons[idx].setImage(card.image, for: .selected)
        }

        
        cell.dealerLabel.text = "\(dealerRanking.0)"
        cell.playerLabel.text = "\(playerRanking.0)"
        for btn in cell.buttons {
            btn.rx.tap.bind { _ in
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }.disposed(by: disposeBag)
        }
        

        for btn in cell.dealerButtons {
            btn.rx.tap.bind { _ in
                for (idx,card) in game.comunitiCards.enumerated() {
                    cell.buttons[idx].alpha = 0.5
                    if dealerRanking.1.contains(card) {
                        cell.buttons[idx].alpha = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        UIView.animate(withDuration: 0.5) {
                            cell.buttons[idx].alpha = 1
                        }
                    }
                }
            }.disposed(by: disposeBag)
        }
        
        for btn in cell.playerButtons {
            btn.rx.tap.bind { _ in
                for (idx,card) in game.comunitiCards.enumerated() {
                    cell.buttons[idx].alpha = 0.5
                    if playerRanking.1.contains(card) {
                        cell.buttons[idx].alpha = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        UIView.animate(withDuration: 0.5) {
                            cell.buttons[idx].alpha = 1
                        }
                    }
                }
            }.disposed(by: disposeBag)
        }
                
        cell.backgroundColor = game.color
        cell.titleLabel.text = "\(game.timeStamp.formatedString(format: "yyyy.MM.dd HH:mm:ss")!) \(game.playerId)"
        return cell
    }

}


