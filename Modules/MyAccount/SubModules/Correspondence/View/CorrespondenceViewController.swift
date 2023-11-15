//
//  CorrespondenceViewController.swift
//  RCRC
//
//  Created by anand madhav on 17/11/20.
//

import UIKit
let numberOfRows = 3
let headerHeight = 16

class CorrespondenceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var correspondenceTableView: UITableView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    let correspondenceViewModel = CorrespondenceViewModel()
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
                self.phoneView.isHidden = false
                self.emailView.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .correspondance)
        self.addBackgroundImage()
        correspondenceTableView.delegate = self
        correspondenceTableView.dataSource = self
        correspondenceTableView.frame.size.height = correspondenceTableView.contentSize.height
        registerCellXibs()
        configureContactView()
        self.disableLargeNavigationTitleCollapsing()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.correspondence.localized)
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    func registerCellXibs() {
        self.correspondenceTableView.register(CorrespondenceTableViewCell.nib, forCellReuseIdentifier: CorrespondenceTableViewCell.identifier)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CorrespondenceTableViewCell? = tableView.dequeueReusableCell(withIdentifier: CorrespondenceTableViewCell.identifier, for: indexPath) as? CorrespondenceTableViewCell
        cell?.titleLabel.text = correspondenceViewModel.correspondenceList[indexPath.row].localized
        cell?.correspondenceMenuImageView.image = correspondenceViewModel.correspondenceImageList[indexPath.row]
        return cell ?? UITableViewCell()

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let reportIncidenceViewController: ReportIncidenceViewController = ReportIncidenceViewController.instantiate(appStoryboard: .reportIncidence)
            self.navigationController?.pushViewController(reportIncidenceViewController, animated: true)
        case 1:
            let reportLostAndFoundViewController: ReportLostAndFoundViewController = ReportLostAndFoundViewController(nibName: "ReportLostAndFoundViewController", bundle: nil)// ReportLostViewController.instantiate(appStoryboard: .reportIncidence)
            self.navigationController?.pushViewController(reportLostAndFoundViewController, animated: true)
        case 2:
            let recentCommunicationsViewController: RecentCommunicationsViewController = RecentCommunicationsViewController(nibName: "RecentCommunicationsViewController", bundle: nil)
            self.navigationController?.pushViewController(recentCommunicationsViewController, animated: true)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(headerHeight)
    }
}

// MARK: - Contact Information Implementation
extension CorrespondenceViewController {

    func configureContactView() {
        configureUI()
        configureLabels()
        configureGestures()
        configureImages()
//        configureShadows()
        fetchContactDetails()
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

    private func configureUI() {
        self.view.backgroundColor = Colors.backgroundGray
        correspondenceTableView.backgroundColor = Colors.backgroundGray
        activityIndicator = animationView.showActivity
        phoneView.isHidden = true
        emailView.isHidden = true
    }

    private func configureLabels() {

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

        self.phoneView.layer.shadowColor = Colors.black.cgColor
        self.phoneView.layer.shadowOpacity = 0.3
        self.phoneView.layer.shadowOffset = CGSize(width: 1.0, height: -4.0)
        self.emailView.layer.shadowColor = Colors.black.cgColor
        self.emailView.layer.shadowOpacity = 0.1
        self.emailView.layer.shadowOffset = CGSize(width: 0, height: 4.0)
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

    @objc func contactLabelTapped(_ sender: UITapGestureRecognizer) {

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
