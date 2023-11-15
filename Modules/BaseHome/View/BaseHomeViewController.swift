//
//  BaseHomeViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 14/02/23.
//

import UIKit
import PDFKit
import Alamofire

class BaseHomeViewController: ContentViewController {

    let logoAnimationView = LogoAnimationView()
    @IBOutlet weak var containerView: UIView!
    var viewModel = BaseHomeViewModel()
    
    lazy var pdfView: PDFView = {
        let heightIs = UIScreen.main.bounds.size.height - ( 143 + (self.tabBarController?.tabBar.frame.size.height ?? 0))
        let view = PDFView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: heightIs))
        view.backgroundColor = UIColor.white
        view.displaysRTL = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDefaults.shared.isAppLaunched {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = true
            view.addSubview(logoAnimationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.delegate = self
        } else {
            configurePDF()
        }
        
        self.disableLargeNavigationTitleCollapsing()
        
        if let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController {
            mainViewController.delegate = self
        }
    }
    
    func configurePDF() {
        
        containerView.addSubview(pdfView)
        let openFile = self.viewModel.openPdfFile()
        var pdfURL: URL? = nil
        if let fileMURL = openFile.fileManagerURL {
            pdfURL = fileMURL
        } else {
            self.viewModel.savePDFViewAndReturnPath()
            let newOpenFile = self.viewModel.openPdfFile()
            if let fileMURL = newOpenFile.fileManagerURL {
                pdfURL = fileMURL
            } else if let bundleURL = newOpenFile.bundleURL {
                pdfURL = bundleURL
            }
        }
        
        if let pdfURL = pdfURL {
            pdfView.document = PDFDocument(url: pdfURL)
            pdfView.autoScales = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                if let self = self {
                    self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit * 3.5
                    ServiceManager.sharedInstance.pdfScaleFactor = self.pdfView.scaleFactor
                }
            }
        }
        
        if AppDefaults.shared.isMapAPICalled {
            self.getMapData()
        }
        
    }
    
    private func getMapData() {
        viewModel.getHomeMap { [weak self] baseHomeModel, error in
            DispatchQueue.main.async {
                AppDefaults.shared.isMapAPICalled = false
                guard let self = self else { return }
                if baseHomeModel != nil {
                    if let urlIs = URL(string: self.viewModel.getMapPDFURL() ?? emptyString) {
                        AF.download(urlIs).responseData { response in
                            if let data = response.value {
                                
                                let openFile = self.viewModel.openPdfFile()
                                if let fileMURL = openFile.fileManagerURL, let dataOfDir = try? Data(contentsOf: fileMURL) {
                                    if dataOfDir != data {
                                        self.viewModel.saveDownloadedPDFFile(pdfData: data)
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                            self.configurePDF()
                                        }
                                    } else {
                                       // PDF Data Matched
                                    }
                                } else {
                                    self.viewModel.saveDownloadedPDFFile(pdfData: data)
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                        self.configurePDF()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
        
        if let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController {
            mainViewController.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppDefaults.shared.isAppLaunched {
            logoAnimationView.logoGifImageView.startAnimatingGif()
        } else {
            
            let openFile = self.viewModel.openPdfFile()
            if let fileMURL = openFile.fileManagerURL, let dataOfDir = try? Data(contentsOf: fileMURL), let pdfData = self.pdfView.document?.dataRepresentation() {
                if (dataOfDir != pdfData) && (self.pdfView.scaleFactor != ServiceManager.sharedInstance.pdfScaleFactor) {
                    self.configurePDF()
                } else {
                   // Do Something
                }
            } else {
                self.configurePDF()
            }
        }
    }
    
}

extension BaseHomeViewController: SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {
        
        logoAnimationView.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        AppDefaults.shared.isAppLaunched = false
        configurePDF()
        self.view.endEditing(true)
        
        if currentLanguage == .arabic {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
            self.navigationController?.view.setNeedsUpdateConstraints()
        }
    }
}

extension BaseHomeViewController: MainViewControllerDelegate {
    
    func logoutButtonPressed() {
        showCustomAlert(alertTitle: emptyString,
                        alertMessage: Constants.logoutAlertMessage.localized,
                        firstActionTitle: Constants.logout.localized,
                        secondActionTitle: cancel,
                        secondActionStyle: .default,
                        firstActionHandler: performLogout)
    }
    
    private func performLogout() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activity = startActivityIndicator()
        let logoutViewModel = LogoutViewModel()
        logoutViewModel.logout { [weak self] _ in
            activity.stop()
            AppDefaults.shared.isUserLoggedIn = false
            UserProfileDataRepository.shared.delete()
            UserDefaultService.deleteUserName()
            ServiceManager.sharedInstance.profileModel = nil
            self?.navigateToDashboard()
        }
    }
}
