//
//  TouchIDAuthenticationViewController.swift
//  RCRC
//
//  Created by Errol on 02/09/20.
//

import UIKit
import LocalAuthentication

open class TouchIDAuthenticationViewController: UIViewController {

    var context = LAContext()

    enum AuthenticationState {
        case loggedIn, loggedOut
    }

    var state = AuthenticationState.loggedOut

    override open func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        guard let view = loadViewFromNib() else { return }
        self.view = view
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        state = .loggedOut

        if state == .loggedIn {
            state = .loggedOut
        } else {
            context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = Constants.authenticationReason.localized
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason ) { success, error in
                    if success {
                        DispatchQueue.main.async { [unowned self] in
                            self.state = .loggedIn
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        print(error?.localizedDescription ?? Constants.authenticationFailure.localized)
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                print(error?.localizedDescription ?? Constants.policyError.localized)
            }
        }
    }

    fileprivate func loadViewFromNib() -> UIView? {

        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed(Constants.authenticationNib, owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }
}
