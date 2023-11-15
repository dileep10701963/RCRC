//
//  SettingsViewController.swift
//  RCRC
//
//  Created by Errol on 27/07/20.
//

import UIKit

var applicationBuildDate: Date {
    if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"), let infoAttribute = try? FileManager.default.attributesOfItem(atPath: infoPath), let infoDate = infoAttribute[.modificationDate] as? Date {
        return infoDate
    } else {
        return Date()
    }
}

class SettingsViewController: ContentViewController {

    @IBOutlet weak var buildVersionLabel: UILabel!
    @IBOutlet weak var buildDate: UILabel!
    @IBOutlet weak var languageSelector: UISegmentedControl!
    @IBOutlet weak var launchTutorialLabel: UILabel!
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var buttonEnglish: UIButton!
    @IBOutlet weak var buttonArabic: UIButton!
    @IBOutlet weak var buttonUrdu: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .settings)
        setUpBuildInfo()
        configureLanguageSelector()
    }

    private func configureLanguageSelector() {
        buttonEnglish.isSelected = currentLanguage == .english ? true: false
        buttonArabic.isSelected = currentLanguage == .arabic ? true: false
        buttonUrdu.isSelected = currentLanguage == .urdu ? true: false
    }
    
    @IBAction func buttonEnglishTapped(_ sender: UIButton) {
        if currentLanguage != .english {
            LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            reloadRootViewController()
        }
    }
    
    @IBAction func buttonArabicTapped(_ sender: UIButton) {
        if currentLanguage != .arabic {
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            reloadRootViewController()
        }
    }
    
    @IBAction func buttonUrduTapped(_ sender: UIButton) {
        if currentLanguage != .urdu {
            LanguageService.setAppLanguageTo(lang: Languages.urdu.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            reloadRootViewController()
        }
    }

    func setUpBuildInfo() {
        buildVersionLabel.text = Constants.buildVersion.localized
        buildDate.text = "\(Bundle.main.releaseVersionNumber ?? emptyString) (\(Bundle.main.buildVersionNumber ?? emptyString))"
        //Constants.buildDate + applicationBuildDate.toString(withFormat: "dd/MM/yy", timeZone: .IST)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.settings.localized)
        self.headerTitle.text = Constants.settings.localized
        self.launchTutorialLabel.text = Constants.launchTutorial.localized
    }

    override func viewDidAppear(_ animated: Bool) {
    }

    @IBAction func languageSelectorTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if currentLanguage != .english {
                LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
                UIView.appearance().semanticContentAttribute = .forceLeftToRight
                reloadRootViewController()
            }
        case 1:
            if currentLanguage != .arabic {
                LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                reloadRootViewController()
            }
        case 2:
            if currentLanguage != .urdu {
                LanguageService.setAppLanguageTo(lang: Languages.urdu.rawValue)
                UIView.appearance().semanticContentAttribute = .forceRightToLeft
                reloadRootViewController()
            }
        default: break
        }
    }

    @IBAction func qrCodeGeneratorButtonTapped(_ sender: Any) {
        let qrCodeGeneratorViewController = QuickResponseCodeGeneratorViewController.instantiate(appStoryboard: .quickResponseCodeGenerator)
        self.present(qrCodeGeneratorViewController, animated: true)
    }

    func reloadRootViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(rootViewController)
    }

    @IBAction func launchTutorialTapped(_ sender: Any) {
        let onBoardingViewController = OnBoardingPageViewController.instantiate(appStoryboard: .onBoarding)
        onBoardingViewController.modalPresentationStyle = .fullScreen
        self.present(onBoardingViewController, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension Bundle {

    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }

}
