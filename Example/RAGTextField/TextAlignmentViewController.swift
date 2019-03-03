import UIKit
import RAGTextField

final class TextAlignmentViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var naturalAlignmentTextField: RAGTextField! {
        didSet {
            setUp(naturalAlignmentTextField)
            naturalAlignmentTextField.hintColor = .darkGray
            naturalAlignmentTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            naturalAlignmentTextField.hint = "Based on user interface direction"
        }
    }
    
    @IBOutlet private weak var differentAlignmentsTextField: RAGTextField! {
        didSet {
            setUp(differentAlignmentsTextField)
            differentAlignmentsTextField.hintColor = ColorPalette.meadow
            differentAlignmentsTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
        }
    }
    
    @IBOutlet private weak var textAlignmentControl: UISegmentedControl! {
        didSet {
            textAlignmentControl.tintColor = ColorPalette.meadow
        }
    }
    
    private func setUp(_ textField: RAGTextField) {
        
        textField.delegate = self
        textField.clearButtonMode = .whileEditing
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
        
        title = "Text alignment"
        
        super.viewDidLoad()
        
        setTextAlignement(at: textAlignmentControl.selectedSegmentIndex)
    }
    
    @IBAction func onTextAlignmentChanged(_ control: UISegmentedControl) {
        
        setTextAlignement(at: control.selectedSegmentIndex)
    }
    
    private func setTextAlignement(at index: Int) {
        
        _ = differentAlignmentsTextField.resignFirstResponder()
        
        let alignment: NSTextAlignment = [.left, .center, .right][index]
        differentAlignmentsTextField.textAlignment = alignment
        differentAlignmentsTextField.hint = hint(for: alignment)
    }
    
    private func hint(for textAlignment: NSTextAlignment) -> String {
        
        switch textAlignment {
        case .left:
            return "Left alignment"
        case .center:
            return "Center alignment"
        case .right:
            return "Right alignment"
        case .natural:
            return "Natural alignment"
        case .justified:
            return "Justified alignment"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}
