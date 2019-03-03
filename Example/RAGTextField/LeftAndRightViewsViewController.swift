import UIKit
import RAGTextField

private enum Constants {
    
    static let leftAndRightViewTintColor = ColorPalette.flame
}

final class LeftAndRightViewsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet private weak var notificationView: UIView!
    @IBOutlet private weak var notificationLabel: UILabel!
    
    @IBOutlet private weak var leftViewSwitch: UISwitch! {
        didSet {
            leftViewSwitch.tintColor = Constants.leftAndRightViewTintColor
            leftViewSwitch.onTintColor = Constants.leftAndRightViewTintColor
        }
    }
    
    @IBOutlet private weak var leftViewModeControl: UISegmentedControl! {
        didSet {
            leftViewModeControl.tintColor = Constants.leftAndRightViewTintColor
        }
    }
    
    @IBOutlet private weak var rightViewSwitch: UISwitch! {
        didSet {
            rightViewSwitch.tintColor = Constants.leftAndRightViewTintColor
            rightViewSwitch.onTintColor = Constants.leftAndRightViewTintColor
        }
    }
    
    @IBOutlet private weak var rightViewModeControl: UISegmentedControl! {
        didSet {
            rightViewModeControl.tintColor = Constants.leftAndRightViewTintColor
        }
    }
    
    @IBOutlet private weak var leftViewTextField: RAGTextField! {
        didSet {
            setUp(leftViewTextField)
            
            leftViewTextField.placeholderMode = .simple
            leftViewTextField.placeholderColor = ColorPalette.stone
            leftViewTextField.leftView = makeSearchIconView()
            leftViewTextField.leftViewMode = .always
            leftViewTextField.textColor = ColorPalette.midnight
            leftViewTextField.tintColor = ColorPalette.stone
            leftViewTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            leftViewTextField.hintColor = ColorPalette.savanna
            leftViewTextField.hintOffset = 4.0
            leftViewTextField.hint = "Left view mode is .always"
        }
    }
    
    @IBOutlet private weak var rightViewTextField: RAGTextField! {
        didSet {
            setUp(rightViewTextField)
            
            rightViewTextField.placeholderMode = .scalesWhenEditing
            rightViewTextField.placeholderColor = ColorPalette.stone
            rightViewTextField.rightView = makeCalendarButtonView()
            rightViewTextField.rightViewMode = .unlessEditing
            rightViewTextField.textColor = ColorPalette.midnight
            rightViewTextField.tintColor = ColorPalette.stone
            rightViewTextField.hintFont = UIFont.systemFont(ofSize: 11.0)
            rightViewTextField.hintColor = ColorPalette.bramble
            rightViewTextField.hintOffset = 2.0
            rightViewTextField.hint = "Right view mode is .unlessEditing"
        }
    }
    
    @IBOutlet private weak var leftAndRightViewTextField: RAGTextField! {
        didSet {
            setUp(leftAndRightViewTextField, color: Constants.leftAndRightViewTintColor)
            leftAndRightViewTextField.placeholderMode = .scalesWhenEditing
            leftAndRightViewTextField.placeholderColor = ColorPalette.chalk
            leftAndRightViewTextField.textColor = .white
            leftAndRightViewTextField.tintColor = ColorPalette.chalk
        }
    }
    
    @IBOutlet private weak var uiTextField: UITextField! {
        didSet {
            uiTextField.delegate = self
            uiTextField.tintColor = ColorPalette.stone
        }
    }
    
    private func setUp(_ textField: RAGTextField, color: UIColor = ColorPalette.chalk) {
        
        textField.delegate = self
        textField.textBackgroundView = makeTextBackgroundView(color: color)
        textField.textPadding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        textField.textPaddingMode = .textAndPlaceholderAndHint
        textField.scaledPlaceholderOffset = 2.0
        textField.placeholderScaleWhenEditing = 0.8
    }
    
    private func makeTextBackgroundView(color: UIColor) -> UIView {
        
        let view = UIView()
        view.layer.cornerRadius = 4.0
        view.backgroundColor = color
        
        return view
    }
    
    private func makeSearchIconView() -> UIView {
        
        return UIImageView(image: UIImage(named: "search"))
    }
    
    private func makeCalendarButtonView() -> UIView {
        
        let image = UIImage(named: "calendar")!
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        button.addTarget(self, action: #selector(onCalendarButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc private func onCalendarButtonTapped(_ button: UIButton) {
        
        showNotification("Right view tapped")
    }
    
    override func viewDidLoad() {
        
        title = "Left and right views"
        
        setLeftView(visible: leftViewSwitch.isOn)
        setLeftViewMode(at: leftViewModeControl.selectedSegmentIndex)
        
        setRightView(visible: rightViewSwitch.isOn)
        setRightViewMode(at: rightViewModeControl.selectedSegmentIndex)
        
        super.viewDidLoad()
    }
    
    private func setLeftView(visible: Bool) {
    
        if visible {
            leftAndRightViewTextField.leftView = makeSearchIconView()
            uiTextField.leftView = makeSearchIconView()
        } else {
            leftAndRightViewTextField.leftView = nil
            uiTextField.leftView = nil
        }
    }
    
    private func setRightView(visible: Bool) {
        
        if visible {
            leftAndRightViewTextField.rightView = makeCalendarButtonView()
            uiTextField.rightView = makeCalendarButtonView()
        } else {
            leftAndRightViewTextField.rightView = nil
            uiTextField.rightView = nil
        }
    }
    
    private func setLeftViewMode(at index: Int) {
        
        let mode: UITextField.ViewMode = [.always, .whileEditing, .unlessEditing][index]
        leftAndRightViewTextField.leftViewMode = mode
        uiTextField.leftViewMode = mode
    }
    
    private func setRightViewMode(at index: Int) {
        
        let mode: UITextField.ViewMode = [.always, .whileEditing, .unlessEditing][index]
        leftAndRightViewTextField.rightViewMode = mode
        uiTextField.rightViewMode = mode
    }
    
    @IBAction private func onLeftViewModeChanged(_ control: UISegmentedControl) {
        
        setLeftViewMode(at: control.selectedSegmentIndex)
    }
    
    @IBAction private func onLeftViewToggled(_ control: UISwitch) {
        
        setLeftView(visible: control.isOn)
    }
    
    @IBAction private func onRightViewModeChanged(_ control: UISegmentedControl) {
        
        setRightViewMode(at: control.selectedSegmentIndex)
    }
    
    @IBAction private func onRightViewToggled(_ control: UISwitch) {
        
        setRightView(visible: control.isOn)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
    
    private func showNotification(_ message: String) {
        
        notificationLabel.text = message
        
        notificationView.alpha = 1.0
        let animations: () -> Void = { [view = notificationView] in view?.alpha = 0 }
        UIView.animate(withDuration: 0.33, delay: 0.66, options: [], animations: animations)
    }
}

