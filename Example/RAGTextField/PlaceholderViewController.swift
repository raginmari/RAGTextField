import UIKit
import RAGTextField

final class PlaceholderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var simpleTextField: RAGTextField! {
        didSet {
            simpleTextField.placeholderMode = .simple
            setUp(simpleTextField)
        }
    }
    
    @IBOutlet private weak var whenNotEmptyTextField: RAGTextField! {
        didSet {
            whenNotEmptyTextField.placeholderMode = .scalesWhenNotEmpty
            setUp(whenNotEmptyTextField)
        }
    }
    
    @IBOutlet private weak var whenEditingTextField: RAGTextField! {
        didSet {
            whenEditingTextField.placeholderMode = .scalesWhenEditing
            setUp(whenEditingTextField)
        }
    }
    
    @IBOutlet private weak var offsetTextField: RAGTextField! {
        didSet {
            offsetTextField.placeholderMode = .scalesWhenEditing
            setUp(offsetTextField, color: ColorPalette.savanna.withAlphaComponent(0.1))
        }
    }
    
    @IBOutlet weak var placeholderOffsetControl: UISegmentedControl! {
        didSet {
            placeholderOffsetControl.tintColor = ColorPalette.savanna
        }
    }
    
    private func setUp(_ textField: RAGTextField, color: UIColor = ColorPalette.chalk) {
        
        textField.delegate = self
        textField.textColor = ColorPalette.midnight
        textField.tintColor = ColorPalette.midnight
        textField.textBackgroundView = makeTextBackgroundView(color: color)
        textField.textPadding = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        textField.textPaddingMode = .textAndPlaceholderAndHint
        textField.scaledPlaceholderOffset = 2.0
        textField.placeholderScaleWhenEditing = 0.8
        textField.placeholderColor = ColorPalette.stone
    }
    
    private func makeTextBackgroundView(color: UIColor) -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.backgroundColor = color
        
        return view
    }
    
    override func viewDidLoad() {
        
        title = "Placeholder"
        
        setPlaceholderOffset(at: placeholderOffsetControl.selectedSegmentIndex)
        
        super.viewDidLoad()
    }
    
    @IBAction func onPlaceholderOffsetChanged(_ control: UISegmentedControl) {
        
        setPlaceholderOffset(at: control.selectedSegmentIndex)
    }
    
    private func setPlaceholderOffset(at index: Int) {
        
        _ = offsetTextField.resignFirstResponder()
        
        let offset: CGFloat = [0.0, 8.0, 16.0][index]
        offsetTextField.scaledPlaceholderOffset = offset
        
        let value = "Offset by \(Int(offset))pt"
        offsetTextField.text = value
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
