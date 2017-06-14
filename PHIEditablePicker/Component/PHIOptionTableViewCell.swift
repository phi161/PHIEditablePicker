//
//  PHIOptionTableViewCell.swift
//  PHIEditablePicker
//
//  Created by phi161 on 2017.06.14.
//

import UIKit

class PHIOptionTableViewCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainLabel.textColor = UIColor.red
    }

}
