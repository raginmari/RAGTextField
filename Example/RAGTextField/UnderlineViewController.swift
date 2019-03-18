import UIKit
import RAGTextField

final class UnderlineViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var underlineTextField: RAGTextField! {
        didSet {
            underlineTextField.delegate = self
            
            let bgView = UnderlineView(frame: .zero)
            bgView.textField = underlineTextField
            bgView.backgroundLineColor = ColorPalette.midnight
            bgView.foregroundLineColor = ColorPalette.flame
            bgView.foregroundLineWidth = 2.0
            bgView.expandDuration = 0.2
            bgView.backgroundColor = ColorPalette.chalk
            if #available(iOS 11, *) {
                bgView.layer.cornerRadius = 4.0
                bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            
            underlineTextField.tintColor = ColorPalette.flame
            underlineTextField.textBackgroundView = bgView
            underlineTextField.textPadding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            underlineTextField.textPaddingMode = .textAndPlaceholderAndHint
            underlineTextField.scaledPlaceholderOffset = 0.0
            underlineTextField.placeholderMode = .scalesWhenEditing
            underlineTextField.placeholderScaleWhenEditing = 0.8
            underlineTextField.placeholderColor = ColorPalette.midnight.withAlphaComponent(0.66)
            underlineTextField.transformedPlaceholderColor = underlineTextField.tintColor
            underlineTextField.hint = nil
        }
    }
    
    @IBOutlet private weak var underlineModeTextField: RAGTextField! {
        didSet {
            underlineModeTextField.delegate = self
            
            let bgView = UnderlineView(frame: .zero)
            bgView.textField = underlineModeTextField
            bgView.backgroundLineColor = ColorPalette.midnight
            bgView.foregroundLineColor = ColorPalette.midnight
            bgView.foregroundLineWidth = 3.0
            bgView.expandDuration = 0.2
            bgView.backgroundColor = ColorPalette.sky
            if #available(iOS 11, *) {
                bgView.layer.cornerRadius = 8.0
                bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            
            underlineModeTextField.textColor = .white
            underlineModeTextField.tintColor = .white
            underlineModeTextField.textBackgroundView = bgView
            underlineModeTextField.textPadding = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
            underlineModeTextField.textPaddingMode = .textAndPlaceholder
            underlineModeTextField.scaledPlaceholderOffset = 0.0
            underlineModeTextField.placeholderMode = .scalesWhenEditing
            underlineModeTextField.placeholderScaleWhenEditing = 0.66
            underlineModeTextField.placeholderColor = .white
            underlineModeTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            underlineModeTextField.hintColor = ColorPalette.sky
            underlineModeTextField.hintOffset = 3.0
            underlineModeTextField.hint = "Natural mode supported as well"
        }
    }
    
    @IBOutlet private weak var boxTextField: RAGTextField! {
        didSet {
            boxTextField.delegate = self
            
            let bgView = UnderlineView(frame: .zero)
            bgView.textField = boxTextField
            bgView.backgroundLineColor = ColorPalette.stone
            bgView.foregroundLineColor = ColorPalette.bramble
            bgView.foregroundLineWidth = 2.0
            bgView.expandDuration = 0.2
            bgView.expandMode = .expandsInUserInterfaceDirection
            bgView.backgroundColor = ColorPalette.chalk
            
            boxTextField.textColor = ColorPalette.bramble
            boxTextField.tintColor = ColorPalette.bramble
            boxTextField.textBackgroundView = bgView
            boxTextField.textPadding = UIEdgeInsets(top: 8.0, left: 16.0, bottom: 8.0, right: 16.0)
            boxTextField.textPaddingMode = .textAndPlaceholderAndHint
            boxTextField.scaledPlaceholderOffset = 0.0
            boxTextField.placeholderMode = .scalesWhenEditing
            boxTextField.placeholderScaleWhenEditing = 0.8
            boxTextField.placeholderColor = ColorPalette.midnight.withAlphaComponent(0.66)
            boxTextField.transformedPlaceholderColor = boxTextField.tintColor
            boxTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            boxTextField.hintColor = ColorPalette.midnight
            boxTextField.hintOffset = 0.0
            boxTextField.hint = "Enter some text"
        }
    }
    
    @IBOutlet private weak var underlineModeControl: UISegmentedControl! {
        didSet {
            underlineModeControl.tintColor = ColorPalette.sky
        }
    }
    
    override func viewDidLoad() {
        
        title = "Underline"
        
        setUnderlineMode(at: underlineModeControl.selectedSegmentIndex)
        
        super.viewDidLoad()
    }
    
    private func setUnderlineMode(at index: Int) {
        
        let mode: UnderlineView.Mode = [.expandsFromLeft, .expandsFromCenter, .expandsFromRight, .notAnimated][index]
        (underlineModeTextField.textBackgroundView as? UnderlineView)?.expandMode = mode
    }
    
    @IBAction private func onUnderlineModeChanged(_ control: UISegmentedControl) {
        
        setUnderlineMode(at: control.selectedSegmentIndex)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
