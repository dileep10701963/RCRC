//
//  DeviceSetUpViewController.swift
//  RCRC
//
//  Created by Errol on 02/12/20.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: PaddedTextField!
    let forgotViewModel = ForgotPasswordViewModel()
    var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var descriptionLabel: LocalizedLabel!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: "")
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddressTextField.setAlignment()
        emailAddressTextField.delegate = self
    }

    @IBAction func resetPasswordTapped(_ sender: Any) {
        if !Validation.shared.checkEmptyField(field: self.emailAddressTextField.text ?? "") {
            self.showCustomAlert(alertTitle: Constants.validationFailed.localized,
                                 alertMessage: Constants.emailMissing.localized,
                                 firstActionTitle: ok,
                                 firstActionStyle: .cancel)
        } else if !Validation.shared.isValidEmail(email: self.emailAddressTextField.text ?? "") {
            self.showCustomAlert(alertTitle: Constants.validationFailed.localized,
                                 alertMessage: Constants.emailValidationMessage.localized,
                                 firstActionTitle: ok.localized,
                                 firstActionStyle: .cancel)
        } else {
            if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                return
            }
            guard let emailID = self.emailAddressTextField.text else { return }
            activityIndicator = self.startActivityIndicator()
            self.disableUserInteractionWhenAPICalls()
            forgotViewModel.forgotPassword(userName: emailID, completion: handleResponseResult)
        }
    }
    
    private func handleResponseResult(_ result: LoginResult) {
        self.activityIndicator?.stopAnimating()
        self.enableUserInteractionWhenAPICalls()
        switch result {
        case .success:
            let resetPasswordConfirmationViewController = ResetPasswordConfirmationViewController.instantiate(appStoryboard: .authentication)
            self.navigationController?.pushViewController(resetPasswordConfirmationViewController, animated: true)
        case let .failure(errorMessage):
            self.showCustomAlert(alertTitle: emptyString, alertMessage: errorMessage.localized, firstActionTitle: ok.localized, firstActionStyle: .default)
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {

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

