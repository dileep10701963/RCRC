//
//  AddPaymentMethodHTMLSessionViewController.swift
//  RCRC
//
//  Created by Saheba Juneja on 13/10/22.
//

import UIKit
import WebKit

class AddPaymentMethodHTMLSessionViewController: UIViewController, WKNavigationDelegate, SuccessViewDelegate {

    @IBOutlet weak var addPaymentMethodWebView: WKWebView!
    private let viewModel = PaymentMethodViewModel()
    private var activityIndicator: UIActivityIndicatorView!
    private var sessionId: String? = ""
    private var webviewObserver: NSKeyValueObservation?
    
    @IBOutlet weak var navBarLabel: UILabel!
    static var nibName: String {
        return String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPaymentMethodHTMLSession()
        navBarLabel.text = Constants.enterDetails.localized
        addPaymentMethodWebView.navigationDelegate = self
        addPaymentMethodWebView.backgroundColor = .clear
        webviewObserver = addPaymentMethodWebView.observe(\.isLoading, options: .new) { [weak self] (object, _) in
            if object.isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.enableUserInteractionWhenAPICalls()
                self?.activityIndicator.stopAnimating()
            }
        }
        self.disableLargeNavigationTitleCollapsing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(title: "")
    }
    
    private func addPaymentMethodHTMLSession() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = startActivityIndicator()
        self.disableUserInteractionWhenAPICalls()
        viewModel.getAddPaymentMethodHTMLSession { responseResult, errr in
            switch errr {
            case .caseIgnore:
                if let htmlData = responseResult.html {
                    self.loadWebView(htmlData: htmlData)
                } else {
                    self.showOperationFailed()
                }
            case .invalidData, .invalidURL:
                self.showAlert(for: .serverError)
            case .invalidToken:
                self.showAlert(for: .invalidToken)
            default:
                self.showAlert(for: .serverError)
            }
        }
    }
    
    private func loadWebView(htmlData: String) {
        DispatchQueue.main.async {
            self.addPaymentMethodWebView.loadHTMLString(htmlData, baseURL: nil)
        }
    }
    
    private func showOperationFailed() {
        self.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                             alertMessage: Constants.serverErrorAlertMessage.localized,
                              firstActionTitle: ok,
                              firstActionHandler: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let urlString = addPaymentMethodWebView.url?.absoluteString,
              let urlComponents = URLComponents(string: urlString),
              let host = urlComponents.host,
              let paymentStatus = PaymentStatus(rawValue: host) else { return }

        switch paymentStatus {
        case .cancelled, .failure:
            showTransactionFailed()
        case .success:
            if let resultIndicator = urlComponents.queryItems?.first?.value {
                updateTransaction(resultIndicator: resultIndicator)
            } else {
                showTransactionFailed()
            }
        }
    }
    
    private func showTransactionFailed() {
        showAlert(title: Constants.transactionFailedTitle.localized, message: Constants.transactionFailedMessage.localized)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = AlertDialogController(title: title, message: message)
        let action = AlertAction()
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true) {
                action.showLoading(color: Colors.green)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.dismiss(animated: true, completion: {
                        self.navigateToExistingCardScreen()
                    })
                }
            }
        }
    }
    
    private func navigateToExistingCardScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: ExistingCardsViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateTransaction(resultIndicator: String) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = startActivityIndicator()
        viewModel.updateTransaction(resultIndicator: resultIndicator) { responseResult, errr in
            self.activityIndicator.stop()
            switch errr {
            case .caseIgnore:
                self.showTransactionSuccessful()
            default:
                self.showTransactionFailed()
            }
        }
    }
    
    private func showTransactionSuccessful() {
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        viewController.headerText = Constants.cardAddedSuccessfully.localized
        viewController.descriptionText = Constants.cardAddedSuccessfulDescription.localized
        viewController.proceedButtonText = done
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.dismiss(animated: true, completion: {
                    self.navigateToExistingCardScreen()
                })
            }
        }
    }
    
    func didTapProceed() {
        navigateToExistingCardScreen()
    }
}
