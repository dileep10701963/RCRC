//
//  FaqFooterView.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 15/02/23.
//

import UIKit

enum faqSendQueryerror {
    case emptyEmail, invalidEmail, emptyData, emailSendStart, emailSendFinishSuccess, emailSendFinishFailure, uploadFailed, taskCancelled
}

protocol FaqFooterViewDelegate: AnyObject {
    func sendQueryAction()
    func mailAction(toMailID: String)
    func getAndSetMailID(mailID: String)
    func getPrivacyPolicyTapped()
    func sendQueryButtonTapped(error: faqSendQueryerror, successMessage: String)
    func footerTextViewDidBeginEditing(textView: UITextView) -> Bool
    func imageAttachementTapped()
    func labelAttachmentTapped()
    func removeAttachmentTapped()
    func viewAttachmentTapped()
}

class FaqFooterView: UITableViewHeaderFooterView {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var tollFreeValue: UILabel!
    @IBOutlet weak var assistanceView: UIView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet var arrayImageView: [UIImageView]!
    @IBOutlet weak var phoneLabel: UILabel!
    
    @IBOutlet weak var privacyNoticeLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: PaddedTextField!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var textViewBackground: UIImageView!
    
    @IBOutlet weak var labelFeedBack: UILabel!
    @IBOutlet weak var labelInquiry: UILabel!
    @IBOutlet weak var labelLostFound: UILabel!
    
    @IBOutlet weak var buttonFeedBack: UIButton!
    @IBOutlet weak var buttonInquiry: UIButton!
    @IBOutlet weak var buttonLostFound: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var imageAttachment: UIImageView!
    @IBOutlet weak var labelAttachment: UILabel!
    @IBOutlet weak var labelAttachmentName: UILabel!
    @IBOutlet weak var labelAttachmentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteAttachmentBtn: UIButton!
    @IBOutlet weak var deleteAttachmentHeightConstraint: NSLayoutConstraint!
    
    var contactViewModel = ContactViewModel()
    weak var delegate: FaqFooterViewDelegate?
    let sendQueryChatViewModel = SendQueryChatViewModel()
    var mailID: String = ""
    let myAccountViewModel = MyAccountViewModel()
    var reportData = IncidentModel()
    let reportIncidenceViewModel = ReportIncidenceViewModel()
    private var queryMessageForUpload: String = ""
    var fileUploadSendEmailCounter: Int = 0
    var isTaskCancelled: Bool = false
    
    var phoneText: String? {
        didSet {
            tollFreeValue.attributedText = NSMutableAttributedString(string: phoneText ?? emptyString, attributes: [NSAttributedString.Key.font: Fonts.CodecRegular.twentyTwo, .foregroundColor: Colors.borderGreen])
        }
    }
    
    var mailText: String? {
        didSet {
            // Do Something
        }
    }
    
