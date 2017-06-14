//
//  PHIPickerViewController.swift
//  PHIEditablePicker
//
//  Created by phi161 on 2017.06.14.
//

import UIKit

//TODO: Scroll to the cell with the text field that is currently editing
//TODO: Change PHIPickerDelegate to use indices instead of an IndexPath

/**
 This protocol defines the API of the component. Classes that use PHIPickerDelegate should become the delegate
 and get informed about when the user cancels or selectes an item.
 */
protocol PHIPickerDelegate: class {
    /**
     Tells the delegate that an option was selected.
     @param controller The current instance of the picker
     @param option The indexPath of the selected item
     @param text The custom text that is currently selected. This is `nil` when one of the prefedined options is selected, as opposed to the editable ones
     */
    func pickerViewController(controller: PHIPickerViewController, didSelectOption option: IndexPath?, _ text: String?)
    
    /**
     Tells the delegate that the cancel button was tapped.
     @param controller The current instance of the picker
     */
    func pickerViewControllerDidCancel(controller: PHIPickerViewController)
}


class PHIPickerViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: PHIPickerDelegate?
    
    // Since we might have more than one sections of options, we use an IndexPath instance to represent what the user has currently selected
    var selectedIndexPath: IndexPath? = nil
    
    let PHIOptionTableViewCellReuseIdentifier = "PHIOptionTableViewCellReuseIdentifier"
    let PHIEditableOptionTableViewCellReuseIdentifier = "PHIEditableOptionTableViewCellReuseIdentifier"
    
    var options: [String]
    var editableOptions: [String]
    
    //MARK: - Init
    
    init(options:[String], editableOptions:[String]) {
        self.options = options
        self.editableOptions = editableOptions
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.options = []
        self.editableOptions = []
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.options = []
        self.editableOptions = []
        super.init(coder: aDecoder)
    }
    
    
    //MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar
        title = "Picker!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(buttonTapped(_:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(buttonTapped(_:)))
        
        tableView.register(UINib(nibName: "PHIOptionTableViewCell", bundle: nil), forCellReuseIdentifier: PHIOptionTableViewCellReuseIdentifier)
        tableView.register(UINib(nibName: "PHIEditableOptionTableViewCell", bundle: nil), forCellReuseIdentifier: PHIEditableOptionTableViewCellReuseIdentifier)
    }

    //MARK: - Actions

    @IBAction func buttonTapped(_ sender: Any) {
        // Dismiss keyboard
        view.endEditing(true)
        
        guard let button = sender as? UIBarButtonItem else { return }
        if button == navigationItem.rightBarButtonItem {
            if let indexPath = selectedIndexPath, // we have a selected item..
                selectedIndexPath?.section == 1 // ..and it is an editable one
            {
                delegate?.pickerViewController(controller: self, didSelectOption: selectedIndexPath, editableOptions[indexPath.row])
            } else {
                delegate?.pickerViewController(controller: self, didSelectOption: selectedIndexPath, nil)
            }
        } else if button == navigationItem.leftBarButtonItem {
            delegate?.pickerViewControllerDidCancel(controller: self)
        }
    }
}

//MARK: - UITableViewDelegate & UITableViewDataSource

extension PHIPickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if editableOptions.count > 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return options.count
        } else {
            return editableOptions.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if editableOptions.count > 0 {
            if section == 1 {
                return "editable"
            }
        }
        return "fixed"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHIOptionTableViewCellReuseIdentifier, for: indexPath) as! PHIOptionTableViewCell
            cell.mainLabel?.text = options[indexPath.row]
            cell.accessoryType = selectedIndexPath == indexPath ? .checkmark : .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PHIEditableOptionTableViewCellReuseIdentifier, for: indexPath) as! PHIEditableOptionTableViewCell
            cell.textField?.text = editableOptions[indexPath.row]
            cell.delegate = self
            cell.accessoryType = selectedIndexPath == indexPath ? .checkmark : .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == selectedIndexPath {
            selectedIndexPath = nil
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            let previouslySelectedIndexPath = selectedIndexPath // save so that we can  update the view
            selectedIndexPath = indexPath
            if previouslySelectedIndexPath != nil {
                tableView.reloadRows(at: [previouslySelectedIndexPath!, selectedIndexPath!], with: .automatic)
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - PHIEditableOptionTableViewCellDelegate

extension PHIPickerViewController: PHIEditableOptionTableViewCellDelegate {
    func cellTextFieldDidBeginEditing(_ cell: PHIEditableOptionTableViewCell) {
        if let activeIndexPath = tableView.indexPath(for: cell) {
            // Try to edit the already selected one
            if activeIndexPath == selectedIndexPath {
                selectedIndexPath = nil
                tableView.reloadRows(at: [activeIndexPath], with: .automatic)
            } else { // This cell was not previously selected
                let previouslySelectedIndexPath = selectedIndexPath // save so that we can  update the view
                selectedIndexPath = activeIndexPath
                // There was a cell selected before
                if previouslySelectedIndexPath != nil {
                    tableView.cellForRow(at: previouslySelectedIndexPath!)?.accessoryType = .none
                    tableView.cellForRow(at: selectedIndexPath!)?.accessoryType = .checkmark
                } else { // No cell was selected before
                    tableView.cellForRow(at: selectedIndexPath!)?.accessoryType = .checkmark
                }
            }
        }
    }
    
    func cellTextFieldDidEndEditing(_ cell: PHIEditableOptionTableViewCell) {
        if
            let activeIndexPath = tableView.indexPath(for: cell),
            let text = cell.textField.text {
            editableOptions[activeIndexPath.row] = text
        }
    }
}
