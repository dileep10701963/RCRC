//
//  FrequentlyAskedQuestionViewController.swift
//  RCRC
//
//  Created by anand madhav on 11/08/20.
//

import UIKit
import MessageUI

class FrequentlyAskedQuestionViewController: ContentViewController {
    
    @IBOutlet weak var faqTableView: UITableView!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var faqView: UIView!
    
    var activityIndicator: UIActivityIndicatorView?
    var selectedIndexPath: IndexPath?
    let frequentlyAskedQuestionViewModel = FrequentlyAskedQuestionViewModel()
    var contactViewModel = ContactViewModel()
    var setRootView: Bool = true
    let myAccountViewModel = MyAccountViewModel()
    var reportData = IncidentModel()
    let reportIncidenceViewModel = ReportIncidenceViewModel()
    
    var privacyPolicyResult: Observable<LanguageSelectionModel?, Error?> = Observable(nil, nil)
    let sendQueryChatViewModel = SendQueryChatViewModel()
    var activityIndicatorFooter: UIActivityIndicatorView?
    fileprivate var mediaPicker: MediaPickerController!
    
    private let mailID = "customercare@riyadhbus.sa"
    private var queryMessageForUpload: String = ""
    var fileUploadSendEmailCounter: Int = 0
    var isTaskCancelled: Bool = false
    // ContactUS
    
    @IBOutlet weak var tollFreeValue: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var privacyNoticeLabel: UILabel!
    @IBOutlet weak var emailAddressTextField: PaddedTextField!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var labelFeedBack: UILabel!
    @IBOutlet weak var labelInquiry: UILabel!
    @IBOutlet weak var labelLostFound: UILabel!
    
    @IBOutlet weak var buttonFeedBack: UIButton!
    @IBOutlet weak var buttonInquiry: UIButton!
    @IBOutlet weak var buttonLostFound: UIButton!
    
    var phoneText: String? {
        didSet {
            tollFreeValue.attributedText = NSMutableAttributedString(string: phoneText ?? emptyString, attributes: [NSAttributedString.Key.font: Fonts.CodecRegular.twentyTwo, .foregroundColor: Colors.borderGreen])
        }
    }
    
