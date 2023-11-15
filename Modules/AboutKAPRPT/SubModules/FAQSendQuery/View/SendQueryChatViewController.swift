//
//  SendQueryChatViewController.swift
//  RCRC
//
//  Created by pcadmin on 09/04/21.
//

import UIKit

class SendQueryChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var sendQueryButton: UIButton!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    let sendQueryChatViewModel = SendQueryChatViewModel()
    var activityIndicator: UIActivityIndicatorView?
    var userEmailID: String = emptyString

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .sendQuery)
        self.addBackgroundImage()
        configureTableView()
        queryTextField.delegate = self
        queryTextField.setAlignment()
        bindUI()

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self?.viewBottomConstraint.constant = keyboardSize.height
            }
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] _ in
            self?.viewBottomConstraint.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: "Send Query".localized)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func sendQueryTapped(_ sender: UIButton) {
        if let text = queryTextField.text, text.isNotEmpty {
            sendQueryChatViewModel.sendMessage(text)
            self.sendEmailWithQuery(queryMessage: text)
            queryTextField.text = nil
            chatTableView.reloadData()
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: ((self.sendQueryChatViewModel.userMessages?.count ?? 0) * 2) - 1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            return
        }
    }

    private func configureTableView() {
        chatTableView.register(UserChatTableViewCell.nib, forCellReuseIdentifier: UserChatTableViewCell.identifier)
        chatTableView.register(ServerChatTableViewCell.nib, forCellReuseIdentifier: ServerChatTableViewCell.identifier)
        chatTableView.tableFooterView = UIView()
        chatTableView.dataSource = sendQueryChatViewModel
        chatTableView.allowsSelection = false
    }
    
    func bindUI() {
        sendQueryChatViewModel.isSentMail.bind { isSent in
            guard let isSent = isSent else {return}
            self.activityIndicator?.stopAnimating()
            self.enableUserInteractionWhenAPICalls()
            self.showCustomAlert(alertTitle: Constants.emailStatus, alertMessage: isSent ? Constants.emailSuccess : Constants.emailFailed, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func sendEmailWithQuery(queryMessage: String) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let emailRequest = SendEmailRequest(from: userEmailID, to: "noreply.rcrc@gmail.com", subject: "Send Query", contentType: "text/html", content: "Query: \(queryMessage)", attachmentId: nil)
        activityIndicator = self.startActivityIndicator()
        self.disableUserInteractionWhenAPICalls()
        sendQueryChatViewModel.emailSendRequest = emailRequest
        sendQueryChatViewModel.performSendEmailRequest()
    }
    
}

extension SendQueryChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, text.isNotEmpty {
            sendQueryChatViewModel.sendMessage(textField.text)
            self.sendEmailWithQuery(queryMessage: text)
            textField.text = nil
            chatTableView.reloadData()
        }
        return true
    }
}
