//
//  PokerMenuTableViewController.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import UIKit

class PokerMenuTableViewController: UITableViewController {
    
    enum Menu:String, CaseIterable {
        case cardSetTest = "cardSetTest"
        case cardTrashCan = "cardTrashCan"
        case holdem = "holdem"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Porker Test"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Menu.cardTrashCan.rawValue:
            (segue.destination as? PorkerCardCollectionViewController)?.listType = .inTrash
        case Menu.cardSetTest.rawValue:
            (segue.destination as? PorkerCardCollectionViewController)?.listType = .newCard
        default:
            break
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.allCases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Menu.allCases[indexPath.row].rawValue
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = Menu.allCases[indexPath.row]
        performSegue(withIdentifier: menu.rawValue, sender: nil)
    }
}
