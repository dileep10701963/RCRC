//
//  EditProfileViewController.swift
//  RCRC
//
//  Created by Errol on 26/04/21.
//

import UIKit

class EditProfileViewController: ContentViewController {

    @IBOutlet weak var nameTextField: PaddedTextField!
    @IBOutlet weak var surNameTextField: PaddedTextField!
    @IBOutlet weak var emailAddressTextField: PaddedTextField!
    @IBOutlet weak var saveProfileButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var mobileNumberTitleLabel: UILabel!
    
    @IBOutlet weak var emailAddressTitleLabel: UILabel!
    @IBOutlet weak var lastNameTitleLabel: UILabel!
    @IBOutlet weak var firstNameTitleLabel: UILabel!
    @IBOutlet weak var mobileNumber: UITextField!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var countryCodeTableView: UITableView!
    @IBOutlet weak var countryCodeHeightConstraint: NSLayoutConstraint!
    let signUpViewModel = SignUpViewModel()
    var tapGesture = UITapGestureRecognizer()
        
    @IBOutlet weak var nameErrorLabel: UILabel!{
        didSet {
            if nameErrorLabel.text != nil {
                nameErrorLabel.isHidden = false
            } else {
                nameErrorLabel.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var surNameErrorLabel: UILabel!{
        didSet {
            if surNameErrorLabel.text != nil {
                surNameErrorLabel.isHidden = false
            } else {
                surNameErrorLabel.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var phoneErrorLabel: UILabel!{
        didSet {
            if phoneErrorLabel.text != nil {
                phoneErrorLabel.isHidden = false
            } else {
                phoneErrorLabel.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var mailErrorLabel: UILabel!{
        didSet {
            if mailErrorLabel.text != nil {
                mailErrorLabel.isHidden = false
            } else {
                mailErrorLabel.isHidden = true
            }
        }
    }
    
    private var mediaPicker: MediaPickerController!
    let editProfileViewModel = EditProfileViewModel()
    var editProfileModel: ProfileModel?
    var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logEvent(screen: .editProfile)
        self.headerTitle.text = Constants.editProfile.localized
        saveProfileButton.setTitle("Save".localized, for: .normal)

        configureView()
        self.handleResult(editProfileModel)
        self.mobileNumber.delegate = self
        self.emailAddressTextField.isEnabled = false
        self.emailAddressTextField.alpha = 0.5
        self.disableLargeNavigationTitleCollapsing()
        self.configureCountryCodeTableView()
        countryCodeTableView.translatesAutoresizingMaskIntoConstraints = false
        self.configureNavigationBar(title: Constants.editProfile.localized)
        mobileNumber.placeholder = Constants.mobileNumer.localized
        addDoneButtonOnKeyboard()
        configureTextFieldObserver()
    }
    
    private func configureCountryCodeTableView() {
        countryCodeTableView.backgroundColor = Colors.rptArrowGrey
        self.countryCodeTableView.register(CountryCodeTableCell.nib, forCellReuseIdentifier: CountryCodeTableCell.identifier)
        countryCodeTableView.dataSource = self
        countryCodeTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        getPhoneCode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.hidesBottomBarWhenPushed = false
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
                    
                    guard let self = self else { return }
                    
                    self.activityIndicator?.stop()
                    self.enableUserInteractionWhenAPICalls()
                    
                    if let phoneCodeModel = phoneCodeModel {
                        self.signUpViewModel.phoneCodeModel = phoneCodeModel
                    } else if let phoneCodeModel = self.signUpViewModel.getCountryCodeJsonFromBundle() {
                        self.signUpViewModel.phoneCodeModel = phoneCodeModel
                    }
                    
                    let numberWithExtension = self.editProfileViewModel.getPhoneNumberWithOutExt(phoneCodeModel: self.signUpViewModel.phoneCodeModel, currentNumber: self.editProfileModel?.phone ?? emptyString)
                    self.mobileNumber.text = numberWithExtension.number
                    self.countryCodeLabel.text = numberWithExtension.numbExtension
                }
            }
        }
    }

    @IBAction func countryCodeTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if self.signUpViewModel.phoneCodeModel.CountryList.count > 0 {
            if countryCodeHeightConstraint.constant == 0 {
                configureTableView(sender)
            } else {
//                countryCodeImageView.image = UIImage(named: "DropDownArrow")
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
    
    func configureTableView(_ sender: UIButton) {
//        countryCodeImageView.image = UIImage(named: "DropUpArrow")
        countryCodeTableView.layer.cornerRadius = 5.0
        countryCodeTableView.reloadData()
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 250.0
            self.view.layoutIfNeeded()
        }
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableHandleTapGesture(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func isEnableEditProfileButton() -> Bool {
        if (nameErrorLabel.text == nil || nameErrorLabel.text == emptyString) && (surNameErrorLabel.text == nil || surNameErrorLabel.text == emptyString) && ( phoneErrorLabel.text == nil || phoneErrorLabel.text == emptyString ) && ( mailErrorLabel.text == nil || mailErrorLabel.text == emptyString) {
            DispatchQueue.main.async {
                self.saveProfileButton.isEnabled = true
                self.saveProfileButton.alpha = 1.0
            }
            return true
        } else {
            DispatchQueue.main.async {
                self.saveProfileButton.alpha = 0.5
                self.saveProfileButton.isEnabled = false
            }
            return false
        }
    }

    @IBAction func backButtonClickAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func saveProfileTapped(_ sender: UIButton) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        
        if let name = nameTextField.text, name != emptyString,
           let surname = surNameTextField.text, surname != emptyString,
        let email = emailAddressTextField.text, email != emptyString,
        let phone = mobileNumber.text, phone != emptyString {
            activityIndicator = self.startActivityIndicator()
            self.disableUserInteractionWhenAPICalls()
            let phoneNumber = "\(countryCodeLabel.text ?? "")\(phone)".replacingOccurrences(of: " ", with: "")
            let data = EditProfileModel(name: name, surname: surname, gender: editProfileModel?.gender ?? emptyString, documentType: "PASS", personalId: editProfileModel?.personalId ?? emptyString, mail: email, dateOfBirth: editProfileModel?.dateOfBirth ?? emptyString, phone: phoneNumber, additionalEmails: [AdditionalEmail(email: "")], additionalPhones: [AdditionalPhone(phoneNumber: "")])
            editProfileViewModel.updateProfileData(profileModel: data, completion: handleResponseResult(_:))
        } else {
            return
        }
    }
    
    private func configureTextFieldObserver() {
        editProfileViewModel.isValid.bind({ (message, textField) in
            switch textField {
            case .name:
                if let message = message {
                    self.nameTextField.borderColor = .red
                    self.nameErrorLabel.attributedText = self.attributedText(text: message)
                } else {
                    self.nameTextField.borderColor = .clear
                    self.nameErrorLabel.text = nil
                }
                self.nameErrorLabel.setAlignment()
            case .lastName:
                if let message = message {
                    self.surNameTextField.borderColor = .red
                    self.surNameErrorLabel.attributedText = self.attributedText(text: message)
                } else {
                    self.surNameTextField.borderColor = .clear
                    self.surNameErrorLabel.text = nil
                }
                self.surNameErrorLabel.setAlignment()
            case .mobile:
                if let message = message {
                    self.mobileNumber.borderColor = .red
                    self.phoneErrorLabel.attributedText = self.attributedText(text: message)
                } else {
                    self.mobileNumber.borderColor = .clear
                    self.phoneErrorLabel.text = nil
                }
                self.phoneErrorLabel.setAlignment()
            case .email:
                if let message = message {
                    self.emailAddressTextField.borderColor = .red
                    self.mailErrorLabel.attributedText = self.attributedText(text: message)
                } else {
                    self.emailAddressTextField.borderColor = .clear
                    self.mailErrorLabel.text = nil
                }
            default:
                break
            }
            let _ = self.isEnableEditProfileButton()
        })
    }
    
    
    private func handleResponseResult(_ result: ResponseResult) {
        activityIndicator?.stop()
        self.enableUserInteractionWhenAPICalls()
        switch result {
        case .success:
            ServiceManager.sharedInstance.profileModel?.name = nameTextField.text
            ServiceManager.sharedInstance.profileModel?.surname = surNameTextField.text
            let phoneNumber = "\(countryCodeLabel.text ?? "")\(mobileNumber.text ?? "")".replacingOccurrences(of: " ", with: "")
            ServiceManager.sharedInstance.profileModel?.phone = phoneNumber
            self.navigateToSuccessView()
        case .failure(let error, _):
            switch error {
            case .invalidToken:
                self.showAlert(for: .invalidToken)
            default:
                self.showAlert(for: .serverError)
            }
        }
    }

    fileprivate func configureView() {
        self.setTextFieldAttributes(tag: 0, textField: nameTextField)
        self.setTextFieldAttributes(tag: 1, textField: surNameTextField)
        self.setTextFieldAttributes(tag: 2, textField: mobileNumber)
        self.setTextFieldAttributes(tag: 3, textField: emailAddressTextField)
        
        firstNameTitleLabel.setAlignment()
        lastNameTitleLabel.setAlignment()
        mobileNumberTitleLabel.setAlignment()
        emailAddressTitleLabel.setAlignment()
        
        firstNameTitleLabel.text = "First Name".localized
        lastNameTitleLabel.text = "Last Name".localized
        mobileNumberTitleLabel.text = "Mobile Number".localized
        emailAddressTitleLabel.text = "Email Address".localized
    }
    
    func setTextFieldAttributes(tag: Int, textField: UITextField){
        textField.setAlignment()
        textField.tag = tag
        textField.textColor = Colors.textColor
        textField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingChanged)
        textField.addTarget(self, action: #selector(textFieldTextChanged(_:)), for: .editingDidBegin)
        textField.delegate = self
    }
    
    @objc func textFieldTextChanged(_ sender: UITextField) {
        
        UIView.animate(withDuration: 0.0, delay: 0.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        switch sender.tag {
        case 0:
            editProfileViewModel.name = sender.text
        case 1:
            editProfileViewModel.lastName = sender.text
        case 2:
            editProfileViewModel.countryCodeDigits = editProfileViewModel.getValidationCountryCodeDigit(countryLabel: countryCodeLabel.text ?? "", countryCodeModels: self.signUpViewModel.phoneCodeModel.CountryList)
            editProfileViewModel.mobileNumber = sender.text
        case 3:
            editProfileViewModel.email = sender.text
        default:
            break
        }
    }

    private func configurePlaceholderText(_ value: String) -> NSAttributedString {
        let placeholders = ["First Name".localized, "Mobile Number".localized, "Email Address".localized, "Last Name".localized]
        if placeholders.contains(value) {
            return NSAttributedString(string: value, attributes: [.foregroundColor: UIColor.darkGray])
        }
        return NSAttributedString(string: value, attributes: [.foregroundColor: Colors.textColor])
    }

    private func handleResult(_ result: ProfileModel?) {
        if let data = result {
            ServiceManager.sharedInstance.profileModel = data
            self.nameTextField.text = data.name
            self.surNameTextField.text = data.surname
            self.mobileNumber.text = emptyString
            self.countryCodeLabel.text = emptyString
            self.emailAddressTextField.text = data.mail
        } else {
            self.nameTextField.attributedPlaceholder = self.configurePlaceholderText("First Name".localized)
            self.surNameTextField.attributedPlaceholder = self.configurePlaceholderText("Last Name".localized)
            self.mobileNumber.attributedPlaceholder = self.configurePlaceholderText("Mobile Number".localized)
            self.emailAddressTextField.attributedPlaceholder = self.configurePlaceholderText("Email Address".localized)
        }
    }

    private func navigateToSuccessView() {
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        viewController.headerText = Constants.accountInfoUpdatedTitle.localized
        viewController.descriptionText = Constants.accountInfoUpdatedMessage.localized
        viewController.proceedButtonText = "Done".localized
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.dismiss(animated: true, completion: {
                    self.navigationController?.popToRootViewController(animated: true)
                })
            }
        }
    }
    
    func addDoneButtonOnKeyboard() { 
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        mobileNumber.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        DispatchQueue.main.async {
            self.mobileNumber.selectedTextRange = self.mobileNumber.textRange(from: self.mobileNumber.endOfDocument, to: self.mobileNumber.endOfDocument)
        }
        mobileNumber.resignFirstResponder()
    }
}

extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == mobileNumber {
            let isMobileNumberTextFieldEndRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            if isMobileNumberTextFieldEndRange != textField.selectedTextRange {
                textField.selectedTextRange = isMobileNumberTextFieldEndRange
            }
        }
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
            
            if textField == mobileNumber {
                if editProfileViewModel.countryCodeDigits != nil {
                    if updatedText.count > editProfileViewModel.countryCodeDigits ?? 0 {
                        return false
                    }
                } else {
                    if updatedText.count >= 15 {
                        return false
                    }
                }
            }
            
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == mobileNumber {
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            }
            
        }
    }
    
}

extension EditProfileViewController: SuccessViewDelegate {

    func didTapProceed() {
        self.nameTextField.text = nil
        self.mobileNumber.text = nil
        self.emailAddressTextField.text = nil
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
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
        countryCodeLabel.text = signUpViewModel.getCountryCodeFromModel(indexPath.row)

        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.countryCodeHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        mobileNumber.text = ""
        editProfileViewModel.mobileNumber = mobileNumber.text
        editProfileViewModel.countryCodeDigits = signUpViewModel.phoneCodeModel.CountryList[indexPath.row].digit
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    @objc func tableHandleTapGesture(_ sender: UITapGestureRecognizer) {
            hide()
    }

    func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
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
