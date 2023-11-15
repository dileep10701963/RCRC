//
//  ContactDetailViewController.swift
//  RCRC
//
//  Created by Admin on 19/03/21.
//

import UIKit
import MessageUI

class ContactDetailViewController: UIViewController {

    @IBOutlet weak var fullNameTextField: PaddedTextField!
    @IBOutlet weak var contactNumberTextField: PaddedTextField!
    @IBOutlet weak var emailTextField: PaddedTextField!
    @IBOutlet weak var topicTextField: PaddedTextField!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var privacyNoticeLabel: PaddedTextField!
    private let viewModel = ContactDetailViewModel()
    var activityIndicator: UIActivityIndicatorView?

    var picker: PickerWithDoneButton?
    var selectedData: String?
    var selected: Int = -1

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .contactInfo)
        self.configureNavigationBar(title: Constants.contact.localized)
        let attributedString = NSMutableAttributedString(string: "By clicking on 'Send Message' you acknowledge having read our Privacy Notice and consent to receive additional information.".localized, attributes: [.font: Fonts.RptaSignage.twelve!])
        attributedString.addAttribute(.foregroundColor, value: Colors.green, range: NSRange(location: "By clicking on 'Send Message' you acknowledge having read our ".count, length: "Privacy notice".count))
        privacyNoticeLabel.attributedText = attributedString
        messageTextView.addDoneButton(self, selector: #selector(descriptionDoneTapped))
        messageTextView.delegate = self
        fullNameTextField.delegate = self
        contactNumberTextField.delegate = self
        emailTextField.delegate = self

        fullNameTextField.setAlignment()
        contactNumberTextField.setAlignment()
        emailTextField.setAlignment()
        topicTextField.setAlignment()
        messageTextView.setAlignment()
        privacyNoticeLabel.setAlignment()
        bindUI()
        configureObserver()
        viewModel.fetchUserProfile()
        topicTextField.text = Constants.selectTopic.localized
        self.disableLargeNavigationTitleCollapsing()
    }

    private func configureObserver() {
        viewModel.userData.bind { [weak self] data in
            DispatchQueue.main.async {
                self?.fullNameTextField.text = data?.fullName
                self?.contactNumberTextField.text = data?.mobileNumber
                self?.emailTextField.text = data?.emailAddress
            }
        }
    }

    func bindUI() {
        viewModel.isSentMail.bind { isSent in
            guard let isSent = isSent else {return}
            self.activityIndicator?.stopAnimating()
            self.view.isUserInteractionEnabled = true
            self.showCustomAlert(alertTitle: Constants.emailStatus, alertMessage: isSent ? Constants.emailSuccess : Constants.emailFailed, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }

    @objc private func descriptionDoneTapped() {
        self.view.endEditing(true)
    }

    @IBAction func proceedButtonPressed(sender: UIButton) {
        if let fullName = fullNameTextField.text, fullName.isNotEmpty,
           let contactNumber = contactNumberTextField.text, contactNumber.isNotEmpty,
           let emailAddress = emailTextField.text, emailAddress.isNotEmpty,
           let topic = topicTextField.text, topic.isNotEmpty,
           let description = messageTextView.text, description.isNotEmpty {
            if !Validation.shared.isValidEmail(email: emailAddress) {
                self.showCustomAlert(alertTitle: Constants.validationFailed,
                                     alertMessage: Constants.emailValidationError,
                                     firstActionTitle: ok,
                                     firstActionStyle: .cancel)
            } else if !Validation.shared.isValidPhone(phone: contactNumber) {
                self.showCustomAlert(alertTitle: Constants.validationFailed,
                                     alertMessage: Constants.contactValidationError,
                                     firstActionTitle: ok,
                                     firstActionStyle: .cancel)
            } else {
                if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                    return
                }
                let emailRequest = SendEmailRequest(from: "testing@gmail.com", to: "noreply.rcrc@gmail.com", subject: "Send Message - \(topic)", contentType: "text/html", content: "Full Name: \(fullName)\nContact Number: \(contactNumber)\nEmail Address: \(emailAddress)\nDescription: \(description)", attachmentId: "")
                activityIndicator = self.startActivityIndicator()
                self.view.isUserInteractionEnabled = false
                viewModel.emailSendRequest = emailRequest
                viewModel.performSendEmailRequest()
            }
        } else {
            self.showCustomAlert(alertTitle: "All fields are required", alertMessage: "Please enter all the required information and try again", firstActionTitle: ok, firstActionStyle: .default)
        }
    }

    @IBAction func selectTopicTapped(_ sender: UIButton) {
        self.picker = PickerWithDoneButton(pickerData: suggestionFeedback[0].subCategory, selected: selected)
        self.picker?.delegate = self
        self.view.addSubview(self.picker ?? UIView())
        self.picker?.pinEdgesToSuperView()
        self.picker?.viewHeight = self.view.bounds.height - 200
    }
}

extension ContactDetailViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == contactNumberTextField {
            /*let contactNumberText = contactNumberTextField.text ?? ""
            if !contactNumberText.isNotEmpty {
                contactNumberTextField.text = "+966 "
            }*/
            if textField == contactNumberTextField {
                if textField.text?.prefix(5) ?? "" != Constants.riyadhCountryCode {
                    textField.text = Constants.riyadhCountryCode
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
            if textField == contactNumberTextField {
                if updatedText.count < 5 || updatedText.count > 17 {
                    return false
                }
            }
        }
        return true
    }
}

extension ContactDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text, let textRange = Range(range, in: textViewText) {
            let updatedText = textViewText.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
}

extension ContactDetailViewController: PickerWithDoneButtonDelegate {

    func tappedOnShadow() {
        self.picker?.removeFromSuperview()
    }

    func doneTapped(at index: Int?, value: String?) {
        self.selectedData = value
        self.selected = index ?? -1
        self.topicTextField.text = value?.localized ?? topicTextField.text?.localized
        self.picker?.removeFromSuperview()
    }
}

class PaddedTextField: UITextField {

    let textFieldPadding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }
}

extension ContactDetailViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        guard error == nil else {
            self.dismiss(animated: true)
            return
        }
        switch result {
        case .saved:
            self.showToast("Email saved in Drafts")
        case .sent:
            self.showToast("Email sent successfully")
        case .failed:
            self.showToast("Unable to send email. Please try again.")
        case .cancelled:
            break
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