    var contactUsMailID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .faq)
        configureTableView()
        self.disableLargeNavigationTitleCollapsing()
        mediaPicker = MediaPickerController(viewController: self)
        configureGestures()
        emailAddressTextField.setAlignment()
        messageTextView.setAlignment()
        self.segmentControl.setTitle("DSContactUS".localized, forSegmentAt: 0)
        self.segmentControl.setTitle("DSFAQ".localized, forSegmentAt: 1)
        self.bindUI()
        phoneText = "19933"
        tollFreeValue.setAlignment()
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        fetchFaqList {
            self.fetchProfileDetailOnFAQScreen()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let arabics = "سياسة الخصوصية والبيانات"
        let range = (Constants.privacyNoticeMessage.localized as NSString).range(of: currentLanguage == .arabic ? arabics: Constants.privacyPolicyTitle.localized)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let mutableAttributedString = NSMutableAttributedString.init(string: Constants.privacyNoticeMessage.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.privacyNoticeGray, .font: Fonts.CodecRegular.thirteen, .paragraphStyle: paragraphStyle])
        mutableAttributedString.addAttributes([NSAttributedString.Key.foregroundColor: Colors.black, .font: Fonts.CodecBold.twelve], range: range)
        privacyNoticeLabel.attributedText = mutableAttributedString
        if currentLanguage == .arabic {
            privacyNoticeLabel.textAlignment = .center
        } else if currentLanguage == .english {
            privacyNoticeLabel.textAlignment = .left
        }
        fetchProfileDetails()
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
    
    @IBAction func contactFaqsSegmentedControllAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.transition(with: faqView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.contactView.isHidden = false
                self.faqView.isHidden = true
                self.faqTableView.isHidden = true
            })
            
        case 1:
            UIView.transition(with: contactView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.faqView.isHidden = false
                self.faqTableView.isHidden = false
                self.contactView.isHidden = true
            })
        default:
            break
        }
    }
    
    private func fetchProfileDetailOnFAQScreen() {
        if AppDefaults.shared.isUserLoggedIn && (ServiceManager.sharedInstance.profileModel == nil || ServiceManager.sharedInstance.profileModel?.mail == nil || ServiceManager.sharedInstance.profileModel?.mail == "") {
            self.fetchProfileDetails()
        }
    }
    
    private func fetchProfileDetails() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        myAccountViewModel.fetchProfileDetails()
        myAccountViewModel.profileDetailsResult.bind{ [weak self] (profile, error) in
            DispatchQueue.main.async {
                if profile != nil || error != nil {
                    if self != nil {
                        if let profile = profile {
                            ServiceManager.sharedInstance.profileModel = profile
                            if profile.mail != nil {
                                self?.emailAddressTextField.text = profile.mail
                            } else {
                                self?.emailAddressTextField.text = "info@gmail.com"
                            }
                        } else {
                            if let error = error as? NetworkError {
                                if error == .invalidToken || error == .notLoggedIn {
                                    self?.retryLogin()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func retryLogin() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        AuthenticationService.retryLogin { [weak self] (result) in
            switch result {
            case .success:
                self?.fetchProfileDetails()
            case .failure:
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.privacyNoticeLabelTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        privacyNoticeLabel.isUserInteractionEnabled = true
        privacyNoticeLabel.addGestureRecognizer(tapGesture )
        privacyNoticeLabel.tag = 1
    }
    
    @objc func privacyNoticeLabelTapped(_ sender: UITapGestureRecognizer) {
        self.getPrivacyPolicyTapped()
    }
    
    @IBAction func buttonFeedBackInquiryLostFoundTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            buttonFeedBack.setImage(UIImage(named: "selected-green"), for: .selected)
            buttonInquiry.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonLostFound.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonLostFound.isSelected = false
            buttonInquiry.isSelected = false
            buttonFeedBack.isSelected = true
        case 1:
            buttonInquiry.setImage(UIImage(named: "selected-green"), for: .selected)
            buttonFeedBack.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonLostFound.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonLostFound.isSelected = false
            buttonInquiry.isSelected = true
            buttonFeedBack.isSelected = false
        case 2:
            buttonLostFound.setImage(UIImage(named: "selected-green"), for: .selected)
            buttonInquiry.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonFeedBack.setImage(UIImage(named: "deselected-green"), for: .normal)
            buttonLostFound.isSelected = true
            buttonInquiry.isSelected = false
            buttonFeedBack.isSelected = false
        default:
            break
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }

    }

    @objc func keyboardWillHide(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        SSLRestConfig.manager.session.getAllTasks { sslRestConfig in
            if sslRestConfig.count > 0 {
                if sslRestConfig[0].currentRequest?.description.contains("sendemail") ?? false || sslRestConfig[0].currentRequest?.description.contains("fileupload") ?? false {
                    DispatchQueue.main.async {
                        if let tableFooterView = self.faqTableView.tableFooterView, tableFooterView.isKind(of: FaqFooterView.self) {
                            if let footerView = tableFooterView as? FaqFooterView {
                                footerView.fileUploadSendEmailCounter = 0
                                footerView.isTaskCancelled = true
                                sslRestConfig.forEach({$0.cancel()})
                            }
                        }
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let footer = faqTableView.tableFooterView {
            let newSize = footer.systemLayoutSizeFitting(CGSize(width: faqTableView.bounds.width, height: 0))
            footer.frame.size.height = newSize.height
        }
    }
    
    private func configureTableView() {
        faqTableView.rowHeight = UITableView.automaticDimension
        faqTableView.estimatedRowHeight = 44
        self.faqTableView.register(FAQTableViewCell.nib, forCellReuseIdentifier: FAQTableViewCell.identifier)
        self.faqTableView.register(DescriptionTableViewCell.nib, forCellReuseIdentifier: DescriptionTableViewCell.identifier)
        faqTableView.delegate = self
        faqTableView.dataSource = self
        self.faqView.isHidden = true
        self.faqTableView.isHidden = true
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
                    self.sendQueryButtonTapped(error: self.isTaskCancelled ? .taskCancelled: isSent ? .emailSendFinishSuccess: .emailSendFinishFailure, successMessage: mailSuccessMessage)
                } else {
                    self.sendEmailForFileUpload()
                }
                
            } else {
                let mailSuccessMessage = self.buttonFeedBack.isSelected ? Constants.feedBackSuccessMessage.localized : self.buttonInquiry.isSelected ? Constants.inquirySuccessMessage.localized: Constants.lostFoundSuccessMessage.localized
                self.sendQueryButtonTapped(error: self.isTaskCancelled ? .taskCancelled: isSent ? .emailSendFinishSuccess: .emailSendFinishFailure, successMessage: mailSuccessMessage)
            }
        }
    }
    
    func fetchFaqList(completion: @escaping () -> Void) {
        
        activityIndicator?.stop()
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = self.startActivityIndicator()
        frequentlyAskedQuestionViewModel.getFAQ()
        frequentlyAskedQuestionViewModel.faqResult.bind { [weak self] result, error in
            if let self = self {
                DispatchQueue.main.async {
                    if error != nil || result != nil {
                        self.activityIndicator?.stop()
                        if error != nil {
                            self.faqTableView.setEmptyMessage(Constants.noRecordsFound.localized)
                            completion()
                        } else if result != nil {
                            self.faqTableView.reloadData()
                            completion()
                        }
                    }
                }
            } else {
                completion()
            }
        }
    }
    
}

extension FrequentlyAskedQuestionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return frequentlyAskedQuestionViewModel.numberOfSection() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == selectedIndexPath?.section {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell: FAQTableViewCell? = tableView.dequeueReusableCell(withIdentifier: FAQTableViewCell.identifier, for: indexPath) as? FAQTableViewCell
            cell?.configure(title: frequentlyAskedQuestionViewModel.setQuestionText(indexPath: indexPath), selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath)
            return cell ?? UITableViewCell()
        } else {
            let cell: DescriptionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.identifier, for: indexPath) as? DescriptionTableViewCell
            let answerContent = frequentlyAskedQuestionViewModel.setAnswerText(indexPath: indexPath)
            cell?.configure(answerContent.answer, linkText: answerContent.link)
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == faqTableView {
            self.view.endEditing(true)
            
            if indexPath.section == selectedIndexPath?.section && indexPath.row == 1 {
                let answerContent = frequentlyAskedQuestionViewModel.setAnswerText(indexPath: indexPath)
                if answerContent.link != emptyString {
                    if answerContent.link == "schedules" {
                        if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                            let selectedController = viewControllers[1]
                            self.tabBarController?.selectedViewController = selectedController
                        }
                    } else if answerContent.link == "sendquery" {
                        // Do Something
                    }
                }
            } else {
                if selectedIndexPath?.section == indexPath.section {
                    selectedIndexPath = IndexPath(row: -1, section: -1)
                } else {
                    selectedIndexPath = indexPath
                }
                tableView.deselectRow(at: indexPath, animated: true)
                tableView.reloadData()
            }
        }
    }
}
extension FrequentlyAskedQuestionViewController: FaqFooterViewDelegate {
    
    func footerTextViewDidBeginEditing(textView: UITextView) -> Bool {
        
        if let superView = textView.superview {
            let pointInTable:CGPoint = superView.convert(textView.frame.origin, to: faqTableView)
            faqTableView.contentOffset = CGPoint(x: faqTableView.contentOffset.x, y: pointInTable.y - 42)
            return true
        } else {
            return true
        }
        
    }
    
    func mailAction(toMailID: String) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients([toMailID])
            self.present(composeVC, animated: true)
        } else {
            if let appURL = URL(string: "mailto:\(toMailID)") {
                if UIApplication.shared.canOpenURL(appURL) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(appURL)
                    }
                }
            }
        }
    }
    
    func sendQueryAction() {
        let sendQuery: SendQueryViewController = SendQueryViewController.instantiate(appStoryboard: .sendQuery)
        sendQuery.mailID = contactUsMailID
        self.navigationController?.pushViewController(sendQuery, animated: true)
    }
    
    func getAndSetMailID(mailID: String) {
        contactUsMailID = mailID
    }
    
    func getPrivacyPolicyTapped() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: nil) {
            return
        }
        
        self.fetchPrivacyPolcyLineButtonTapped()
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
    
    func fetchPrivacyPolicy() {
        
        self.activityIndicatorFooter = startActivityIndicator()
        sendQueryChatViewModel.getPrivacyPolicy()
        sendQueryChatViewModel.privacyPolicyResult.bind { [weak self] model, error in
            if model != nil || error != nil {
                if let self = self {
                    self.activityIndicatorFooter?.stop()
                    if let model = model {
                        DispatchQueue.main.async {
                            let content = self.sendQueryChatViewModel.getAttributedString(model: model)
                            if let privacyContent = content {
                                self.showScrollableAlertWithAttributedContent(alertTitle: Constants.privacyPolicyTitle.localized, alertMessage: privacyContent)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendQueryButtonTapped(error: faqSendQueryerror, successMessage: String) {
        
        switch error {
        case .emptyEmail:
            self.showCustomAlert(alertTitle: "",
                                 alertMessage: Constants.emailMissing.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        case .invalidEmail:
            self.showCustomAlert(alertTitle: "",
                                 alertMessage: Constants.emailValidationError.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        case .emptyData:
            self.showCustomAlert(alertTitle: "",
                                 alertMessage: Constants.messageMissing.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .default)
        case .emailSendStart:
            self.activityIndicatorFooter = startActivityIndicator()
        case .emailSendFinishSuccess:
            self.activityIndicatorFooter?.stop()
            self.showCustomAlert(alertTitle: emptyString, alertMessage: successMessage, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                DispatchQueue.main.async {
                    if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                        let selectedController = viewControllers[0] as? UINavigationController
                        self.tabBarController?.selectedViewController = selectedController
                        selectedController?.setViewControllers([HomeViewController.instantiate(appStoryboard: .home)], animated: false)
                    }
                }
            })
            
        case .emailSendFinishFailure:
            self.activityIndicatorFooter?.stop()
            self.showCustomAlert(alertTitle: emptyString, alertMessage: Constants.emailFailed.localized, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                // Do Something
            })
        case .uploadFailed:
            self.activityIndicatorFooter?.stop()
            self.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                                 alertMessage: Constants.serverErrorAlertMessage.localized,
                                 firstActionTitle: ok,
                                 firstActionHandler: nil)
        case .taskCancelled:
            if let tableFooterView = faqTableView.tableFooterView, tableFooterView.isKind(of: FaqFooterView.self) {
                if let footerView = tableFooterView as? FaqFooterView {
                    footerView.isTaskCancelled = false
                }
            }
        }
    }
    
    func imageAttachementTapped() {
        mediaPicker.loadMedia(completion: handleMediaSelection)
    }
    
    func labelAttachmentTapped() {
        mediaPicker.loadMedia(completion: handleMediaSelection)
    }
    
    private func handleMediaSelection(media: Media) {
        switch media {
        case let .image(image):
            handleImageSelection(image: image)
        case let .video(video, thumbnail):
            //            handleVideoSelection(video: video, thumbnail: thumbnail)
            return
        }
    }
    
    private func handleImageSelection(image: UIImage) {
        print("Image Size :- \(image.getFileSize())")
        if image.getFileSize() > 0.500 {
            let compressedImage = image.compressedData()
            if var data = compressedImage {
                //                let image = UIImage(data: data)
                print("Image Size Data :- \(data.getFileSize())")
                if data.getFileSize() > 0.500 {
                    if let image = UIImage(data: data), let compressedImageData = image.compressTo(bytes: 500) {
                        data = compressedImageData
                        print("Image Size Data ***JPEG**** :- \(data.getFileSize())")
                        
                    }
                }
                reportData.images = []
                reportData.videos = []
                reportData.mediaType = .image
                reportData.videos.append(data as! NSData ?? NSData())
                
            }
        } else {
            reportData.images = []
            reportData.videos = []
            reportData.mediaType = .image
            reportData.images.append(image)
        }
        
        if let tableFooterView = faqTableView.tableFooterView, tableFooterView.isKind(of: FaqFooterView.self) {
            if let footerView = tableFooterView as? FaqFooterView, footerView.emailAddressTextField != nil {
                if reportData.images.count > 0 || reportData.videos.count > 0 {
                    footerView.reportData = reportData
                    footerView.labelAttachmentName.attributedText = attachmentNameWithIcon()
                    footerView.labelAttachmentHeightConstraint.constant = 21
                    footerView.deleteAttachmentHeightConstraint.constant = 16
                } else {
                    footerView.labelAttachmentName.text = ""
                    footerView.labelAttachmentHeightConstraint.constant = 0
                    footerView.deleteAttachmentHeightConstraint.constant = 0
                }
            }
        }
        
    }

    private func handleVideoSelection(video: NSData, thumbnail: UIImage) {
        
        reportData.images = []
        reportData.videos = []
        reportData.mediaType = .video
        reportData.videos.append(video)
        
        if let tableFooterView = faqTableView.tableFooterView, tableFooterView.isKind(of: FaqFooterView.self) {
            if let footerView = tableFooterView as? FaqFooterView, footerView.emailAddressTextField != nil {
                if reportData.videos.count > 0 {
                    footerView.reportData = reportData
                    footerView.labelAttachmentName.attributedText = attachmentNameWithIcon()
                    footerView.labelAttachmentHeightConstraint.constant = 21
                    footerView.deleteAttachmentHeightConstraint.constant = 16
                } else {
                    footerView.labelAttachmentName.text = ""
                    footerView.labelAttachmentHeightConstraint.constant = 0
                    footerView.deleteAttachmentHeightConstraint.constant = 0
                }
            }
        }
        
    }
    
    func removeAttachmentTapped() {
        reportData.images = []
        reportData.videos = []
        if let tableFooterView = faqTableView.tableFooterView, tableFooterView.isKind(of: FaqFooterView.self) {
            if let footerView = tableFooterView as? FaqFooterView, footerView.emailAddressTextField != nil {
                footerView.reportData = reportData
                footerView.labelAttachmentName.text = ""
                footerView.labelAttachmentHeightConstraint.constant = 0
                footerView.deleteAttachmentHeightConstraint.constant = 0
            }
        }
    }
    
    private func attachmentNameWithIcon() -> NSMutableAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.fifteen,
            NSAttributedString.Key.foregroundColor: Colors.weatherBlue,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        var attributedString: NSMutableAttributedString!
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = Images.deleteAttach
        attributedString = NSMutableAttributedString(
            string: reportData.mediaType == .image ? "Image01": "Video01", attributes: attributes
        )
        return attributedString
    }
    
    func viewAttachmentTapped() {
        // Do Something
    }
    
}

extension FrequentlyAskedQuestionViewController: MFMailComposeViewControllerDelegate {
    
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
            self.showToast("Sorry, we are unable to send your email. Please try again.")
        case .cancelled:
            break
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

extension FrequentlyAskedQuestionViewController {
    
    @IBAction func sendEmailButtonTapped(_ sender: UIButton) {
        if !Validation.shared.checkEmptyField(field: self.emailAddressTextField.text ?? "") {
            self.sendQueryButtonTapped(error: .emptyEmail, successMessage: emptyString)
        } else if !Validation.shared.isValidEmail(email: self.emailAddressTextField.text ?? "") {
            self.sendQueryButtonTapped(error: .invalidEmail, successMessage: emptyString)
        } else if messageTextView.attributedText.string == NSMutableAttributedString(string: Constants.typeYourMessage.localized).string || !Validation.shared.checkEmptyField(field: self.messageTextView.text ?? "") {
            self.sendQueryButtonTapped(error: .emptyData, successMessage: emptyString)
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
                    self.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                    let uploadRequest = FileUploadRequest(fileName: "Image-File\(Date.currentTimeStamp.string)", fileContent: reportData.images[0].convertToBase64String())
                    reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
                } else if reportData.videos.count > 0 {
                    self.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                    let uploadRequest = FileUploadRequest(fileName: "Video-File\(Date.currentTimeStamp.string)", fileContent: reportData.videos[0].convertToBase64String())
                    reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
                } else {
                    print("Error Else execute")
                }
            case .video:
                self.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
                let uploadRequest = FileUploadRequest(fileName: "Video-File\(Date.currentTimeStamp.string)", fileContent: reportData.videos[0].convertToBase64String())
                reportIncidenceViewModel.performFileUploadRequest(request: uploadRequest, index: 0)
            default:
                break
            }
        } else {
            let mailSubject = buttonFeedBack.isSelected ? Constants.feedBack.localized : buttonInquiry.isSelected ? Constants.inquiry.localized: Constants.lostFound.localized
            self.sendQueryButtonTapped(error: .emailSendStart, successMessage: emptyString)
            let emailRequest = SendEmailRequest(from: self.emailAddressTextField.text ?? "", to: mailID, subject: mailSubject, contentType: "text/html", content: queryMessage, attachmentId: nil)
            sendQueryChatViewModel.emailSendRequest = emailRequest
            sendQueryChatViewModel.performSendEmailRequest()
        }
    }
}
