////
////  RegisterViewController.swift
////  RCRC
////
////  Created by Dnyaneshwar Shinde on 28/10/23.
////
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var confirmMobileTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var confirmEmailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryCodeTableView: UITableView!
    @IBOutlet weak var countryCodeHeightConstraint: NSLayoutConstraint!
    
    var tapGesture = UITapGestureRecognizer()
    private var selectedTextField: ReportTextField?
    var selected: Int = -1
    var datePicker = UIDatePicker()
    var picker: PickerWithDoneButton?
    var activityIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var nameError: UILabel! {
        didSet {
            if nameError.text != nil {
                nameError.isHidden = false
            } else {
                nameError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var confirmMobileError: UILabel! {
        didSet {
            if confirmMobileError.text != nil {
                confirmMobileError.isHidden = false
            } else {
                confirmMobileError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var mobileError: UILabel! {
        didSet {
            if mobileError.text != nil {
                mobileError.isHidden = false
            } else {
                mobileError.isHidden = true
            }
        }
    }
    @IBOutlet weak var emailError: UILabel! {
        didSet {
            if emailError.text != nil {
                emailError.isHidden = false
            } else {
                emailError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var confirmEmailError: UILabel! {
        didSet {
            if confirmEmailError.text != nil {
                confirmEmailError.isHidden = false
            } else {
                confirmEmailError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var passwordError: UILabel! {
        didSet {
            if passwordError.text != nil {
                passwordError.isHidden = false
            } else {
                passwordError.isHidden = true
            }
        }
    }
    @IBOutlet weak var repeatPasswordError: UILabel! {
        didSet {
            if repeatPasswordError.text != nil {
                repeatPasswordError.isHidden = false
            } else {
                repeatPasswordError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var userIDError: UILabel! {
        didSet {
            if userIDError.text != nil {
                userIDError.isHidden = false
            } else {
                userIDError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var lastNameError: UILabel! {
        didSet {
            if lastNameError.text != nil {
                lastNameError.isHidden = false
            } else {
                lastNameError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let signUpViewModel = SignUpViewModel()
    let documentViewModel = DocumentViewModel()
    var documentTypeModel: DocumentTypeResponseModel!
    var showPasswordButton: UIButton = UIButton()
    private var activeTextField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureTextFieldObserver()
        countryCodeLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGestureForCountryList(_:)))
        countryCodeLabel.addGestureRecognizer(tap)
        configureCountryCodeTableView()
        configureDelegates()
        addDoneButtonOnKeyboard()
        self.disableLargeNavigationTitleCollapsing()
        
        nameError.setAlignment()
        lastNameError.setAlignment()
        mobileError.setAlignment()
        confirmEmailError.setAlignment()
        emailError.setAlignment()
        confirmEmailError.setAlignment()
        passwordError.setAlignment()
        repeatPasswordError.setAlignment()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        makeNavigationBarTransparent()
        self.setNavigationBarAppearance(isPrimaryColorSet: false)
        self.configureNavigationBar(title: "")
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
        getPhoneCode()
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+200)
    }
    
    private func fetchDocumentTypes() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = self.startActivityIndicator()
        self.disableUserInteractionWhenAPICalls()
        documentViewModel.getDocumentTypes()
        documentViewModel.documentResult.bind {[weak self] documentType, error in
            DispatchQueue.main.async {
                if documentType == nil && error == nil {}
                else {
                    self?.activityIndicator?.stop()
                    self?.enableUserInteractionWhenAPICalls()
                    if let documentType = documentType {
                        self?.documentTypeModel = documentType
                    } else if let _ = error {
                        self?.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized, alertMessage: Constants.serverErrorAlertMessage.localized, firstActionTitle: ok, firstActionStyle: .default)
                    }
                }
            }
        }
    }
    
    func getPhoneCode() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = self.startActivityIndicator()
        self.disableUserInteractionWhenAPICalls()
        signUpViewModel.getPhoneCode { [weak self] phoneCodeModel, error in
            
            self?.activityIndicator?.stop()
            self?.enableUserInteractionWhenAPICalls()
            
            DispatchQueue.main.async {
                if phoneCodeModel == nil && error == nil {}
                else {
                    self?.activityIndicator?.stop()
                    self?.enableUserInteractionWhenAPICalls()
                    
                    if let phoneCodeModel = phoneCodeModel {
                        self?.signUpViewModel.phoneCodeModel = phoneCodeModel
                    } else if let phoneCodeModel = self?.signUpViewModel.getCountryCodeJsonFromBundle() {
                        self?.signUpViewModel.phoneCodeModel = phoneCodeModel
                    } else {
                        self?.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized, alertMessage: Constants.serverErrorAlertMessage.localized, firstActionTitle: ok, firstActionStyle: .default)
                    }
                }
            }
        }
    }
    
    private func configureCountryCodeTableView() {
        countryCodeTableView.backgroundColor = Colors.rptArrowGrey
        self.countryCodeTableView.register(CountryCodeTableCell.nib, forCellReuseIdentifier: CountryCodeTableCell.identifier)
        countryCodeTableView.dataSource = self
        countryCodeTableView.delegate = self
    }
    private func configureDelegates() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            countryCodeLabel.text = "669+"
            signUpViewModel.countryCode = "669+"
            countryCodeLabel.textAlignment = .right
        } else {
            countryCodeLabel.text = "+966"
            signUpViewModel.countryCode = "+966"
            countryCodeLabel.textAlignment = .left
        }
    }
    
    private func configureTextFields() {
        
        self.setTextFieldAttributes(tag: 1, textField: nameTextField)
        self.setTextFieldAttributes(tag: 2, textField: mobileNumberTextField)
        self.setTextFieldAttributes(tag: 3, textField: emailAddressTextField)
        self.setTextFieldAttributes(tag: 6, textField: confirmEmailAddressTextField)
        self.setTextFieldAttributes(tag: 9, textField: confirmMobileTextField)
        
        passwordTextField.setAlignment()
        passwordTextField.borderColor = .clear
        passwordTextField.borderWidth = 1.0
        passwordTextField.tintColor = Colors.green
        passwordTextField.tag = 4
        passwordTextField.textContentType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingDidBegin)
        passwordTextField.delegate = self
        
        passwordTextField.enablePasswordToggle()
        repeatPasswordTextField.enablePasswordToggle()
        
        repeatPasswordTextField.setAlignment()
        repeatPasswordTextField.borderColor = .clear
        repeatPasswordTextField.borderWidth = 1.0
        repeatPasswordTextField.tintColor = Colors.green
        repeatPasswordTextField.tag = 5
        repeatPasswordTextField.textContentType = .none
        repeatPasswordTextField.autocorrectionType = .no
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingDidBegin)
        repeatPasswordTextField.delegate = self
        
        //   self.setTextFieldAttributes(tag: 6, textField: citizenshipIDTextField)
        self.setTextFieldAttributes(tag: 7, textField: lastNameTextField)
        self.setTextFieldAttributes(tag: 8, textField: userIDTextField)
    }
    
    func setTextFieldAttributes(tag: Int, textField: UITextField){
        textField.setAlignment()
        textField.borderColor = .clear
        textField.borderWidth = 1.0
        textField.tintColor = Colors.green
        textField.tag = tag
        textField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingDidBegin)
        textField.delegate = self
    }
    
    @objc private func showPasswordTapped() {
        passwordTextField.isSecureTextEntry.toggle()
        repeatPasswordTextField.isSecureTextEntry.toggle()
        if showPasswordButton.currentImage == Images.showPassword {
            showPasswordButton.setImage(Images.hidePassword, for: .normal)
        } else {
            showPasswordButton.setImage(Images.showPassword, for: .normal)
        }
    }
    
    private func configureTextFieldObserver() {
        signUpViewModel.isValid.bind({ (message, textField) in
            switch textField {
            case .name:
                if let message = message {
                    self.nameError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.nameTextField.borderColor = .clear
                    self.nameError.text = nil
                }
                self.nameError.setAlignment()
            case .mobile:
                if let message = message {
                    self.mobileError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.mobileNumberTextField.borderColor = .clear
                    self.mobileError.text = nil
                }
                self.mobileError.setAlignment()
                
            case .confirmMobile:
                if let message = message {
                    self.confirmMobileError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.confirmMobileTextField.borderColor = .clear
                    self.confirmMobileError.text = nil
                }
                self.confirmMobileError.setAlignment()
                
            case .email:
                if let message = message {
                    self.emailError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.emailError.text = nil
                }
                self.emailError.setAlignment()
                
            case .confirmEmail:
                if let message = message {
                    self.confirmEmailError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.confirmEmailError.text = nil
                }
                self.confirmEmailError.setAlignment()
                
            case .password:
                if let message = message {
                    self.passwordError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.passwordTextField.borderColor = .clear
                    self.passwordError.text = nil
                }
                self.passwordError.setAlignment()
            case .repeatPassword:
                if let message = message {
                    self.repeatPasswordError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.repeatPasswordTextField.borderColor = .clear
                    self.repeatPasswordError.text = nil
                }
                self.repeatPasswordError.setAlignment()
            case .citizenshipID:
                break
                
            case .lastName:
                if let message = message {
                    self.lastNameError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.lastNameTextField.borderColor = .clear
                    self.lastNameError.text = nil
                }
                self.lastNameError.setAlignment()
            case .dateOfBirth:
                break
                
            case .gender:
                break
                
            case .documentType:
                break
                
            case .userID:
                
                if let message = message {
                    self.userIDError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.userIDTextField.borderColor = .clear
                    self.userIDError.text = nil
                }
                self.userIDError.setAlignment()
            case .consession:
                break
                
            case .reseller:
                break
                
            case .none:
                break
            }
            let _ = self.isEnableSignupButton()
        })
    }
    
    @objc func handleTapGestureForCountryList(_ sender: UITapGestureRecognizer? = nil) {
        
        self.view.endEditing(true)
        if self.signUpViewModel.phoneCodeModel.CountryList.count > 0 {
            if countryCodeHeightConstraint.constant == 0 {
                configureTableView(countryCodeLabel)
            } else {
                //  countryCodeImageView.image = UIImage(named: "DropDownArrow")
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut) {
                    self.countryCodeHeightConstraint.constant = 0
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            if let phoneCodeModel = signUpViewModel.getCountryCodeJsonFromBundle() {
                self.signUpViewModel.phoneCodeModel = phoneCodeModel
            }
        }
    }
    
    func configureTableView(_ sender: UILabel) {
        // countryCodeImageView.image = UIImage(named: "DropUpArrow")
        countryCodeTableView.layer.cornerRadius = 5.0
        countryCodeTableView.reloadData()
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 250.0
            self.view.layoutIfNeeded()
        }
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func registerButtonClickAction(_ sender: UIButton) {
        
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        if let name = nameTextField.text, name != emptyString,
           let lastName = lastNameTextField.text, lastName != emptyString,
           let countryCode = countryCodeLabel.text, countryCode != emptyString,
           let mobile = mobileNumberTextField.text, mobile != emptyString,
           let confirmMobile = confirmMobileTextField.text, confirmMobile != emptyString,
           let email = emailAddressTextField.text, email != emptyString,
           let confirmEmail = confirmEmailAddressTextField.text, confirmEmail != emptyString,
           let userID = userIDTextField.text, userID != emptyString,
           let password = passwordTextField.text, password != emptyString,
           let repeatPassword = repeatPasswordTextField.text, repeatPassword != emptyString {
           
            
            /*if signUpViewModel.isConcession == -1 && signUpViewModel.isReseller == -1 {
             signUpViewModel.isConcession = -1
             signUpViewModel.isReseller = -1
             } else if signUpViewModel.isConcession == -1 {
             signUpViewModel.isConcession = -1
             } else if signUpViewModel.isReseller == -1 {
             signUpViewModel.isReseller = -1
             } else {*/
            
            /* We are passing default values for Date Of Birth, Gender, Document Type, Citizen ID, Until we are enabling UITextFields of the same*/
            
            if email != confirmEmail {
                self.showCustomAlert(alertTitle: emptyString, alertMessage: Constants.emailConfirmEmailShouldSame.localized, firstActionTitle: ok, firstActionStyle: .default)
            } else if repeatPassword != password {
                self.showCustomAlert(alertTitle: emptyString, alertMessage: Constants.passwordConfirmPasswordShouldSame.localized, firstActionTitle: ok, firstActionStyle: .default)
            } else if confirmMobile != mobile {
                self.showCustomAlert(alertTitle: emptyString, alertMessage: Constants.confirmMobileShouldSame.localized, firstActionTitle: ok, firstActionStyle: .default)
            } else {
                signUpViewModel.dateOfBirth = "1981-06-01"
                signUpViewModel.documentType = "PASS"
                signUpViewModel.gender = "MALE"
                signUpViewModel.citizenshipID = "250\(Date.currentTimeStamp.string)"
                
                self.activityIndicator = self.startActivityIndicator()
                self.disableUserInteractionWhenAPICalls()
                signUpViewModel.registerUser(signUpModel: signUpViewModel, completion: handleResponseResult)
            }
        } else {
            return
        }
    }
    
    private func handleResponseResult(_ result: LoginResult) {
        self.activityIndicator?.stop()
        self.enableUserInteractionWhenAPICalls()
        UIApplication.shared.endIgnoringInteractionEvents()
        switch result {
        case .success:
            UserDefaultService.setCountryISOCode(value: signUpViewModel.selectedCountryListModel?.iso ?? "")
            let registrationSuccessfulViewController = RegistrationSuccessfulViewController.instantiate(appStoryboard: .authentication)
            self.navigationController?.pushViewController(registrationSuccessfulViewController, animated: true)
        case let .failure(errorMessage):
            self.showCustomAlert(alertTitle: emptyString, alertMessage: errorMessage.localized, firstActionTitle: ok, firstActionStyle: .default)
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let viewController = navigationController?.viewControllers.first(where: { $0.isKind(of: LoginViewController.self) }) {
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            let viewController = LoginViewController.instantiate(appStoryboard: .authentication)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @objc func textFieldTextChanged(_ sender: UITextField) {
        UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        switch sender.tag {
        case 1:
            signUpViewModel.name = sender.text
        case 2:
            signUpViewModel.mobileNumber = sender.text
        case 3:
            signUpViewModel.email = sender.text
        case 4:
            signUpViewModel.password = sender.text
        case 5:
            signUpViewModel.repeatPassword = sender.text
        case 6:
            signUpViewModel.confirmEmail = sender.text
        case 7:
            signUpViewModel.lastName = sender.text
        case 8:
            signUpViewModel.userID = sender.text
        case 9:
            signUpViewModel.confirmMobileNumber = sender.text
            
        default:
            break
        }
    }
    
    private func addHyphen(_ value: String) -> String {
        var result: String = value
        if value.count == 8 || value.count == 12 {
            let range = NSRange(location: 0, length: value.count)
            do {
                let regex = try NSRegularExpression(pattern: "^\\+966\\s([0-9]{3})|([0-9]{3}-[0-9]{3})$")
                if regex.firstMatch(in: value, options: [], range: range) != nil {
                    mobileNumberTextField.text?.append("-")
                    result.append("-")
                }
            } catch {
                //print(error.localizedDescription)
            }
        }
        return result
    }
    
    func addDoneButtonOnKeyboard() {
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        mobileNumberTextField.inputAccessoryView = doneToolbar
        confirmMobileTextField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        DispatchQueue.main.async {
            self.mobileNumberTextField.selectedTextRange = self.mobileNumberTextField.textRange(from: self.mobileNumberTextField.endOfDocument, to: self.mobileNumberTextField.endOfDocument)
            
            self.confirmMobileTextField.selectedTextRange = self.confirmMobileTextField.textRange(from: self.confirmMobileTextField.endOfDocument, to: self.confirmMobileTextField.endOfDocument)
        }
        mobileNumberTextField.resignFirstResponder()
        confirmMobileTextField.resignFirstResponder()
    }
    
    private func isEnableSignupButton() -> Bool {
        
        if nameError.attributedText == nil, lastNameError.attributedText == nil, mobileError.attributedText == nil, confirmMobileError.attributedText == nil, emailError.attributedText == nil, confirmEmailError.attributedText == nil, passwordError.attributedText == nil, repeatPasswordError.attributedText == nil, userIDError.attributedText == nil /* dateOfBirthError.attributedText == nil, citizenshipIDError.attributedText == nil, genderError.attributedText == nil, concessionError.attributedText == nil, resellerError.attributedText == nil, documentTypeError.attributedText == nil*/ {
            return true
        } else {
            return false
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if textField == mobileNumberTextField {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            }
            
        }
        
        if textField == confirmMobileTextField {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            }
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mobileNumberTextField {
            let isMobileNumberTextFieldEndRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            if isMobileNumberTextFieldEndRange != textField.selectedTextRange {
                textField.selectedTextRange = isMobileNumberTextFieldEndRange
            }
        }
        
        if textField == confirmMobileTextField {
            let isMobileNumberTextFieldEndRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            if isMobileNumberTextFieldEndRange != textField.selectedTextRange {
                textField.selectedTextRange = isMobileNumberTextFieldEndRange
            }
        }

        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        if newString.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines).location != 0 {
            
            if let text = textField.text, let textRange = Range(range, in: text) {
                let updatedText = text.replacingCharacters(in: textRange, with: string)
                
                if updatedText.containsEmoji || updatedText.containsAnyEmoji || string == " " {
                    return false
                }
                switch textField {
                case mobileNumberTextField:
                    
                    if signUpViewModel.countryCodeDigits != nil {
                        if updatedText.count > signUpViewModel.countryCodeDigits ?? 0 {
                            return false
                        }
                    } else {
                        if updatedText.count >= 15 {
                            return false
                        }
                    }
                    
                case confirmMobileTextField:
                    
                    if signUpViewModel.countryCodeDigits != nil {
                        if updatedText.count > signUpViewModel.countryCodeDigits ?? 0 {
                            return false
                        }
                    } else {
                        if updatedText.count >= 15 {
                            return false
                        }
                    }
                    
                case passwordTextField, repeatPasswordTextField :
                    if string == " " {
                        
                    }
                    
                case emailAddressTextField, confirmEmailAddressTextField:
                    if string == " " {
                        
                    }
                default: break
                }
            }
            return true
        } else {
            return false
        }
    }
}

extension RegisterViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return signUpViewModel.phoneCodeModel.CountryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: CountryCodeTableCell? = countryCodeTableView.dequeueReusableCell(withIdentifier: CountryCodeTableCell.identifier, for: indexPath) as? CountryCodeTableCell
        let countryCode = signUpViewModel.getCountryAndISOCodeFromModel(indexPath.row)
        cell?.setCountryLabel(countryCode)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let countryCode = "+\(signUpViewModel.phoneCodeModel.CountryList[indexPath.row].code ?? "")"
        //        countryCodeLabel.text = countryCode
        //        signUpViewModel.countryCode = countryCode
        countryCodeLabel.text = signUpViewModel.getCountryCodeFromModel(indexPath.row)
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        mobileNumberTextField.text = ""
        signUpViewModel.countryCodeDigits = signUpViewModel.phoneCodeModel.CountryList[indexPath.row].digit
        //   countryCodeImageView.image = UIImage(named: "DropDownArrow")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        hide()
    }
    
    func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
                //   self.countryCodeImageView.image = UIImage(named: "DropDownArrow")
                self.countryCodeHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.tapGesture.removeTarget(self, action: nil)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        if view.isDescendant(of: countryCodeTableView) {
            return false
        } else {
            return true
        }
    }
}


extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(isSecureTextEntry == false){
            button.setImage(UIImage(named: "View_Password"), for: .normal)
        }else{
            button.setImage(UIImage(named: "hide_password"), for: .normal)
        }
    }
    
    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
    }
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}

extension UIImage {
    class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        
        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
        }
        
        return UIImage.animatedImage(with: images, duration: 0.0)
    }
}
