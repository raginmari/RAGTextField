//
//  ViewController.swift
//  RAGTextField
//
//  Created by raginmari on 03/03/2017.
//  Copyright (c) 2017 raginmari. All rights reserved.
//

import UIKit
import RAGTextField

private enum Constants {
    static let horizontalPadding = CGFloat(8.0)
    static let verticalPadding = CGFloat(4.0)
}

class ViewController: UIViewController {

    @IBOutlet weak var placeholderAndHintTextField: RAGTextField! {
        didSet {
            let bgView = PillView()
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            placeholderAndHintTextField.textBackgroundView = bgView
            
            placeholderAndHintTextField.horizontalTextPadding = Constants.horizontalPadding
            placeholderAndHintTextField.verticalTextPadding = Constants.verticalPadding
            
            placeholderAndHintTextField.placeholderMode = .scalesWhenNotEmpty
            placeholderAndHintTextField.scaledPlaceholderOffset = 2.0
        }
    }
    
    @IBOutlet weak var placeholderTextField: RAGTextField! {
        didSet {
            let bgView = PillView()
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            placeholderTextField.textBackgroundView = bgView
            
            placeholderTextField.horizontalTextPadding = Constants.horizontalPadding
            placeholderTextField.verticalTextPadding = Constants.verticalPadding
            
            placeholderTextField.placeholderMode = .scalesWhenEditing
            placeholderTextField.scaledPlaceholderOffset = 2.0
        }
    }
    
    @IBOutlet weak var plainTextField: RAGTextField! {
        didSet {
            let bgView = PillView()
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            plainTextField.textBackgroundView = bgView
            
            plainTextField.horizontalTextPadding = Constants.horizontalPadding
            plainTextField.verticalTextPadding = Constants.verticalPadding
            
            plainTextField.placeholderMode = .simple
        }
    }
    
    fileprivate var orderedTextFields = [UIResponder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderedTextFields = [placeholderAndHintTextField, placeholderTextField, plainTextField]
    }
    
    fileprivate func nextResponder(after responder: UIResponder) -> UIResponder? {
        switch responder {
        case placeholderAndHintTextField:
            return placeholderTextField
        case placeholderTextField:
            return plainTextField
        case plainTextField:
            return nil
        default:
            return nil
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let value = textField.text ?? ""
        
        if value.isEmpty {
            (textField as! RAGTextField).hint = "Empty"
        } else if value.characters.count < 3 {
            (textField as! RAGTextField).hint = "Too short"
        } else {
            (textField as! RAGTextField).hint = nil
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let nextFirstResponder = nextResponder(after: textField)
        nextFirstResponder?.becomeFirstResponder()
    }
}
