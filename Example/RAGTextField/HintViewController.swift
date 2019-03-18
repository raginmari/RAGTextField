import UIKit
import RAGTextField

final class HintViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var hintTextField: RAGTextField! {
        didSet {
            setUp(hintTextField)
            hintTextField.hintColor = .darkGray
            hintTextField.hintFont = UIFont.systemFont(ofSize: 10.0)
            hintTextField.hint = "An info or error message"
        }
    }
    
    @IBOutlet private weak var coloredHintTextField: RAGTextField! {
        didSet {
            setUp(coloredHintTextField)
            coloredHintTextField.hintColor = ColorPalette.flame
            coloredHintTextField.hintFont = UIFont.systemFont(ofSize: 12.0)
            coloredHintTextField.hint = "An error has occurred"
        }
    }
    
    @IBOutlet private weak var offsetHintTextField: RAGTextField! {
        didSet {
            setUp(offsetHintTextField)
            offsetHintTextField.hintColor = ColorPalette.sky
            offsetHintTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            offsetHintTextField.hint = "Keep a distance"
        }
    }
    
    @IBOutlet private weak var hintVisibilityControl: UISegmentedControl! {
        didSet {
            hintVisibilityControl.tintColor = .darkGray
        }
    }
    
    @IBOutlet private weak var hintOffsetControl: UISegmentedControl! {
        didSet {
            hintOffsetControl.tintColor = ColorPalette.sky
        }
    }
    
    private func setUp(_ textField: RAGTextField) {
        
        textField.delegate = self
        textField.textColor = ColorPalette.midnight
        textField.tintColor = ColorPalette.midnight
        textField.textBackgroundView = makeTextBackgroundView()
        textField.textPadding = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        textField.textPaddingMode = .textAndPlaceholderAndHint
        textField.scaledPlaceholderOffset = 2.0
        textField.placeholderMode = .scalesWhenEditing
        textField.placeholderScaleWhenEditing = 0.8
        textField.placeholderColor = ColorPalette.stone
    }
    
    private func makeTextBackgroundView() -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.backgroundColor = ColorPalette.chalk
        
        return view
    }
    
    override func viewDidLoad() {
        
        title = "Hint label"
        
        super.viewDidLoad()
        
        setHintVisibility(at: hintVisibilityControl.selectedSegmentIndex)
        setHintOffset(at: hintOffsetControl.selectedSegmentIndex)
    }
    
    @IBAction func onHintVisibilityDidChange(_ control: UISegmentedControl) {
        
        setHintVisibility(at: control.selectedSegmentIndex)
    }
    
    @IBAction func onHintOffsetDidChange(_ control: UISegmentedControl) {
        
        setHintOffset(at: control.selectedSegmentIndex)
    }
    
    private func setHintVisibility(at index: Int) {
        
        _ = hintTextField.resignFirstResponder()
        
        let value: String? = ["An info or error message", "", nil, nil][index]
        hintTextField.hint = value
        
        if index == 3 {
            hintTextField.layoutAlwaysIncludesHint = true
        } else {
            hintTextField.layoutAlwaysIncludesHint = false
        }
    }
    
    private func setHintOffset(at index: Int) {
        
        _ = offsetHintTextField.resignFirstResponder()
        
        let offset: CGFloat = [0.0, 8.0, 16.0][index]
        offsetHintTextField.hintOffset = offset
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
