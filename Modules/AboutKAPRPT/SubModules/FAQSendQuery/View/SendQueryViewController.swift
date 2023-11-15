//
//  SendQueryViewController.swift
//  RCRC
//
//  Created by Errol on 09/04/21.
//

import UIKit

class SendQueryViewController: ContentViewController {

    @IBOutlet weak var privacyNoticeLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: PaddedTextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendQueryTitleLabel: UILabel!
    let sendQueryChatViewModel = SendQueryChatViewModel()
    var activityIndicator: UIActivityIndicatorView?
    @IBOutlet var arrayImageView: [UIImageView]!
    var mailID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .sendQuery)
        
        configureUI()
        configureGestures()
        bindUI()
        
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        let proceedButtonString = NSMutableAttributedString(string: Constants.sendMessage.localized, attributes: [NSAttributedString.Key.foregroundColor : Colors.white, .font: Fonts.CodecRegular.eighteen])
        proceedButton.setAttributedTitle(proceedButtonString, for: .normal)
        self.view.endEditing(true)
    }
    
    func fetchPrivacyPolicy() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = startActivityIndicator()
        sendQueryChatViewModel.getPrivacyPolicy()
        sendQueryChatViewModel.privacyPolicyResult.bind { [weak self] model, error in
            if model != nil || error != nil {
                if let self = self {
                    self.activityIndicator?.stop()
                    if let model = model {
                        DispatchQueue.main.async {
                            let content = self.sendQueryChatViewModel.getAttributedString(model: model)
                            if let privacyContent = content {
                                self.showScrollableAlertWithAttributedContent(alertTitle: Constants.privacyPolicyTitle.localized, alertMessage: privacyContent) {
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fetchPrivacyPolcyLineButtonTapped() {
        if let model = self.sendQueryChatViewModel.privacyPolicyResult.value {
            let isArabicContentWithData = sendQueryChatViewModel.isArabicContentWithData(model: model)
            switch isArabicContentWithData.isStringEmpty {
            case true:
                fetchPrivacyPolicy()
            case false:
                if isArabicContentWithData.isArabic == true && currentLanguage == .arabic {
                    let content = sendQueryChatViewModel.getAttributedString(model: model)
                    if let privacyContent = content {
                        self.showScrollableAlertWithAttributedContent(alertTitle: Constants.privacyPolicyTitle.localized, alertMessage: privacyContent) {
                            DispatchQueue.main.async {
                                // Do Something
                            }
                        }
                    }
                } else if isArabicContentWithData.isArabic == false && currentLanguage == .english {
                    let content = self.sendQueryChatViewModel.getAttributedString(model: model)
                    if let privacyContent = content {
                        self.showScrollableAlertWithAttributedContent(alertTitle: Constants.privacyPolicyTitle.localized, alertMessage: privacyContent) {
                            DispatchQueue.main.async {
                                // Do Something
                            }
                        }
                    }
                } else {
                    fetchPrivacyPolicy()
                }
            }
            
        } else {
            fetchPrivacyPolicy()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: emptyString.localized)
        
        let arabics = "سياسة الخصوصية والبيانات"
        
        let range = (Constants.privacyNoticeMessage.localized as NSString).range(of: currentLanguage == .arabic ? arabics: Constants.privacyPolicyTitle.localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let mutableAttributedString = NSMutableAttributedString.init(string: Constants.privacyNoticeMessage.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.privacyNoticeGray, .font: Fonts.CodecRegular.thirteen, .paragraphStyle: paragraphStyle])
        mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: Colors.newGreen, .font: Fonts.CodecBold.thirteen], range: range)
        privacyNoticeLabel.attributedText = mutableAttributedString
        if currentLanguage == .arabic {
            privacyNoticeLabel.textAlignment = .center
        } else if currentLanguage == .english {
            privacyNoticeLabel.textAlignment = .left
        }
        if mailID == "" {
            mailID = "customercare@riyadbus.sa" //"noreply.rcrc@gmail.com"
        }
    }
    
    private func configureUI() {
        proceedButton.setBackgroundImage(Images.button_dark_light?.setNewImageAsPerLanguage(), for: .normal)
        sendQueryTitleLabel.attributedText = NSMutableAttributedString(string: Constants.sendQuery.localized, attributes: [NSAttributedString.Key.foregroundColor : Colors.black, .font : Fonts.CodecBold.eighteen])
        let profileInfo = UserProfileDataRepository.shared.fetchAll()?.first
        var emailID : String = ""
        if let profileInfo = profileInfo {
            emailID = profileInfo.emailAddress ?? emptyString
        } else if let profile = ServiceManager.sharedInstance.profileModel {
            emailID = profile.mail ?? emptyString
        }
        
        emailAddressTextField.text = emailID
        emailAddressTextField.setAlignment()
        emailAddressTextField.attributedPlaceholder = NSMutableAttributedString(string: Constants.yourEmailAddress.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
        messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
        messageTextView.setAlignment()
        emailAddressTextField.delegate = self
        messageTextView.delegate = self
    }
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        if !Validation.shared.checkEmptyField(field: self.emailAddressTextField.text ?? "") {
            self.showCustomAlert(alertTitle: ""/*Constants.validationFailed.localized*/,
                                 alertMessage: Constants.emailMissing.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        } else if !Validation.shared.isValidEmail(email: self.emailAddressTextField.text ?? "") {
            self.showCustomAlert(alertTitle: ""/*Constants.validationFailed.localized*/,
                                 alertMessage: Constants.emailValidationError.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        } else if messageTextView.attributedText.string == NSMutableAttributedString(string: Constants.typeYourMessage.localized).string || !Validation.shared.checkEmptyField(field: self.messageTextView.text ?? "") {
            self.showCustomAlert(alertTitle: ""/*Constants.validationFailed.localized*/,
                                 alertMessage: Constants.messageMissing.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        } else {
            if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                return
            }
            sendQueryChatViewModel.sendMessage(messageTextView.text)
            self.sendEmailWithQuery(queryMessage: messageTextView.text ?? "")
        }
    }
    
    private func configureGestures() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.privacyNoticeLabelTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        privacyNoticeLabel.isUserInteractionEnabled = true
        privacyNoticeLabel.addGestureRecognizer(tapGesture )
        privacyNoticeLabel.tag = 1
    }
    
    @objc func privacyNoticeLabelTapped(_ sender: UITapGestureRecognizer) {

        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        guard let view = sender.view else {
            return
        }
        switch view.tag {
        case 1:
            self.fetchPrivacyPolcyLineButtonTapped()
            
            /*guard let url = URL(string: "telprompt://\(phoneText ?? emptyString)"),
                UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)*/
        default:
            return
        }
    }
    
    func sendEmailWithQuery(queryMessage: String) {
        let emailRequest = SendEmailRequest(from: self.emailAddressTextField.text ?? "", to: mailID, subject: Constants.userQuery.localized, contentType: "text/html", content: queryMessage, attachmentId: nil)
        activityIndicator = self.startActivityIndicator()
        self.disableUserInteractionWhenAPICalls()
        sendQueryChatViewModel.emailSendRequest = emailRequest
        sendQueryChatViewModel.performSendEmailRequest()
    }
    
    func bindUI() {
        sendQueryChatViewModel.isSentMail.bind { isSent in
            guard let isSent = isSent else {return}
            self.activityIndicator?.stop()
            self.enableUserInteractionWhenAPICalls()
            self.emailAddressTextField.text = ""
            self.messageTextView.text = ""
            self.showCustomAlert(alertTitle: emptyString, alertMessage: isSent ? Constants.emailSuccess.localized : Constants.emailFailed.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                //self.navigationController?.popViewController(animated: true)
                DispatchQueue.main.async {
                    if isSent {
                        self.emailAddressTextField.resignFirstResponder()
                        self.messageTextView.resignFirstResponder()
                        self.emailAddressTextField.text = ""
                        self.messageTextView.text = ""
                        self.messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
                        self.messageTextView.setAlignment()
                        if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                            let selectedController = viewControllers[0]
                            self.tabBarController?.selectedViewController = selectedController
                        }
                    }
                }
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SendQueryViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        if newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 {
            
            if let textViewText = textView.text, let textRange = Range(range, in: textViewText) {
                let updatedText = textViewText.replacingCharacters(in: textRange, with: text)
                
                if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.placeHolderGray {
            textView.attributedText = nil
            textView.textColor = Colors.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let textViewText = textView.attributedText, textViewText == NSMutableAttributedString(string: "") {
            textView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
            textView.textColor = Colors.placeHolderGray
            textView.setAlignment()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
}