    var didFetchContactDetails: Bool = false {
        didSet {
            if didFetchContactDetails {
                UIView.animate(withDuration: 0.6) {
                    self.contentView.layoutIfNeeded()
                }
                self.assistanceView.isHidden = false
                self.setNeedsLayout()
                self.layoutIfNeeded()
                let height = self.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                var frame = self.frame
                frame.size.height = height
                self.frame = frame
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        fetchContactDetails()
        configureUI()
        configureGestures()
        setupFooterData()
        bindUI()
        self.buttonFeedBack.isSelected = true
        
        if currentLanguage == .arabic {
            stackView.distribution = .fillEqually
        } else {
            stackView.distribution = .fill
        }
        
        self.labelAttachment.font = Fonts.CodecRegular.fourteen
        self.labelAttachment.text = Constants.attachFile.localized
        self.labelAttachment.setAlignment()
        
        self.labelAttachmentName.font = Fonts.CodecRegular.fourteen
        self.labelAttachmentName.text = ""
        self.labelAttachmentName.setAlignment()
        self.labelAttachmentName.translatesAutoresizingMaskIntoConstraints = false
        self.deleteAttachmentBtn.translatesAutoresizingMaskIntoConstraints = false
        self.labelAttachmentHeightConstraint.constant = 0
        self.deleteAttachmentHeightConstraint.constant = 0
        
        self.reportData.images = []
        self.reportData.videos = []
        self.reportData.mediaType = .none
        
        self.configureAttachmentView()
        self.sendEmailRequestAfterEmailUpload()
        self.endEditing(true)
    }
    
    private func configureAttachmentView(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FaqFooterView.tapFunctionForLabelAttachment(sender:)))
        labelAttachment.isUserInteractionEnabled = true
        labelAttachment.addGestureRecognizer(tapGesture)
        
        let tapGestureForImage = UITapGestureRecognizer(target: self, action: #selector(FaqFooterView.tapFunctionForImageAttachment(sender:)))
        imageAttachment.isUserInteractionEnabled = true
        imageAttachment.addGestureRecognizer(tapGestureForImage)
        
        let tapGestureForRemoveAttachment = UITapGestureRecognizer(target: self, action: #selector(FaqFooterView.tapFunctionForViewAttachment(sender:)))
        labelAttachmentName.isUserInteractionEnabled = true
        labelAttachmentName.addGestureRecognizer(tapGestureForRemoveAttachment)
    }
    
    @objc func tapFunctionForLabelAttachment(sender:UITapGestureRecognizer) {
        delegate?.labelAttachmentTapped()
    }
    
    @objc func tapFunctionForImageAttachment(sender:UITapGestureRecognizer) {
        delegate?.imageAttachementTapped()
    }
    
    @objc func tapFunctionForViewAttachment(sender:UITapGestureRecognizer) {
        delegate?.viewAttachmentTapped()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    private func setupFooterData() {
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
        
        textViewBackground.image = textViewBackground.image?.setNewImageAsPerLanguage()
        
        if mailID == "" {
            mailID = "customercare@riyadhbus.sa"
        }
    }
    
    private func configureUI() {
        
        labelInquiry.text = Constants.inquiry.localized
        labelFeedBack.text = Constants.feedBack.localized
        labelLostFound.text = Constants.lostFound.localized
        
        labelInquiry.font = Fonts.CodecRegular.fourteen
        labelFeedBack.font = Fonts.CodecRegular.fourteen
        labelLostFound.font = Fonts.CodecRegular.fourteen
        
        labelInquiry.setAlignment()
        labelFeedBack.setAlignment()
        labelLostFound.setAlignment()
        
        emailLabel.text = Constants.bySendingMessage.localized
        emailLabel.setAlignment()
        
        proceedButton.setBackgroundImage(Images.button_dark_light?.setNewImageAsPerLanguage(), for: .normal)
        let profileInfo = UserProfileDataRepository.shared.fetchAll()?.first
        var emailID : String = ""
        if let profileInfo = profileInfo {
            emailID = profileInfo.emailAddress ?? emptyString
        } else if let profile = ServiceManager.sharedInstance.profileModel {
            emailID = profile.mail ?? emptyString
        }
        
        emailAddressTextField.text = emailID
        emailAddressTextField.setAlignment()
        emailAddressTextField.attributedPlaceholder = NSMutableAttributedString(string: Constants.yourEmailAddress.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.seventeen])
        if currentLanguage == .arabic {
            messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.seventeen])
        } else if currentLanguage == .english {
            messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
        }
        messageTextView.setAlignment()
        emailAddressTextField.delegate = self
        messageTextView.delegate = self
        
        let proceedButtonString = NSMutableAttributedString(string: Constants.sendMessage.localized, attributes: [NSAttributedString.Key.foregroundColor : Colors.white, .font: Fonts.CodecRegular.eighteen])
        proceedButton.setAttributedTitle(proceedButtonString, for: .normal)
        
    }
    
