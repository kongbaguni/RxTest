//
//  GameTableViewController.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/09.
//

import UIKit
import RxRealm
import RxSwift
import RxCocoa
fileprivate let range = 1...10

class GameTableViewController: UITableViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var numberTextField: UITextField!

    let viewModel = GameViewModel()
    
    let disposeBag = DisposeBag()
    let picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        button.rx.tap.bind { [weak self]_ in
            let txt = self?.numberTextField.text ?? "0"
            let number = NSString(string: txt).integerValue
            self?.viewModel.makeGame(diceNumber: number)
        }.disposed(by: disposeBag)
        
    
        picker.dataSource = self
        picker.delegate = self
        numberTextField.inputView = picker
        

        viewModel.observerbleList.subscribe { [weak self]event in
            print("GameTableViewController --------------------------------------")

            switch event {
            case .next(let list):
                let count = self?.viewModel.list.count ?? 0
                let newCount = list.count
                print("count : \(count) newCount: \(newCount)")
            case .completed:
                print("completed")
            case .error(let error):
                print(error.localizedDescription)
            }
            self?.tableView.reloadData()
        }.disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GameInfoTableViewCell
        let data = viewModel.list.reversed()[indexPath.row]
        cell.gameId = data.id
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let config = UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: "삭제", handler: { [weak self] action, view, collback in
                if let s = self {
                    let data = s.viewModel.list.reversed()[indexPath.row]
                    data.delete()                    
                }
            })
        ])
        return config
    }


}



extension GameTableViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return range.count
    }
    
}

extension GameTableViewController : UIPickerViewDelegate {

    func getTxt(row:Int) -> String? {
        for (idx,number) in range.enumerated() {
            if idx == row {
                return "\(number)"
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        numberTextField.text = getTxt(row: row)
        view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        getTxt(row: row)
    }
}
