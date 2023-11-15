//
//  SignUpViewController.swift
//  RCRC
//
//  Created by Errol on 02/12/20.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var citizenshipIDTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: ReportTextField!
    @IBOutlet weak var genderTextField: ReportTextField!
    @IBOutlet weak var documentTypeTextField: ReportTextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userIDTextField: UITextField!
    
    @IBOutlet weak var concessionYesButton: UIButton!
    @IBOutlet weak var concessionNoButton: UIButton!
    @IBOutlet weak var resellerYesButton: UIButton!
    @IBOutlet weak var resellerNoButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yesConsessionImageView: UIImageView!
    @IBOutlet weak var noConsessionImageView: UIImageView!
    @IBOutlet weak var yesResellerImageView: UIImageView!
    @IBOutlet weak var noResellerImageView: UIImageView!
    
    @IBOutlet weak var getStartedLabel: UILabel!
    @IBOutlet var imageCollection:[UIImageView]!
    @IBOutlet weak var getStartedBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var countryCodeImageView: UIImageView!
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
    
    @IBOutlet weak var citizenshipIDError: UILabel! {
        didSet {
            if citizenshipIDError.text != nil {
                citizenshipIDError.isHidden = false
            } else {
                citizenshipIDError.isHidden = true
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
    
    @IBOutlet weak var dateOfBirthError: UILabel! {
        didSet {
            if dateOfBirthError.text != nil {
                dateOfBirthError.isHidden = false
            } else {
                dateOfBirthError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var genderError: UILabel! {
        didSet {
            if genderError.text != nil {
                genderError.isHidden = false
            } else {
                genderError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var documentTypeError: UILabel! {
        didSet {
            if documentTypeError.text != nil {
                documentTypeError.isHidden = false
            } else {
                documentTypeError.isHidden = true
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
    
    @IBOutlet weak var concessionError: UILabel! {
        didSet {
            if concessionError.text != nil {
                concessionError.isHidden = false
            } else {
                concessionError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var resellerError: UILabel! {
        didSet {
            if resellerError.text != nil {
                resellerError.isHidden = false
            } else {
                resellerError.isHidden = true
            }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!

    let signUpViewModel = SignUpViewModel()
    let documentViewModel = DocumentViewModel()
    var documentTypeModel: DocumentTypeResponseModel!
    var showPasswordButton: UIButton = UIButton()
    private var activeTextField: UITextField?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        /*makeNavigationBarTransparent()
        self.setNavigationBarAppearance(isPrimaryColorSet: false)*/
        self.configureNavigationBar(title: "")
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
        getPhoneCode()
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
    }

    /*override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makeNavigationBarGreen()
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addBackgroundImage()
        
        configureTextFields()
        configureTextFieldObserver()
        //configureButtons()
        configureCountryCodeTableView()
        configureDelegates()
        /* Commented below line for first Version
         fetchDocumentTypes()*/
        addDoneButtonOnKeyboard()
        self.disableLargeNavigationTitleCollapsing()
        var frame: CGRect = titleLabel.frame
        frame.origin.x = 0//pass the X cordinate
        titleLabel.frame = frame
        
        for (index, imageView) in imageCollection.enumerated() {
            imageCollection[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        
        nameError.setAlignment()
        lastNameError.setAlignment()
        mobileError.setAlignment()
        emailError.setAlignment()
        userIDError.setAlignment()
        passwordError.setAlignment()
        repeatPasswordError.setAlignment()
        
        getStartedLabel.translatesAutoresizingMaskIntoConstraints = false
        if currentLanguage == .english {
            getStartedBottomConstraint.constant = 12
            getStartedLabel.text = Constants.getStarted
        } else {
            getStartedBottomConstraint.constant = 0
            getStartedLabel.text = ""
        }
        
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
        dateOfBirthTextField.tag = 1
        dateOfBirthTextField.reportDelegate = self
        genderTextField.reportDelegate = self
        documentTypeTextField.reportDelegate = self
        
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
    
    private func configureButtons() {
        concessionYesButton.setShadow()
        concessionNoButton.setShadow()
        resellerYesButton.setShadow()
        resellerNoButton.setShadow()
    }

    private func configureTextFields() {
        
        self.setTextFieldAttributes(tag: 1, textField: nameTextField)
        self.setTextFieldAttributes(tag: 2, textField: mobileNumberTextField)
        self.setTextFieldAttributes(tag: 3, textField: emailAddressTextField)

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

        showPasswordButton.setImage(Images.showPassword, for: .normal)
        showPasswordButton.imageEdgeInsets = currentLanguage == .english ? UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        showPasswordButton.frame = CGRect(x: 0, y: 0, width: 30, height: 25)
        showPasswordButton.contentMode = .center
        showPasswordButton.addTarget(self, action: #selector(showPasswordTapped), for: .touchUpInside)
        passwordTextField.rightViewMode = .always
        passwordTextField.rightView = showPasswordButton

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
        
        self.setTextFieldAttributes(tag: 6, textField: citizenshipIDTextField)
        self.setTextFieldAttributes(tag: 7, textField: lastNameTextField)
        self.setTextFieldAttributes(tag: 8, textField: userIDTextField)
        
        dateOfBirthTextField.configureTextField(placeholder: "dd/MM/yyyy", rightImage: Images.timeTable)
        genderTextField.configureTextField(placeholder: "Select".localized, rightImage: Images.downArrowGreen)
        documentTypeTextField.configureTextField(placeholder: "Select".localized, rightImage: Images.downArrowGreen)
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
                    //self.nameTextField.borderColor = .red
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
                break
            case .email:
                if let message = message {
                    self.emailError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    //self.emailAddressTextField.borderColor = .clear
                    self.emailError.text = nil
                }
                self.emailError.setAlignment()
            case .confirmEmail:
                break
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
                if let message = message {
                    self.citizenshipIDError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.citizenshipIDTextField.borderColor = .clear
                    self.citizenshipIDError.text = nil
                }
                self.citizenshipIDError.setAlignment()
            case .lastName:
                if let message = message {
                    self.lastNameError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.lastNameTextField.borderColor = .clear
                    self.lastNameError.text = nil
                }
                self.lastNameError.setAlignment()
            case .dateOfBirth:
                if let message = message {
                    self.dateOfBirthError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                    self.dateOfBirthError.text = message
                } else {
                    self.dateOfBirthTextField.borderColor = .clear
                    self.dateOfBirthError.text = nil
                }
                self.dateOfBirthError.setAlignment()
            case .gender:
                if let message = message {
                    self.genderError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                    self.genderError.text = message
                } else {
                    self.genderTextField.borderColor = .clear
                    self.genderError.text = nil
                }
                self.genderError.setAlignment()
            case .documentType:
                if let message = message {
                    self.documentTypeError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.documentTypeTextField.borderColor = .clear
                    self.documentTypeError.text = nil
                }
                self.documentTypeError.setAlignment()
            case .userID:
                if let message = message {
                    self.userIDError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.userIDTextField.borderColor = .clear
                    self.userIDError.text = nil
                }
                self.userIDError.setAlignment()
            case .consession:
                if let message = message {
                    self.concessionError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.concessionError.text = nil
                }
                self.concessionError.setAlignment()
            case .reseller:
                if let message = message {
                    self.resellerError.attributedText = self.attributedText(text: message, lineSapcing: 3)
                } else {
                    self.resellerError.text = nil
                }
                self.resellerError.setAlignment()
            case .none:
                break
            }
            let _ = self.isEnableSignupButton()
        })
    }

    @IBAction func countryCodeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if self.signUpViewModel.phoneCodeModel.CountryList.count > 0 {
            if countryCodeHeightConstraint.constant == 0 {
                configureTableView(sender)
            } else {
                countryCodeImageView.image = UIImage(named: "DropDownArrow")
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
        countryCodeImageView.image = UIImage(named: "DropUpArrow")
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
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        if let name = nameTextField.text, name != emptyString,
           let lastName = lastNameTextField.text, lastName != emptyString,
           let countryCode = countryCodeLabel.text, countryCode != emptyString,
           let mobile = mobileNumberTextField.text, mobile != emptyString,
           let email = emailAddressTextField.text, email != emptyString,
           let userID = userIDTextField.text, userID != emptyString,
           let password = passwordTextField.text, password != emptyString,
           let repeatPassword = repeatPasswordTextField.text, repeatPassword != emptyString,
           /*let citizenID = citizenshipIDTextField.text, citizenID != emptyString,
            let dateOfBirth = dateOfBirthTextField.text, dateOfBirth != emptyString,
            let gender = genderTextField.text, gender != emptyString,
            let documentType = documentTypeTextField.text, documentType != emptyString,*/ isEnableSignupButton() {
            
            /*if signUpViewModel.isConcession == -1 && signUpViewModel.isReseller == -1 {
             signUpViewModel.isConcession = -1
             signUpViewModel.isReseller = -1
             } else if signUpViewModel.isConcession == -1 {
             signUpViewModel.isConcession = -1
             } else if signUpViewModel.isReseller == -1 {
             signUpViewModel.isReseller = -1
             } else {*/
            
            /* We are passing default values for Date Of Birth, Gender, Document Type, Citizen ID, Until we are enabling UITextFields of the same*/
            signUpViewModel.dateOfBirth = "1981-06-01"
            signUpViewModel.documentType = "PASS"
            signUpViewModel.gender = "MALE"
            signUpViewModel.citizenshipID = "250\(Date.currentTimeStamp.string)"
            
            self.activityIndicator = self.startActivityIndicator()
            self.disableUserInteractionWhenAPICalls()
            signUpViewModel.registerUser(signUpModel: signUpViewModel, completion: handleResponseResult)
            //}
        } else {
            return
        }
    }
    
    @IBAction func concessionButtonTapped(_ sender: UIButton) {
        signUpViewModel.isConcession = sender.tag
        if sender.tag == 0 {
            yesConsessionImageView.image = Images.resellerImage
            concessionYesButton.setTitleColor(Colors.btnGreyTxt, for: .normal)
            
            noConsessionImageView.image = Images.resellerFilledImage
            concessionNoButton.setTitleColor(Colors.white, for: .normal)
            
            //concessionYesButton.removeBorderWithColor()
            //concessionNoButton.addBorderWithColor()
        } else {
            noConsessionImageView.image = Images.resellerImage
            concessionNoButton.setTitleColor(Colors.btnGreyTxt, for: .normal)
            
            yesConsessionImageView.image = Images.resellerFilledImage
            concessionYesButton.setTitleColor(Colors.white, for: .normal)
            //concessionNoButton.removeBorderWithColor()
            //concessionYesButton.addBorderWithColor()
        }
    }
    
    @IBAction func resellerButtonTapped(_ sender: UIButton) {
        signUpViewModel.isReseller = sender.tag
        if sender.tag == 0 {
            
            yesResellerImageView.image = Images.resellerImage
            resellerYesButton.setTitleColor(Colors.btnGreyTxt, for: .normal)
            
            noResellerImageView.image = Images.resellerFilledImage
            resellerNoButton.setTitleColor(Colors.white, for: .normal)
            
            //resellerYesButton.removeBorderWithColor()
            //resellerNoButton.addBorderWithColor()
        } else {
            noResellerImageView.image = Images.resellerImage
            resellerNoButton.setTitleColor(Colors.btnGreyTxt, for: .normal)
            
            yesResellerImageView.image = Images.resellerFilledImage
            resellerYesButton.setTitleColor(Colors.white, for: .normal)
            
            //resellerNoButton.removeBorderWithColor()
            //resellerYesButton.addBorderWithColor()
        }
    }
    
    private func handleResponseResult(_ result: LoginResult) {
        self.activityIndicator?.stop()
        self.enableUserInteractionWhenAPICalls()
        UIApplication.shared.endIgnoringInteractionEvents()
        switch result {
        case .success:
            UserDefaultService.setCountryISOCode(value: signUpViewModel.selectedCountryListModel?.iso ?? "")
            //UserDefaultService.setCountryCurrencyCode(value: selectedCountryListModel.currency)
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
            self.countryCodeImageView.image = UIImage(named: "DropDownArrow")
            self.countryCodeHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        switch sender.tag {
        case 1:
            signUpViewModel.name = sender.text
        case 2:
            //let value = addHyphen(sender.text ?? emptyString)
            signUpViewModel.mobileNumber = sender.text
        case 3:
            signUpViewModel.email = sender.text
        case 4:
            signUpViewModel.password = sender.text
        case 5:
            signUpViewModel.repeatPassword = sender.text
        case 6:
            signUpViewModel.citizenshipID = sender.text
        case 7:
            signUpViewModel.lastName = sender.text
        case 8:
            signUpViewModel.userID = sender.text
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
    
    private func configurePicker() {
        self.picker?.delegate = self
        self.view.addSubview(self.picker ?? UIView())
        self.picker?.pinEdgesToSuperView()
        self.picker?.viewHeight = self.view.bounds.height - 200
    }

    private func hidePicker() {
        self.picker?.removeFromSuperview()
    }

    private func showDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateSelected))
        toolbar.setItems([doneButton], animated: true)
        dateOfBirthTextField.inputAccessoryView = toolbar
        dateOfBirthTextField.inputView = datePicker
    }

    @objc private func dateSelected() {
        let selectedDate = datePicker.date.toStringCurrentTimeZone(withFormat: Date.dateTimeDOBAPI)
        dateOfBirthTextField.text = selectedDate
        self.signUpViewModel.dateOfBirth = selectedDate
        self.view.endEditing(true)
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
    }
    
    @objc func doneButtonAction() {
        DispatchQueue.main.async {
            self.mobileNumberTextField.selectedTextRange = self.mobileNumberTextField.textRange(from: self.mobileNumberTextField.endOfDocument, to: self.mobileNumberTextField.endOfDocument)
        }
        mobileNumberTextField.resignFirstResponder()
    }
    
    private func isEnableSignupButton() -> Bool {
        if nameError.attributedText == nil, lastNameError.attributedText == nil, mobileError.attributedText == nil, emailError.attributedText == nil, passwordError.attributedText == nil, repeatPasswordError.attributedText == nil, userIDError.attributedText == nil /*dateOfBirthError.attributedText == nil, citizenshipIDError.attributedText == nil, genderError.attributedText == nil, concessionError.attributedText == nil, resellerError.attributedText == nil, documentTypeError.attributedText == nil*/ {
            DispatchQueue.main.async {
                self.registerButton.setTitleColor(Colors.white, for: .normal)
                self.registerButton.isEnabled = true
                //self.registerButton.alpha = 1.0
                self.registerImageView.image = Images.button_dark_light?.setNewImageAsPerLanguage()
            }
            return true
        } else {
            DispatchQueue.main.async {
                self.registerButton.setTitleColor(Colors.textGray, for: .normal)
                self.registerButton.isEnabled = false
                //self.registerButton.alpha = 0.5
                self.registerImageView.image = Images.registerDisableButton?.setNewImageAsPerLanguage()
            }
            return false
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        if textField == mobileNumberTextField {
            
            /*if textField.text?.prefix(5) ?? "" != Constants.riyadhCountryCode {
                textField.insertText(Constants.riyadhCountryCode)
            }*/
            DispatchQueue.main.async {
                textField.selectedTextRange = textField.textRange(from: textField.endOfDocument, to: textField.endOfDocument)
            }
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //guard range.location == 0 else {
        //return true
        //}
        
        if textField == mobileNumberTextField {
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
//                    if updatedText.count < 5 || updatedText.count >= 15 {

                    if signUpViewModel.countryCodeDigits != nil {
                        if updatedText.count > signUpViewModel.countryCodeDigits ?? 0 {
                            return false
                        }
                    } else {
                        if updatedText.count >= 15 {
                            return false
                        }
                    }
                    
                    /*if let char = string.cString(using: String.Encoding.utf8) {
                     let isBackSpace = strcmp(char, "\\b")
                     if isBackSpace == -92 {
                     if textField.text?.count == 9 || textField.text?.count == 13 {
                     textField.text?.removeLast()
                     }
                     }
                     }*/
                case passwordTextField, repeatPasswordTextField, citizenshipIDTextField :
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

// MARK: - TextField delegate
extension SignUpViewController: ReportTextFieldDelegate {

    func reportTextField(_ textField: UITextField) {
        self.view.endEditing(true)
        switch textField {
        case documentTypeTextField:
            if documentTypeModel != nil {
                self.selectedTextField = documentTypeTextField
                self.picker = PickerWithDoneButton(pickerData: documentTypeModel.items.compactMap({$0.name ?? ""}), selected: selected)
                self.signUpViewModel.documentType = self.selectedTextField?.text
                configurePicker()
            }
        case genderTextField:
            self.selectedTextField = genderTextField
            self.picker = PickerWithDoneButton(pickerData: gender[0].subCategory, selected: selected)
            self.signUpViewModel.gender = self.selectedTextField?.text
            configurePicker()
        case dateOfBirthTextField:
            showDatePicker()
        default:
            break
        }
    }
}

// MARK: - Picker delegate
extension SignUpViewController: PickerWithDoneButtonDelegate {

    func doneTapped(at index: Int?, value: String?) {
        hidePicker()
        self.selectedTextField?.text = value?.localized ?? selectedTextField?.text
        switch self.selectedTextField {
        case documentTypeTextField:
            if documentTypeModel != nil {
                self.documentTypeTextField.text = self.selectedTextField?.text
                let documentType = documentTypeModel.items.first(where: {$0.name == self.documentTypeTextField.text ?? ""})
                signUpViewModel.documentType = documentType?.id
            }
        case genderTextField:
            self.genderTextField.text = self.selectedTextField?.text
            signUpViewModel.gender = self.selectedTextField?.text
        default:
            break
        }
    }

    func tappedOnShadow() {
        hidePicker()
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

extension SignUpViewController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
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
        countryCodeImageView.image = UIImage(named: "DropDownArrow")
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
                self.countryCodeImageView.image = UIImage(named: "DropDownArrow")
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

