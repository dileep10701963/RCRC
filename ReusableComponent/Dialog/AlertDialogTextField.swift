//
//  AlertDialogTextField.swift
//  RCRC
//
//  Created by Errol on 21/06/21.
//

import UIKit

class AlertDialogTextField: UIViewController {
    typealias EnteredText = String
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var alertTextField: UITextField!

    private var titleText: String?
    private var messageText: String?
    private var placeholderText: String?
    private var textFieldText: String?
    private var action: ((EnteredText) -> Void)?
    private var onSave: (() -> Void)?

    convenience init(title: String, message: String, placeholder: String, action: @escaping (EnteredText) -> Void, onSave: @escaping () -> Void) {
        self.init(nibName: "AlertDialogTextField", bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.titleText = title.localized
        self.messageText = message.localized
        self.placeholderText = placeholder.localized
        self.action = action
        self.onSave = onSave
    }
    
    convenience init(title: String, message: String, placeholder: String, editText: String, action: @escaping (EnteredText) -> Void, onSave: @escaping () -> Void) {
        self.init(nibName: "AlertDialogTextField", bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.titleText = title.localized
        self.messageText = message.localized
        self.placeholderText = placeholder.localized
        self.textFieldText = editText
        self.action = action
        self.onSave = onSave
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let alertMessageAttributedText = attributedText(text: messageText)
        let alertTitleAttributedText = attributedText(text: titleText)
        
        alertTitle.attributedText = alertTitleAttributedText
        alertMessage.attributedText = alertMessageAttributedText
        alertTextField.placeholder = placeholderText
        alertTextField.text = textFieldText
        
        alertTextField.layer.cornerRadius = 10.0
        alertTextField.delegate = self
        alertTitle.textAlignment = .center
        alertMessage.setAlignment()
        
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        if let enteredText = alertTextField.text, enteredText.isNotEmpty {
            alertTextField.borderColor = Colors.green
            action?(enteredText)
            dismiss(animated: true, completion: onSave)
        } else {
            alertTextField.borderColor = .red
        }
    }

    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension AlertDialogTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
