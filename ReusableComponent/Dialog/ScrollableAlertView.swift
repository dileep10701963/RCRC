//
//  ScrollableAlertView.swift
//  RCRC
//
//  Created by Saheba Juneja on 16/02/23.
//

import UIKit

class ScrollableAlertView: UIViewController {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var popUpBackground: UIImageView!
    
    
    var action: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func okButtonAction(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.action?()
    }
    
    public convenience init(title: String, attributedMessage: NSMutableAttributedString, buttonTitle: String = emptyString) {

        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        
        let alertTitleAttributedText = attributedText(text: title.localized)
        titleLabel.attributedText = alertTitleAttributedText
        titleLabel.textAlignment = .center
        messageTextView.attributedText = attributedMessage
        messageTextView.setAlignment()
        self.updateTextViewFrame()
        
        if buttonTitle != emptyString {
            buttonOk.setTitle(buttonTitle.localized, for: .normal)
        } else {
            buttonOk.setTitle(Constants.close.localized, for: .normal)
        }
        
    }
    
    func updateTextViewFrame() {
        let frame: CGFloat = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.height ?? 0
        let viewHeight = frame - 160.0
        
        if messageTextView.contentSize.height > viewHeight {
            heightConstraint.priority = UILayoutPriority(250)
            viewTopConstraint.priority = UILayoutPriority(999)
            viewBottomConstraint.priority = UILayoutPriority(999)
//            popUpBackground.image = Images.popUpLargeBackground
        } else {
            heightConstraint.priority = UILayoutPriority(999)
            viewTopConstraint.priority = UILayoutPriority(250)
            viewBottomConstraint.priority = UILayoutPriority(250)
//            popUpBackground.image = Images.popUpBackground
        }
        
        
    }
    
    public convenience init(title: String, message: String) {

        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        
        let alertTitleAttributedText = attributedText(text: title.localized)
        let alertMessageAttributedText = attributedText(text:message.localized)
        
        titleLabel.attributedText = alertTitleAttributedText
        titleLabel.textAlignment = .center
        messageTextView.attributedText = alertMessageAttributedText
    }

    fileprivate func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed("ScrollableAlertView", owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }
}
