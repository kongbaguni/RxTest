//
//  HoldemTableViewCell.swift
//  RxTest
//
//  Created by Changyeol Seo on 2021/07/15.
//

import UIKit

class HoldemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        for btn in buttons {
            btn.isSelected = selected
        }
    }

}
