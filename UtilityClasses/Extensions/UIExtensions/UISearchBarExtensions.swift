//
//  UISearchBarExtensions.swift
//  RCRC
//
//  Created by Errol on 28/10/20.
//

import UIKit

// MARK: - UISearchBar Extensions
extension UISearchBar {
    // Access TextField of UISearchBar
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            for view in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }

    public var activityIndicator: UIActivityIndicatorView? {
        return textField?.leftView?.subviews.compactMap { $0 as? UIActivityIndicatorView }.first
    }

    var isLoading: Bool {
        get {
            return activityIndicator != nil
        } set {
            if newValue {
                if activityIndicator == nil {
                    DispatchQueue.main.async {
                        let newActivityIndicator = UIActivityIndicatorView(style: .white)
                        newActivityIndicator.color = Colors.rptGreen
                        newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        newActivityIndicator.startAnimating()
                        let leftViewSize = self.textField?.leftView?.frame.size ?? CGSize.zero
                        self.setImage(UIImage().scaleToSize(aSize: CGSize(width: 15, height: 15)), for: .search, state: .normal)
                        newActivityIndicator.backgroundColor = .clear
                        self.textField?.leftView?.addSubview(newActivityIndicator)
                        
                        if let leftView = self.textField?.leftView {
                            newActivityIndicator.center = leftView.convert(leftView.center, from: self.textField?.leftView?.superview)
                        } else {
                            newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                        }
                    }
                }
            } else {
                activityIndicator?.removeFromSuperview()
                setImage(UIImage(), for: .search, state: .normal)
            }
        }
    }
}
