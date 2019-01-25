//
//  ViewController.swift
//  RAGTextField
//
//  Created by raginmari on 03/03/2017.
//  Copyright (c) 2017 raginmari. All rights reserved.
//

import UIKit
import RAGTextField

class ViewController: UIViewController {

    @IBOutlet weak var uitextField: UITextField!
    
    @IBOutlet weak var textField: RAGTextField! {
        didSet {
            let bgView = PillView()
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.075)
            textField.textBackgroundView = bgView
            
            textField.placeholderMode = .scalesWhenNotEmpty
            textField.hintFont = UIFont.systemFont(ofSize: 12.0)
        }
    }
    
    @IBAction private func onTextAlignmentChanged(_ control: UISegmentedControl) {
        
        textField.endEditing(true)
        
        let alignments: [NSTextAlignment] = [ .left, .center, .right, .justified, .natural ]
        textField.textAlignment = alignments[control.selectedSegmentIndex]
        uitextField.textAlignment = alignments[control.selectedSegmentIndex]
    }
    
    @IBAction private func onPlaceholderModeChanged(_ control: UISegmentedControl) {
        
        textField.endEditing(true)
        
        let modes: [RAGTextFieldPlaceholderMode] = [ .simple, .scalesWhenEditing, .scalesWhenNotEmpty ]
        textField.placeholderMode = modes[control.selectedSegmentIndex]
    }
    
    @IBAction private func onHintChanged(_ control: UISwitch) {
        
        textField.endEditing(true)
        textField.hint = control.isOn ? "Hint or error message" : nil
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
