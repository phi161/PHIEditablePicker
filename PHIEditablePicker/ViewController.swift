//
//  ViewController.swift
//  PHIEditablePicker
//
//  Created by phi161 on 2017.06.14.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        statusLabel.text = ""
    }
    
    //MARK: - Actions
    
    @IBAction func buttonTapped(_ sender: Any) {
        let picker = PHIPickerViewController(options: ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight"], editableOptions: ["00", "11", "22", "33", "44", "55", "66", "77", "88", "99"])
        picker.delegate = self
        let navigationController = UINavigationController(rootViewController: picker)
        present(navigationController, animated: true, completion: nil)
    }
}


//MARK: - PHIPickerDelegate

extension ViewController: PHIPickerDelegate {
    func pickerViewControllerDidCancel(controller: PHIPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        statusLabel.text = "user canceled"
    }
    
    func pickerViewController(controller: PHIPickerViewController, didSelectOption option: IndexPath?, _ text: String?) {
        controller.dismiss(animated: true) {
            self.statusLabel.text = "done with option \(option?.row ?? -1) and text \(text ?? "nil")"
        }
    }
}
