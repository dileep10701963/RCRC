//
//  UIButtonExtensions.swift
//  RCRC
//
//  Created by Errol on 28/10/20.
//

import UIKit

extension UIButton {
    /// Set Left and Right Image for an UIButton
    /// - Parameters:
    ///   - right: Left Image
    ///   - left: Right Image
    func setImages(left: UIImage? = nil, right: UIImage? = nil) {
        if LanguageService.currentAppLanguage() == "en" {
            self.titleLabel?.textAlignment = .left
            self.translatesAutoresizingMaskIntoConstraints = false
            if let rightImage = right, left == nil {
                let rightImageView = UIImageView(image: rightImage)
                rightImageView.contentMode = .scaleAspectFit
                rightImageView.tintColor = Colors.buttonTintColor
                rightImageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                addSubview(rightImageView)
                rightImageView.translatesAutoresizingMaskIntoConstraints = false
                rightImageView.contentMode = .scaleAspectFit
                
                rightImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
                rightImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
                rightImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
                rightImageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
                let lConstraint = NSLayoutConstraint(item: rightImageView, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 5)
                lConstraint.priority -= 1
                self.addConstraints([lConstraint])
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
            if let rightImage = right, let leftImage = left {
                self.setImage(leftImage, for: .normal)
                self.imageEdgeInsets.right = 5
                self.contentEdgeInsets.right = leftImage.size.width + 15
                self.layoutIfNeeded()
                let rightImageView = UIImageView(image: rightImage)
                rightImageView.tintColor = Colors.buttonTintColor
                rightImageView.contentMode = .scaleAspectFit
                addSubview(rightImageView)
                rightImageView.translatesAutoresizingMaskIntoConstraints = false
                rightImageView.contentMode = .scaleAspectFit
                let rightImageLeadingConstraint = NSLayoutConstraint(item: rightImageView, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 5)
                let rightImageTrailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: rightImageView, attribute: .trailing, multiplier: 1, constant: 10)
                let rightImageVerticalConstraint = NSLayoutConstraint(item: rightImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                self.addConstraints([rightImageLeadingConstraint, rightImageTrailingConstraint, rightImageVerticalConstraint])
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
        } else if LanguageService.currentAppLanguage() == "ar" || LanguageService.currentAppLanguage() == "ur" {
            self.contentHorizontalAlignment = .right
            self.titleLabel?.textAlignment = .right
            self.translatesAutoresizingMaskIntoConstraints = false
            if let rightImage = right, left == nil {
                let rightImageView = UIImageView(image: rightImage)
                addSubview(rightImageView)
                rightImageView.translatesAutoresizingMaskIntoConstraints = false
                rightImageView.contentMode = .scaleAspectFit
                let lConstraint = NSLayoutConstraint(item: rightImageView, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 5)
                lConstraint.priority -= 1
                let tConstraint = NSLayoutConstraint(item: rightImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -10)
                let vConstraint = NSLayoutConstraint(item: rightImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                self.addConstraints([lConstraint, tConstraint, vConstraint])
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
            if let rightImage = right, let leftImage = left {

                self.contentEdgeInsets.right = leftImage.size.width + 5
                self.layoutIfNeeded()
                let rightImageView = UIImageView(image: rightImage)
                addSubview(rightImageView)
                rightImageView.translatesAutoresizingMaskIntoConstraints = false
                rightImageView.contentMode = .scaleAspectFit
                let rightImageLeadingConstraint = NSLayoutConstraint(item: rightImageView, attribute: .leading, relatedBy: .equal, toItem: self.titleLabel, attribute: .trailing, multiplier: 1, constant: 5)
                let rightImageTrailingConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: rightImageView, attribute: .trailing, multiplier: 1, constant: 10)
                let rightImageVerticalConstraint = NSLayoutConstraint(item: rightImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                self.addConstraints([rightImageLeadingConstraint, rightImageTrailingConstraint, rightImageVerticalConstraint])

                let leftImageView = UIImageView(image: leftImage)
                addSubview(leftImageView)
                leftImageView.translatesAutoresizingMaskIntoConstraints = false
                leftImageView.contentMode = .scaleAspectFit
                let leftImageLeadingConstraint = NSLayoutConstraint(item: leftImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 5)
                let leftImageTrailingConstraint = NSLayoutConstraint(item: leftImageView, attribute: .trailing, relatedBy: .equal, toItem: self.titleLabel, attribute: .leading, multiplier: 1, constant: -5)
                let leftImageVerticalConstraint = NSLayoutConstraint(item: leftImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
                self.addConstraint(leftImageLeadingConstraint)
                self.addConstraint(leftImageTrailingConstraint)
                self.addConstraint(leftImageVerticalConstraint)
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
            }
        }
    }

    func setAlignment() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.titleLabel?.textAlignment = .right
        } else {
            self.titleLabel?.textAlignment = .left
        }
    }

    func setContentHorizontalAlignment() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.contentHorizontalAlignment = .right
        } else {
            self.contentHorizontalAlignment = .left
        }
    }
    
    func setShadow() {
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func addBorderWithColor() {
        self.layer.borderWidth = 1.2
        self.layer.borderColor = Colors.green.cgColor
        self.setTitleColor(Colors.green, for: .normal)
    }
    
    func removeBorderWithColor() {
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.clear.cgColor
        self.titleLabel?.textColor = UIColor.black
    }
}
