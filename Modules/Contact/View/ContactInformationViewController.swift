//
//  ContactInformationViewController.swift
//  RCRC
//
//  Created by Errol on 14/08/20.
//

import UIKit

class ContactInformationViewController: UIViewController {

    @IBOutlet weak var phoneInformationView: UIView!
    @IBOutlet weak var emailInformationView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionTitleLabel: LocalizedLabel!
    @IBOutlet weak var descriptionLabel: LocalizedLabel!
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    var sendMessageButton: UIButton? = UIButton()
    let contactViewModel = ContactViewModel()
    var activityIndicator: UIActivityIndicatorView?
    var phoneText: String? {
        didSet {
            let string = configureAttributedString(inputText: phoneText ?? emptyString)
            phoneLabel.attributedText = string
        }
    }
    
    var mailText: String? {
        didSet {
            let string = configureAttributedString(inputText: mailText ?? emptyString)
            emailLabel.attributedText = string
        }
    }
    var didFetchContactDetails: Bool = false {
        didSet {
            if didFetchContactDetails {
                self.activityIndicator?.stopAnimating()
                self.phoneInformationView.isHidden = false
                self.emailInformationView.isHidden = false
            }
        }
    }
//    var backButtonEnabled: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.contact.localized)
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        self.logEvent(screen: .contactInfo)
        configureUI()
        configureLabels()
        configureGestures()
        configureImages()
        configureShadows()
        //addSendMessageButton()
        fetchContactDetails()
        self.disableLargeNavigationTitleCollapsing()
    }

    fileprivate func fetchContactDetails() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        contactViewModel.fetchContactDetails()
        contactViewModel.contactDetails.bind { (result, error) in
            if let result = result, error == nil {
                guard let item = result.items.first else { return }
                self.didFetchContactDetails = true
                self.phoneText = (item?.contentFields[safe: 0]??.label ?? emptyString) + ": " + (item?.contentFields[safe: 0]??.contentFieldValue?.data ?? emptyString)
                self.mailText = (item?.contentFields[safe: 1]??.label ?? emptyString) + ": " + (item?.contentFields[safe: 1]??.contentFieldValue?.data ?? emptyString)
            } else if let error = error {
                self.showCustomAlert(alertTitle: Constants.error, alertMessage: error.localizedDescription, firstActionTitle: ok, firstActionStyle: .default)
            }
        }
    }

    private func addSendMessageButton() {
        sendMessageButton?.contentMode = .scaleAspectFit
        sendMessageButton?.translatesAutoresizingMaskIntoConstraints = false
        sendMessageButton?.setTitle(Constants.sendMessage.localized, for: .normal)
        sendMessageButton?.addTarget(self, action: #selector(sendMessageTapped), for: .touchUpInside)
        sendMessageButton?.titleLabel?.textColor = UIColor.init(red: 0.0, green: 111.0, blue: 68.0, alpha: 1.0)
        sendMessageButton?.titleLabel?.font = Fonts.RptaSignage.fourteen
        let barbutton = UIBarButtonItem(customView: sendMessageButton!)
        self.navigationItem.rightBarButtonItem = barbutton
    }

    @objc func sendMessageTapped() {
        let contactDetailViewController = ContactDetailViewController.instantiate(appStoryboard: .contactInformation)
        self.navigationController?.pushViewController(contactDetailViewController, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    private func configureUI() {
        self.view.backgroundColor = Colors.backgroundGray
        activityIndicator = animationView.showActivity
        phoneInformationView.isHidden = true
        emailInformationView.isHidden = true
    }

    private func configureLabels() {

        descriptionTitleLabel.font = Fonts.RptaSignage.eighteen
        descriptionLabel.font = Fonts.RptaSignage.fifteen
        descriptionTitleLabel.text = Constants.contactDescriptionTitle.localized
        descriptionLabel.text = Constants.contactDescription.localized
        phoneLabel.setAlignment()
        emailLabel.setAlignment()
    }

    private func configureGestures() {

        let tapGestureForPhoneLabel = UITapGestureRecognizer(target: self, action: #selector(self.contactLabelTapped(_:)))
        let tapGestureForFaxLabel = UITapGestureRecognizer(target: self, action: #selector(self.contactLabelTapped(_:)))
        let tapGestureForEmailLabel = UITapGestureRecognizer(target: self, action: #selector(self.contactLabelTapped(_:)))
        tapGestureForPhoneLabel.numberOfTapsRequired = 1
        tapGestureForFaxLabel.numberOfTapsRequired = 1
        tapGestureForEmailLabel.numberOfTapsRequired = 1
        phoneLabel.isUserInteractionEnabled = true
        emailLabel.isUserInteractionEnabled = true
        phoneLabel.addGestureRecognizer(tapGestureForPhoneLabel)
        emailLabel.addGestureRecognizer(tapGestureForEmailLabel)
        phoneLabel.tag = 1
        emailLabel.tag = 3
    }

    private func configureImages() {

        self.phoneImage.image = Images.phone
        self.emailImage.image = Images.email
    }

    private func configureShadows() {

        self.descriptionView.layer.shadowColor = Colors.black.cgColor
        self.descriptionView.layer.shadowOpacity = 0.3
        self.descriptionView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.phoneInformationView.layer.shadowColor = Colors.black.cgColor
        self.phoneInformationView.layer.shadowOpacity = 0.3
        self.phoneInformationView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.emailInformationView.layer.shadowColor = Colors.black.cgColor
        self.emailInformationView.layer.shadowOpacity = 0.1
        self.emailInformationView.layer.shadowOffset = CGSize(width: 0, height: 4.0)
        
    }

    fileprivate func configureAttributedString(inputText: String) -> NSMutableAttributedString {

        let regularFontAttributes = [NSAttributedString.Key.font: Fonts.RptaSignage.fifteen, .foregroundColor: Colors.textGray]
        let greenFontAttributes = [NSMutableAttributedString.Key.font: Fonts.RptaSignage.seventeen, NSMutableAttributedString.Key.foregroundColor: Colors.green]
        var contactType = [String]()
        contactType = inputText.components(separatedBy: ":")
        let contactsplit = contactType.dropFirst()
        let contactRegularText = inputText.components(separatedBy: ":").first ?? emptyString + ":".localized
        let contactRegularString = NSMutableAttributedString(string: contactRegularText + ":", attributes: regularFontAttributes as [NSAttributedString.Key: Any])
        let contactGreenText = contactsplit.joined(separator: ":").localized
        let contactGreenString = NSMutableAttributedString(string: contactGreenText, attributes: greenFontAttributes as [NSAttributedString.Key: Any])
        contactRegularString.append(contactGreenString)
        return contactRegularString
    }

    @IBAction func contactLabelTapped(_ sender: UITapGestureRecognizer) {

        guard let view = sender.view else {
            return
        }
        switch view.tag {
        case 1:
            guard let url = URL(string: "telprompt://\(phoneText ?? emptyString)"),
                UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case 3:
            return
//            EmailService.sendEmail(mailto: ViewControllerConstants.ContactInformation.emailAddress, subject: ViewControllerConstants.ContactInformation.emailSubject) // todo
        default:
            return
        }
    }
}
