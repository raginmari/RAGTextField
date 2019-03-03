import UIKit
import RAGTextField

final class TextPaddingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var defaultTextField: RAGTextField! {
        didSet {
            setUp(defaultTextField, color: ColorPalette.chalk)
            defaultTextField.textPadding = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        }
    }
    
    @IBOutlet private weak var paddedTextField: RAGTextField! {
        didSet {
            setUp(paddedTextField, color: ColorPalette.bramble.withAlphaComponent(0.2))
            paddedTextField.placeholderColor = ColorPalette.midnight.withAlphaComponent(0.66)
            paddedTextField.hintColor = ColorPalette.midnight
            paddedTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            paddedTextField.textColor = ColorPalette.bramble
            paddedTextField.tintColor = ColorPalette.stone
            paddedTextField.text = "Text"
        }
    }
    
    @IBOutlet private weak var paddingControl: UISegmentedControl! {
        didSet {
            paddingControl.tintColor = ColorPalette.bramble
        }
    }
    
    @IBOutlet private weak var includePlaceholderSwitch: UISwitch! {
        didSet {
            includePlaceholderSwitch.tintColor = ColorPalette.bramble
            includePlaceholderSwitch.onTintColor = ColorPalette.bramble
        }
    }
    
    @IBOutlet private weak var includeHintSwitch: UISwitch! {
        didSet {
            includeHintSwitch.tintColor = ColorPalette.bramble
            includeHintSwitch.onTintColor = ColorPalette.bramble
        }
    }
    
    private func setUp(_ textField: RAGTextField, color: UIColor) {
        
        textField.delegate = self
        textField.textColor = ColorPalette.midnight
        textField.tintColor = ColorPalette.midnight
        textField.textBackgroundView = makeTextBackgroundView(color: color)
        textField.textPaddingMode = .textAndPlaceholderAndHint
        textField.hintOffset = 2.0
        textField.scaledPlaceholderOffset = 2.0
        textField.placeholderMode = .scalesWhenEditing
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
        
        title = "Text padding"
        
        super.viewDidLoad()
        
        setPadding(at: paddingControl.selectedSegmentIndex)
        updateTextPaddingMode()
    }
    
    private func setPadding(at index: Int) {
        
        _ = paddedTextField.resignFirstResponder()
        
        let padding: CGFloat = [4.0, 8.0, 16.0][index]
        paddedTextField.textPadding = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    private func updateTextPaddingMode() {
        
        let mode: RAGTextPaddingMode
        switch (includePlaceholderSwitch.isOn, includeHintSwitch.isOn) {
        case (true, true):
            mode = .textAndPlaceholderAndHint
        case (true, _):
            mode = .textAndPlaceholder
        case (_, true):
            mode = .textAndHint
        default:
            mode = .text
        }
        
        paddedTextField.textPaddingMode = mode
        paddedTextField.hint = hint(for: mode)
    }
    
    @IBAction private func onIncludePlaceholderChanged(_ control: UISwitch) {
        
        updateTextPaddingMode()
    }
    
    @IBAction private func onIncludeHintChanged(_ control: UISwitch) {
        
        updateTextPaddingMode()
    }
    
    private func hint(for mode: RAGTextPaddingMode) -> String {
        
        switch mode {
        case .text:
            return "Text mode"
        case .textAndHint:
            return "Text + hint mode"
        case .textAndPlaceholder:
            return "Text + placeholder mode"
        case .textAndPlaceholderAndHint:
            return "Text + placeholder + hint mode"
        }
    }
    
    @IBAction private func onPaddingChanged(_ control: UISegmentedControl) {
        
        setPadding(at: control.selectedSegmentIndex)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
