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
            let underlineColor = UIColor(red: 0.0, green: 150.0 / 255.0, blue: 1.0, alpha: 1.0)
            let placeholderColor = UIColor(white: 185.0 / 255.0, alpha: 1.0)
            let textBackgroundColor = UIColor(white: 245.0 / 255.0, alpha: 1.0)
            
            // Create the text background view
            let bgView = UnderlineView(frame: CGRect.zero)
            bgView.expandMode = .expandsInUserInterfaceDirection
            bgView.backgroundLineColor = placeholderColor
            bgView.foregroundLineColor = underlineColor
            bgView.lineWidth = 2.0
            bgView.backgroundColor = textBackgroundColor
            bgView.layer.cornerRadius = 4.0
            if #available(iOS 11.0, *) {
                bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            textField.textBackgroundView = bgView
            
            textField.placeholderColor = placeholderColor
            textField.placeholderMode = .scalesWhenNotEmpty
            textField.placeholderScaleWhenEditing = 0.7
            textField.scaledPlaceholderOffset = 0.0
            textField.hintOffset = 4.0
            textField.textPadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            textField.textPaddingMode = .textAndPlaceholder
            textField.hintFont = UIFont.systemFont(ofSize: 11.0)
            textField.tintColor = underlineColor
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField === self.textField {
            (self.textField.textBackgroundView as? UnderlineView)?.setExpanded(true, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField === self.textField {
            (self.textField.textBackgroundView as? UnderlineView)?.setExpanded(false, animated: true)
        }
    }
}
