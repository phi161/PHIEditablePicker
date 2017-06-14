//
//  PHIEditableOptionTableViewCell.swift
//  PHIEditablePicker
//
//  Created by phi161 on 2017.06.14.
//

import UIKit

/**
 This protocol informs the view controller about events related to the cell's UITextField editing state
 */
protocol PHIEditableOptionTableViewCellDelegate: class {
    /**
     Tells the delegate that editing has started
     */
    func cellTextFieldDidBeginEditing(_ cell: PHIEditableOptionTableViewCell);
    
    /**
     Tells the delegate that editing has ended
     */
    func cellTextFieldDidEndEditing(_ cell: PHIEditableOptionTableViewCell);
}


class PHIEditableOptionTableViewCell: UITableViewCell {
    
    weak var delegate: PHIEditableOptionTableViewCellDelegate?
    
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textField.delegate = self
    }
}

extension PHIEditableOptionTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.cellTextFieldDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.cellTextFieldDidEndEditing(self)
    }
}