    private func configureGestures() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.privacyNoticeLabelTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        privacyNoticeLabel.isUserInteractionEnabled = true
        privacyNoticeLabel.addGestureRecognizer(tapGesture )
        privacyNoticeLabel.tag = 1
    }
    
    @objc func privacyNoticeLabelTapped(_ sender: UITapGestureRecognizer) {
        self.delegate?.getPrivacyPolicyTapped()
    }
    
    @IBAction func buttonFeedBackInquiryLostFoundTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            buttonLostFound.isSelected = false
            buttonInquiry.isSelected = false
            buttonFeedBack.isSelected = true
        case 1:
            buttonLostFound.isSelected = false
            buttonInquiry.isSelected = true
            buttonFeedBack.isSelected = false
        case 2:
            buttonLostFound.isSelected = true
            buttonInquiry.isSelected = false
            buttonFeedBack.isSelected = false
        default:
            break
        }
    }
    
    
    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        if !Validation.shared.checkEmptyField(field: self.emailAddressTextField.text ?? "") {
            delegate?.sendQueryButtonTapped(error: .emptyEmail, successMessage: emptyString)
        } else if !Validation.shared.isValidEmail(email: self.emailAddressTextField.text ?? "") {
            delegate?.sendQueryButtonTapped(error: .invalidEmail, successMessage: emptyString)
        } else if messageTextView.attributedText.string == NSMutableAttributedString(string: Constants.typeYourMessage.localized).string || !Validation.shared.checkEmptyField(field: self.messageTextView.text ?? "") {
            delegate?.sendQueryButtonTapped(error: .emptyData, successMessage: emptyString)
        } else {
            if !Utilities.Connectivity.isConnectedToInternet(viewController: nil) {
                return
            }
            self.sendEmailWithQuery(queryMessage: messageTextView.text ?? "")
        }
    }
    
    func sendEmailWithQuery(queryMessage: String) {
        if reportData.images.count > 0 || reportData.videos.count > 0 {
            queryMessageForUpload = queryMessage
            switch reportData.mediaType {
            case .image:
                if reportData.images.count > 0 {
                    self.delegate?.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                    let uploadRequest = FileUploadRequest(fileName: "Image-File\(Date.currentTimeStamp.string)", fileContent: reportData.images[0].convertToBase64String())
                    reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
                } else if reportData.videos.count > 0 {
                    self.delegate?.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                    let uploadRequest = FileUploadRequest(fileName: "Video-File\(Date.currentTimeStamp.string)", fileContent: reportData.videos[0].convertToBase64String())
                    reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
                } else {
                    print("Error Else execute")
                }
            case .video:
                self.delegate?.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                let uploadRequest = FileUploadRequest(fileName: "Video-File\(Date.currentTimeStamp.string)", fileContent: reportData.videos[0].convertToBase64String())
                reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
            default:
                break
            }
        } else {
            let mailSubject = buttonFeedBack.isSelected ? Constants.feedBack.localized : buttonInquiry.isSelected ? Constants.inquiry.localized: Constants.lostFound.localized
            self.delegate?.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
            let emailRequest = SendEmailRequest(from: self.emailAddressTextField.text ?? "", to: mailID, subject: mailSubject, contentType: "text/html", content: queryMessage, attachmentId: nil)
            sendQueryChatViewModel.emailSendRequest = emailRequest
            sendQueryChatViewModel.performSendEmailRequest()
        }
    }
    
    func sendEmailRequestAfterEmailUpload() {
        reportIncidenceViewModel.uploadStatus.bind { uploadStatus in
            guard let uploadStatus = uploadStatus else {return}
            if uploadStatus.hasUploaded {
                DispatchQueue.main.async {
                    self.sendEmailForFileUpload()
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.sendQueryButtonTapped(error: self.isTaskCancelled ? .taskCancelled: .uploadFailed, successMessage: emptyString)
                }
            }
        }
    }
    
    private func sendEmailForFileUpload() {
        fileUploadSendEmailCounter += 1
        let mailSubject = self.buttonFeedBack.isSelected ? Constants.feedBack.localized : self.buttonInquiry.isSelected ? Constants.inquiry.localized: Constants.lostFound.localized
        let emailRequest = SendEmailRequest(from: self.emailAddressTextField.text ?? "", to: self.mailID, subject: mailSubject, contentType: "text/html", content: self.queryMessageForUpload, attachmentId: self.reportIncidenceViewModel.attachedFileName)
        self.sendQueryChatViewModel.emailSendRequest = emailRequest
        self.sendQueryChatViewModel.performSendEmailRequest()
    }
    
    func bindUI() {
        sendQueryChatViewModel.isSentMail.bind { isSent in
            guard let isSent = isSent else {return}
            DispatchQueue.main.async {
                if isSent {
                    self.emailAddressTextField.resignFirstResponder()
                    self.messageTextView.resignFirstResponder()
                    self.emailAddressTextField.text = ""
                    self.messageTextView.text = ""
                    if currentLanguage == .arabic {
                        self.messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.seventeen])
                    } else if currentLanguage == .english {
                        self.messageTextView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
                    }
                    self.messageTextView.setAlignment()
                }
            }
            
            if self.reportIncidenceViewModel.attachedFileName != emptyString && isSent == false {
                if self.fileUploadSendEmailCounter == 6 {
                    self.fileUploadSendEmailCounter = 0
                    let mailSuccessMessage = self.buttonFeedBack.isSelected ? Constants.feedBackSuccessMessage.localized : self.buttonInquiry.isSelected ? Constants.inquirySuccessMessage.localized: Constants.lostFoundSuccessMessage.localized
                    self.delegate?.sendQueryButtonTapped(error: self.isTaskCancelled ? .taskCancelled: isSent ? .emailSendFinishSuccess: .emailSendFinishFailure, successMessage: mailSuccessMessage)
                } else {
                    self.sendEmailForFileUpload()
                }
                
            } else {
                let mailSuccessMessage = self.buttonFeedBack.isSelected ? Constants.feedBackSuccessMessage.localized : self.buttonInquiry.isSelected ? Constants.inquirySuccessMessage.localized: Constants.lostFoundSuccessMessage.localized
                self.delegate?.sendQueryButtonTapped(error: self.isTaskCancelled ? .taskCancelled: isSent ? .emailSendFinishSuccess: .emailSendFinishFailure, successMessage: mailSuccessMessage)
            }
        }
    }
    
    @IBAction func sendQueryAction(_ sender: UIButton) {
        delegate?.sendQueryAction()
    }
    
    @IBAction func phoneTapped(_ sender: UIButton) {
        if let phoneText = phoneText {
            var formattedNumber = phoneText.components(separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
            
            if formattedNumber.isArabic {
                formattedNumber = formattedNumber.convertArabicNumberToEnglish()
            }
            
            if let url = URL(string: "tel:\(formattedNumber)"){
                if #available(iOS 10.0, *) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                    }
                } else {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }
    }
    
    @IBAction func emailTapped(_ sender: UIButton) {
        delegate?.mailAction(toMailID: mailText ?? emptyString)
    }
    
    func fetchContactDetails() {
        
        //assistanceView.isHidden = true
        self.phoneText = "--"
        
        if !Utilities.Connectivity.isConnectedToInternet(viewController: nil) {
            return
        }
        
        contactViewModel.fetchContactDetails()
        contactViewModel.contactDetails.bind({ contactModel, error in
            if let result = contactModel, error == nil {
                guard let item = result.items.first else { return }
                DispatchQueue.main.async {
                    self.didFetchContactDetails = true
                    self.phoneText = (item?.contentFields[safe: 0]??.contentFieldValue?.data ?? "")
                    self.mailText = (item?.contentFields[safe: 1]??.contentFieldValue?.data ?? "")
                    self.delegate?.getAndSetMailID(mailID: self.mailText ?? emptyString)
                }
            } else if let _ = error {
            }
        })
    }
    
    @IBAction func deleteAttachmentTapped(_ sender: UIButton) {
        delegate?.removeAttachmentTapped()
    }
    
}

extension String {
    
    func convertArabicNumberToEnglish() -> String {
        
        let latinString = self.applyingTransform(StringTransform.toLatin, reverse: false)
        if let latinString = latinString {
            let englishNumber = String(latinString.reversed())
            return englishNumber
        } else {
            return emptyString
        }
    }
}

extension FaqFooterView: UITextFieldDelegate, UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
                
        let newString = (textView.text! as NSString).replacingCharacters(in: range, with: text) as NSString
        if newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 {
            
            if let textViewText = textView.text, let textRange = Range(range, in: textViewText) {
                let updatedText = textViewText.replacingCharacters(in: textRange, with: text)
                if updatedText.containsEmoji || updatedText.containsAnyEmoji || updatedText.count > 120 {
                    return false
                }
            }
            return true
        } else {
            return false
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return ((delegate?.footerTextViewDidBeginEditing(textView: textView)) != nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.placeHolderGray {
            textView.attributedText = nil
            textView.textColor = Colors.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let textViewText = textView.attributedText, textViewText == NSMutableAttributedString(string: "") {
            if currentLanguage == .arabic {
                textView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.seventeen])
            } else if currentLanguage == .english {
                textView.attributedText = NSMutableAttributedString(string: Constants.typeYourMessage.localized, attributes: [.foregroundColor: Colors.placeHolderGray, .font: Fonts.CodecRegular.eighteen])
            }
            textView.textColor = Colors.placeHolderGray
            textView.setAlignment()
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}
