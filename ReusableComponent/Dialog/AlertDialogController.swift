//
//  AlertDialogViewController.swift
//  RCRC
//
//  Created by Errol on 25/08/20.
//

import UIKit

class AlertDialogController: UIViewController {

    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertActionStackView: UIStackView!
 //   @IBOutlet weak var alertActionStackViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var nameLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var messageLabelTop: NSLayoutConstraint!
    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    // If Small Screen Device, set Action Height to 30 else 42
    open var alertStackViewHeight: CGFloat = UIScreen.main.bounds.height < 568.0 ? 30 : 35
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var popupHeight: NSLayoutConstraint!
    override open func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
    }

    public convenience init(title: String, message: String) {

        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        
        
        let alertTitleAttributedText = attributedText(text: title.localized)
        let alertMessageAttributedText = attributedText(text:message.localized )

        if title.isEmpty {
            nameLabelHeight.constant = 0
        }
        alertTitle.attributedText = alertTitleAttributedText
        alertMessage.attributedText = alertMessageAttributedText
        setUpLabels()
    }

    fileprivate func setUpLabels() {

        alertTitle.font = Fonts.CodecBold.seventeen
        alertTitle.textColor = Colors.black
        alertMessage.font = Fonts.CodecRegular.fourteen
        alertMessage.textColor = Colors.darkGray
        alertTitle.textAlignment = .center
        alertMessage.textAlignment = .center
    }

    fileprivate func loadViewFromNib() -> UIView? {

        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed(Constants.alertDialogNib, owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }

    open func addAction(_ alertAction: AlertAction) {

        alertActionStackView.addArrangedSubview(alertAction)
        if alertActionStackView.arrangedSubviews.count > 2 {
//            alertActionStackViewHeightConstraint.constant = alertStackViewHeight * CGFloat(alertActionStackView.arrangedSubviews.count)
            alertActionStackView.axis = .vertical
        } else {
//            alertActionStackViewHeightConstraint.constant = alertStackViewHeight
            if alertActionStackView.arrangedSubviews.count == 1 {
//                stackViewWidth.constant = 88
            } else if alertActionStackView.arrangedSubviews.count == 2 {
//                stackViewWidth.constant = 178
            
                if currentLanguage == .arabic {
                    if alertTitle.text?.localized.lowercased() == Constants.logoutAlertTitle.localized.lowercased() {
//                        stackViewWidth.constant = 190
                    }
                }
            }
            alertActionStackView.axis = .horizontal
        }
        alertAction.addTarget(self, action: #selector(AlertDialogController.dismissAlertController(_:)), for: .touchUpInside)
    }

    
    @objc fileprivate func dismissAlertController(_ sender: AlertAction) {
        self.dismiss(animated: true, completion: nil)
    }
}

