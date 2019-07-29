import UIKit
import RAGTextField

final class OutlineViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var outlineTextField: RAGTextField! {
        didSet {
            outlineTextField.delegate = self
            
            let bgView = OutlineView(frame: .zero)
            bgView.lineWidth = 1
            bgView.lineColor = ColorPalette.savanna
            bgView.fillColor = nil
            bgView.cornerRadius = 6.0
            outlineTextField.textColor = ColorPalette.stone
            outlineTextField.tintColor = ColorPalette.stone
            outlineTextField.textBackgroundView = bgView
            outlineTextField.textPadding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            outlineTextField.textPaddingMode = .text
            outlineTextField.scaledPlaceholderOffset = 0.0
            outlineTextField.placeholderMode = .scalesWhenEditing
            outlineTextField.placeholderScaleWhenEditing = 0.8
            outlineTextField.placeholderColor = ColorPalette.savanna
        }
    }

    @IBOutlet private weak var outlinePlaceholderBackgroundColorTextField: RAGTextField! {
        didSet {
            outlinePlaceholderBackgroundColorTextField.delegate = self

            let bgView = OutlineView(frame: .zero)
            bgView.lineWidth = 1
            bgView.lineColor = ColorPalette.savanna
            bgView.fillColor = nil
            bgView.cornerRadius = 6.0
            outlinePlaceholderBackgroundColorTextField.textColor = ColorPalette.stone
            outlinePlaceholderBackgroundColorTextField.tintColor = ColorPalette.stone
            outlinePlaceholderBackgroundColorTextField.textBackgroundView = bgView
            outlinePlaceholderBackgroundColorTextField.textPadding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
            outlinePlaceholderBackgroundColorTextField.textPaddingMode = .text
            outlinePlaceholderBackgroundColorTextField.scaledPlaceholderOffset = -6.5
            outlinePlaceholderBackgroundColorTextField.placeholderMode = .scalesWhenEditing
            outlinePlaceholderBackgroundColorTextField.placeholderScaleWhenEditing = 0.8
            outlinePlaceholderBackgroundColorTextField.placeholderColor = ColorPalette.savanna
            outlinePlaceholderBackgroundColorTextField.placeholderBackgroundColor = UIColor.white
        }
    }
    
    @IBOutlet private weak var outlineAndFillTextField: RAGTextField! {
        didSet {
            outlineAndFillTextField.delegate = self
            
            let bgView = OutlineView(frame: .zero)
            bgView.lineWidth = 2
            bgView.lineColor = ColorPalette.stone
            bgView.fillColor = ColorPalette.midnight
            bgView.cornerRadius = 4.0
            
            outlineAndFillTextField.textColor = ColorPalette.star
            outlineAndFillTextField.tintColor = ColorPalette.star
            outlineAndFillTextField.textBackgroundView = bgView
            outlineAndFillTextField.textPadding = UIEdgeInsets(top: 12.0, left: 8.0, bottom: 12.0, right: 8.0)
            outlineAndFillTextField.textPaddingMode = .textAndPlaceholder
            outlineAndFillTextField.scaledPlaceholderOffset = 0.0
            outlineAndFillTextField.placeholderMode = .scalesWhenEditing
            outlineAndFillTextField.placeholderScaleWhenEditing = 0.8
            outlineAndFillTextField.placeholderColor = ColorPalette.stone
            outlineAndFillTextField.transformedPlaceholderColor = outlineAndFillTextField.tintColor
            outlineAndFillTextField.hintColor = ColorPalette.stone
            outlineAndFillTextField.hintOffset = 2.0
            outlineAndFillTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            outlineAndFillTextField.hint = "Enter some text"
        }
    }
    
    @IBOutlet private weak var boxTextField: RAGTextField! {
        didSet {
            boxTextField.delegate = self
            
            let bgView = OutlineView(frame: .zero)
            bgView.lineWidth = 1.0 / UIScreen.main.scale // 1 pixel
            bgView.lineColor = ColorPalette.sky
            bgView.fillColor = ColorPalette.chalk
            bgView.cornerRadius = 0.0
            boxTextField.textBackgroundView = bgView
            boxTextField.textPadding = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
            boxTextField.textPaddingMode = .textAndPlaceholderAndHint
            boxTextField.scaledPlaceholderOffset = 0.0
            boxTextField.placeholderMode = .scalesWhenEditing
            boxTextField.placeholderScaleWhenEditing = 0.8
            boxTextField.placeholderColor = ColorPalette.sky
            boxTextField.textColor = ColorPalette.midnight
            boxTextField.tintColor = ColorPalette.midnight
            boxTextField.hintColor = ColorPalette.meadow
            boxTextField.hintOffset = 0.0
            boxTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            boxTextField.hint = "Enter some text"
        }
    }
    
    override func viewDidLoad() {
        
        title = "Outline"
        
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
