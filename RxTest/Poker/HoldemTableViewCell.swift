//
//  HoldemTableViewCell.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import UIKit

class HoldemTableViewCell: UITableViewCell {
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var dealerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var dealerButtons : [UIButton]!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var playerButtons : [UIButton]!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        for set in [dealerButtons, buttons, playerButtons] {
            for btn in set ?? [] {
                btn.isSelected = selected
            }
        }
    }

}
