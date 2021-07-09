//
//  ViewController.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/02.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UITableViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var deleteAllButton: UIButton!
    
    var viewModel = DiceViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        button.rx.tap.bind { [unowned self]_ in
            viewModel.insertDice()
        }.disposed(by: disposeBag)
        
        deleteAllButton.rx.tap.bind { [unowned self] in
            viewModel.removeAll()
        }.disposed(by: disposeBag)
        
        viewModel.observerbleList.subscribe { [weak self] event in
            guard let s = self else {
                return
            }
            switch event {
            case .next(_):
                s.tableView.reloadData()
                print("ViewController --------------------------------------")
                print("tableView row \(s.tableView.numberOfRows(inSection: 0))")
                print("list count : \(s.viewModel.list.count)")
            default:
                break
            }
        }.disposed(by: disposeBag)
        
    }
    


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        let data = viewModel.list.reversed()[indexPath.row]
        cell.textLabel?.text = "\(data.timeStamp)"
        cell.detailTextLabel?.text = "\(data.number)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "삭제", handler: { [weak self] action, view, collback in
                if let s = self {
                    let data = s.viewModel.list.reversed()[indexPath.row]
                    s.viewModel.removeDice(id: data.id)
                }
            })
        ])
        return config
    }
}

