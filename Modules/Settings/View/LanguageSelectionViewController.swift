//
//  LanguageSelectionViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 15/02/23.
//

import UIKit


class LanguageSelectionViewController: UIViewController {

    @IBOutlet weak var buttonEnglish: UIButton! {
        didSet{
            buttonEnglish.setImage(UIImage(named:"deselected-green"), for: .normal)
            buttonEnglish.setImage(UIImage(named:"selected-green"), for: .selected)
        }
    }
     
    @IBOutlet weak var buttonArabic: UIButton! {
        didSet{
            buttonArabic.setImage(UIImage(named:"deselected-green"), for: .normal)
            buttonArabic.setImage(UIImage(named:"selected-green"), for: .selected)
        }
    }
    
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonTermConditions: UIButton!
    @IBOutlet weak var engBackground: UIView!
    @IBOutlet weak var arabicBackground: UIView!
    @IBOutlet weak var labelTermCondition: UILabel!
    @IBOutlet weak var termAndConditionButton: UIButton!
    
    let logoAnimationView = LogoAnimationView()
    let viewModel = LangaugeSelectionViewModel()
    var activityIndicator: UIActivityIndicatorView?
    var isTermAndConditionDisplayed: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLaunch()
    }
    
    private func configureLaunch() {
        if AppDefaults.shared.isAppLaunched {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            view.addSubview(logoAnimationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.delegate = self
        }
    }

    func fetchTermsAndCondtions() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = startActivityIndicator()
        viewModel.getTermsAndConditions()
        viewModel.languageSelectionResult.bind { [weak self] model, error in
            if model != nil || error != nil {
                if let self = self {
                    self.activityIndicator?.stop()
                    if let model = model {
                        DispatchQueue.main.async {
                            let contentValue = self.viewModel.getAttributedString(model: model)
                            if let content = contentValue.content {
                                self.showScrollableAlertWithAttributedContent(alertTitle: contentValue.title, alertMessage: content, buttonTitle: Constants.close) {
                                    DispatchQueue.main.async {
                                        self.enableTermAndConditionButtonWhenOkPressed()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func fetchTermsAndCondtionsWhenUnderLineButtonTapped() {

        if let model = self.viewModel.languageSelectionResult.value {
            let isArabicContentWithData = viewModel.isArabicContentWithData(model: model)
            switch isArabicContentWithData.isStringEmpty {
            case true:
                fetchTermsAndCondtions()
            case false:
                if isArabicContentWithData.isArabic == true && currentLanguage == .arabic {
                    let content = self.viewModel.getAttributedString(model: model)
                    if let contentValue = content.content {
                        self.showScrollableAlertWithAttributedContent(alertTitle: content.title, alertMessage: contentValue, buttonTitle: Constants.close) {
                            DispatchQueue.main.async {
                                self.enableTermAndConditionButtonWhenOkPressed()
                            }
                        }
                    }
                } else if isArabicContentWithData.isArabic == false && currentLanguage == .english {
                    let content = self.viewModel.getAttributedString(model: model)
                    if let contentValue = content.content {
                        self.showScrollableAlertWithAttributedContent(alertTitle: content.title, alertMessage: contentValue, buttonTitle: Constants.close) {
                            DispatchQueue.main.async {
                                self.enableTermAndConditionButtonWhenOkPressed()
                            }
                        }
                    }
                } else {
                    fetchTermsAndCondtions()
                }
            }
        } else {
            fetchTermsAndCondtions()
        }
    }
    
    @IBAction func termAndConditionTapped(_ sender: UIButton) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        fetchTermsAndCondtionsWhenUnderLineButtonTapped()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppDefaults.shared.isAppLaunched {
            logoAnimationView.logoGifImageView.startAnimatingGif()
        }
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.isHidden = true
        let text = NSMutableAttributedString(string: Constants.accept.localized, attributes: [NSAttributedString.Key.font: Fonts.CodecBold.sixteen, NSAttributedString.Key.foregroundColor: Colors.textColor])
        labelTermCondition.attributedText = text
        
        let underLineText = NSMutableAttributedString(string: Constants.termCondition.localized, attributes: [NSAttributedString.Key.font: Fonts.CodecBold.sixteen, NSAttributedString.Key.foregroundColor: Colors.textColor, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.underlineColor: Colors.textColor])
        termAndConditionButton.setAttributedTitle(underLineText, for: .normal)
        
        if currentLanguage == .arabic {
            buttonArabic.isSelected = true
            buttonEnglish.isSelected = false
        } else {
            buttonEnglish.isSelected = true
            buttonArabic.isSelected = false
        }

        self.buttonNext.alpha = 0.5
        self.buttonNext.isEnabled = false
    }
    
    @IBAction func englishButtonlanguageTapped(_ sender: UIButton) {
        buttonArabic.isSelected = false
        buttonArabic.isSelected = true
        self.engBackground.backgroundColor = UIColor(hexFromString: "F2FDF5")
        self.arabicBackground.backgroundColor = UIColor(hexFromString: "FFFFFF")
        LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
        viewModel.languageSelectionResult.value  = nil
        UIView.appearance().semanticContentAttribute = .forceLeftToRight
        self.reloadRootViewController()
    }
    
    @IBAction func arabicButtonlanguageTapped(_ sender: UIButton) {
            buttonEnglish.isSelected = false
            buttonArabic.isSelected = true
            self.arabicBackground.backgroundColor = UIColor(hexFromString: "F2FDF5")
            self.engBackground.backgroundColor = UIColor(hexFromString: "FFFFFF")
            LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
            viewModel.languageSelectionResult.value  = nil
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            self.reloadRootViewController()
    }

    @IBAction func buttonNextTapped(_ sender: UIButton) {
        if !buttonTermConditions.isSelected { return }
        AppDefaults.shared.didLaunchBefore = true
        AppDefaults.shared.isAppLaunched = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(rootViewController)
    }
    
    @IBAction func buttonTermConditionTapped(_ sender: UIButton) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        if viewModel.languageSelectionResult.value == nil {
            self.activityIndicator = startActivityIndicator()
            viewModel.getTermsAndConditions()
            viewModel.languageSelectionResult.bind { [weak self] model, error in
                if model != nil || error != nil {
                    if let self = self {
                        self.activityIndicator?.stop()
                        if let model = model {
                            DispatchQueue.main.async {
                                let content = self.viewModel.getAttributedString(model: model)
                                if let contentValue = content.content {
                                    self.showAlertPop(alertTitle: content.title, content: contentValue)
                                }
                            }
                        }
                    }
                }
            }
        } else if let model = viewModel.languageSelectionResult.value {
            let content = self.viewModel.getAttributedString(model: model).content
            if content != nil {
                buttonTermConditions.isSelected = !buttonTermConditions.isSelected
                buttonNext.isEnabled = buttonTermConditions.isSelected ? true: false
                buttonNext.alpha = buttonTermConditions.isSelected ? 1.0: 0.5
            } else {
                self.activityIndicator = startActivityIndicator()
                viewModel.getTermsAndConditions()
                viewModel.languageSelectionResult.bind { [weak self] model, error in
                    if model != nil || error != nil {
                        if let self = self {
                            self.activityIndicator?.stop()
                            if let model = model {
                                DispatchQueue.main.async {
                                    let content = self.viewModel.getAttributedString(model: model)
                                    if let contentValue = content.content {
                                        self.showAlertPop(alertTitle: content.title, content: contentValue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func showAlertPop(alertTitle: String, content: NSMutableAttributedString) {
        self.showScrollableAlertWithAttributedContent(alertTitle: alertTitle, alertMessage: content, buttonTitle: Constants.close)
        buttonTermConditions.isSelected = !buttonTermConditions.isSelected
        buttonNext.isEnabled = buttonTermConditions.isSelected ? true: false
        buttonNext.alpha = buttonTermConditions.isSelected ? 1.0: 0.5
    }

    private func enableTermAndConditionButtonWhenOkPressed() {
        buttonTermConditions.isSelected = true
        buttonNext.isEnabled = true
        buttonNext.alpha = 1.0
    }

    func reloadRootViewController() {
        AppDefaults.shared.isAppLaunched = false
        let storyboard = UIStoryboard(name: "SettingsScene", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "LanguageSelectionViewController")
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(rootViewController)
    }
}

extension LanguageSelectionViewController: SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
        AppDefaults.shared.isAppLaunched = false
    }
}

extension UIImageView {
    
    func setNewImageAsPerLanguage() -> UIImage {
        guard let currentImage = self.image else { return UIImage() }
        let templateImage = currentImage.withRenderingMode(.alwaysOriginal)
        var newImage: UIImage = templateImage
        if currentLanguage == .arabic || currentLanguage == .urdu {
            newImage = currentImage.withHorizontallyFlippedOrientation()
        } else {
            newImage = currentImage
        }
        return newImage
    }
    
}

extension UIImage {
    
    func setNewImageAsPerLanguage() -> UIImage {
        let templateImage = self.withRenderingMode(.alwaysOriginal)
        var newImage: UIImage = templateImage
        if currentLanguage == .arabic || currentLanguage == .urdu {
            newImage = templateImage.withHorizontallyFlippedOrientation()
        } else {
            newImage = templateImage
        }
        return newImage
    }
}

extension String {
    var isArabic: Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "(?s).*\\p{Arabic}.*")
        return predicate.evaluate(with: self)
    }
}
