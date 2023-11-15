//
//  LoginViewController.swift
//  RCRC
//
//  Created by Errol on 02/12/20.
//

import UIKit
import LocalAuthentication

enum LoginRootView {
    case appGuide, myAccount
}

class LoginViewController: UIViewController {

    @IBOutlet weak var emailAddressTextField: UITextField! {
        didSet {
            loginViewModel.email = emailAddressTextField.text
        }
    }

    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            loginViewModel.password = passwordTextField.text
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dontHaveAcc: UILabel!
    
    let loginViewModel = LoginViewModel()
    let myAccountViewModel = MyAccountViewModel()
    
    var error: NSError?
    var context = LAContext()

    weak var profileDelegate: ProfileViewDelegate?

    enum AuthenticationState {
        case loggedIn, loggedOut
    }

    var state = AuthenticationState.loggedOut
    var shouldRedirectToTickets: Bool = false
    var tabController:RCRCTabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let isBiometricsEnabled = AppDefaults.shared.isBiometricsEnabled
        emailAddressTextField.setAlignment()
        passwordTextField.setAlignment()
        emailAddressTextField.tintColor = Colors.green
        passwordTextField.tintColor = Colors.green
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.enablePasswordToggle()
        backButton.setAlignment()
        dontHaveAcc.setAlignment()
   }
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.endEditing(true)
        self.navigationController?.isNavigationBarHidden = true
        self.configureNavigationBar(title: "")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func viewPasswordTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()
        let isPasswordVisible = sender.currentImage == Images.showPassword
    }

    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
//        let forgotPasswordViewController = ForgotPasswordViewController.instantiate(appStoryboard: .authentication)
//        makeNavigationBarGreen()
//        self.navigationController?.pushViewController(forgotPasswordViewController, animated: true)
        showTransactionSuccessful()
    }
    
    
    func showTransactionSuccessful() {
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        viewController.headerText = Constants.paymentSuccessful.localized
        viewController.descriptionText = Constants.paymentSuccessfulDescription.localized
        viewController.proceedButtonText = done
//        viewController.delegate = self
        viewController.wantToShowGIF = true
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.dismiss(animated: true, completion: {
                  //  self.navigateToFareMediaScreen()
                })
            }
        }
    }

    private func navigate() {
        AppDefaults.shared.isUserLoggedIn = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            appDelegate?.changeRootViewController(rootViewController, animated: true)
    }

    private func getViewController(_ kind: AnyClass?) -> UIViewController? {
        guard let kind = kind else { return nil }
        return self.tabBarController?.viewControllers?.first(where: { viewController in
            viewController.children.contains { $0.isKind(of: kind) }
        })
    }

    @IBAction func signInTapped(_ sender: UIButton) {
      
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let emaildID = emailAddressTextField.text ?? emptyString
        let password = passwordTextField.text ?? emptyString
        
        if password == "" && emaildID == "" {
            self.showCustomAlert(alertTitle: emptyString, alertMessage: Constants.emptyFieldMessageSignIn.localized, firstActionTitle: ok, firstActionStyle: .default)
        } else {
            self.disableUserInteractionWhenAPICalls()
            loginViewModel.login(user: emailAddressTextField.text ?? emptyString, password: passwordTextField.text ?? emptyString, completion: handleLoginResult)
        }
        
    }

    private func handleLoginResult(_ result: LoginResult) {
        self.enableUserInteractionWhenAPICalls()
        switch result {
        case .success:
            
            myAccountViewModel.fetchProfileDetails()
            myAccountViewModel.profileDetailsResult.bind{ [weak self] (profile, error) in
                DispatchQueue.main.async {
                    if profile != nil || error != nil {
                        if self != nil {
                            if let profile = profile {
                                ServiceManager.sharedInstance.profileModel = profile
                            }
                        }
                        self?.emailAddressTextField.text = .none
                        self?.passwordTextField.text = .none
                        self?.navigate()
                    }
                }
            }
        case let .failure(errorMessage):
         //   self.signInButton.hideLoading()
            self.showCustomAlert(alertTitle: Constants.loginFailed.localized, alertMessage: errorMessage, firstActionTitle: ok, firstActionStyle: .default)
        }
    }

    @IBAction func biometricSwitch(_ sender: UISwitch) {

        if sender.isOn {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                UserDefaults.standard.set(true, forKey: Constants.biometricsKey)
            } else {
                self.showCustomAlert(alertTitle: Constants.deviceIncompatible,
                                     alertMessage: Constants.deviceNotSupported,
                                     firstActionTitle: ok,
                                     firstActionStyle: .default)
            }
        } else if sender.isOn == false {
            UserDefaults.standard.set(false, forKey: Constants.biometricsKey)
        }
    }

    @IBAction func registerNowTapped(_ sender: Any) {
       
        if let viewController = navigationController?.viewControllers.first(where: { $0.isKind(of: RegisterViewController.self) }) {
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            let viewController = RegisterViewController.instantiate(appStoryboard: .authentication)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

//    @IBAction func biometricLoginTapped(_ sender: Any) {
//        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
//            return
//        }
//        if biometricSwitch.isOn {
//            if AppDefaults.shared.isBiometricsEnabled {
//                state = .loggedOut
//                if state == .loggedIn {
//                    state = .loggedOut
//                } else {
//                    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
//                        let reason = Constants.policyError.localized
//                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { [weak self] success, error in
//                            if success {
//                                DispatchQueue.main.async {
//                                    self?.state = .loggedIn
//                                    self?.signInButton.showLoading()
//                                }
//                                self?.loginViewModel.login(user: "mobilityportal1", password: "mobilityPortal1") { result in
//                                    self?.handleLoginResult(result)
//                                }
//                            } else {
//                                print(error?.localizedDescription ?? Constants.authenticationFailure.localized)
//                            }
//                        }
//                    } else {
//                        print(error?.localizedDescription ?? Constants.policyError.localized)
//                    }
//                }
//            }
//        }
//    }
    
    @IBAction func buttonLngSecondTapped(_ sender: UIButton) {
    
        if currentLanguage == .english {
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            appDelegate?.changeRootViewController(rootViewController, animated: true)
        } else {
            LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            appDelegate?.changeRootViewController(rootViewController, animated: true)
        }
    }
}

extension LoginViewController: HamburgerMenuDelegate {

    func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
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
