//
//  FareMediaPurchaseViewController.swift
//  RCRC
//
//  Created by Errol on 29/07/21.
//

import UIKit
import WebKit

final class FareMediaPurchaseViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var doNotGoBackLabel: UILabel!
    private let viewModel = FareMediaPurchaseViewModel()
    private var activityIndicator: UIActivityIndicatorView!
    private var productId: Int!
    private var isFirstClass: Bool!
    private var transactionId: Int!
    private var webviewObserver: NSKeyValueObservation?
    private var paymentMethod: String!

    static var nibName: String {
        return String(describing: self)
    }

    convenience init(productId: Int, isFirstClass: Bool, paymentMethod: String) {
        self.init(nibName: FareMediaPurchaseViewController.nibName, bundle: nil)
        self.productId = productId
        self.isFirstClass = isFirstClass
        self.paymentMethod = paymentMethod
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initiateTransaction()
        configureNavigationBar(title: Constants.payment.localized)
        doNotGoBackLabel.textColor = Colors.textColor
        let doNotGoBackText = attributedText(text: Constants.doNotGoBack.localized, lineSapcing: 3)
        doNotGoBackLabel.attributedText = doNotGoBackText
        doNotGoBackLabel.textAlignment = .center
        webview.navigationDelegate = self
        webview.backgroundColor = .clear
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webview.configuration.userContentController.addUserScript(script)
        webviewObserver = webview.observe(\.isLoading, options: .new) { [weak self] (object, _) in
            if object.isLoading {
                self?.activityIndicator.startAnimating()
            } else {
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func initiateTransaction() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = startActivityIndicator()
        viewModel.initiateTransaction(productId: productId,
                                      isFirstClass: isFirstClass,
                                      paymentMethod: paymentMethod) { [weak self] (result) in
            self?.activityIndicator.stopAnimating()
            switch result {
            case let .success(data):
                if let htmlData = data.html,
                   let transactionId = data.paymentTransactionId {
                    self?.transactionId = transactionId
                    self?.loadWebView(htmlData: htmlData)
                } else {
                    self?.showOperationFailed()
                }
            case .failure:
                self?.showOperationFailed()
            }
        }
    }

    private func updateTransaction(resultIndicator: String) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        viewModel.updateTransaction(resultIndicator: resultIndicator,
                                    transactionId: transactionId) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success(data):
                    if data.message == Constants.success {
                        self?.showTransactionSuccessful()
                    } else {
                        self?.showTransactionFailed()
                    }
                case .failure:
                    self?.showTransactionFailed()
                }
            }
        }
    }

    private func loadWebView(htmlData: String) {
        DispatchQueue.main.async {
            self.webview.loadHTMLString(htmlData, baseURL: nil)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        guard let urlString = webview.url?.absoluteString,
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

    private func showOperationFailed() {
        self.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                             alertMessage: Constants.serverErrorAlertMessage.localized,
                              firstActionTitle: ok,
                              firstActionHandler: {
            self.navigationController?.popViewController(animated: true)
        })
    }

    private func showTransactionSuccessful() {
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        viewController.headerText = Constants.paymentSuccessful.localized
        viewController.descriptionText = ""
        viewController.proceedButtonText = currentLanguage == .english ? Constants.done: Constants.paymentDoneArabic.localized
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {}
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
                        self.navigateToFareMediaScreen()
                    })
                }
            }
        }
    }

    private func navigateToFareMediaScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: FareMediaViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension FareMediaPurchaseViewController: SuccessViewDelegate {
    func didTapProceed() {
        navigateToFareMediaScreen()
    }
}
