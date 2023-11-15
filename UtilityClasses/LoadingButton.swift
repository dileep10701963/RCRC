//
//  LoadingButton.swift
//  RCRC
//
//  Created by Errol on 23/04/21.
//

import UIKit

class LoadingButton: UIButton {

    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView?

    func showLoading(color: UIColor = .white) {
        originalButtonText = self.titleLabel?.text
        self.setTitle(emptyString, for: UIControl.State.normal)
        if activityIndicator == nil {
            activityIndicator = createActivityIndicator(color: color)
        }
        showSpinning()
    }

    func hideLoading() {
        self.setTitle(originalButtonText, for: UIControl.State.normal)
        activityIndicator?.stopAnimating()
    }

    private func createActivityIndicator(color: UIColor) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = color
        return activityIndicator
    }

    private func showSpinning() {
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator ?? UIView())
        centerActivityIndicatorInButton()
        activityIndicator?.startAnimating()
    }

    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}
