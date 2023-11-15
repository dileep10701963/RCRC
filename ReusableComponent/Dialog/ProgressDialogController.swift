//
//  ProgressDialogController.swift
//  RCRC
//
//  Created by Errol on 26/08/20.
//

import UIKit

class ProgressDialogController: UIViewController {

    @IBOutlet weak var progressDialogView: UIView!
    @IBOutlet weak var dialogTitle: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override open func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
    }

    public convenience init(title: String?) {

        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        setUpLayer()
        setUpLabels()
        dialogTitle.text = title
        showActivityIndicator()
    }

    func showActivityIndicator() {
         if #available(iOS 13.0, *) {
             activityIndicator.style = .large
         } else {
             activityIndicator.style = .whiteLarge
        }
        activityIndicator.color = Colors.green
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }

    fileprivate func loadViewFromNib() -> UIView? {

        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed(Constants.progressDialogNib, owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }

    fileprivate func setUpLabels() {

        dialogTitle.font = Fonts.RptaSignage.twenty
        dialogTitle.textColor = Colors.rptGreen
        dialogTitle.textAlignment = .center
    }

    fileprivate func setUpLayer() {

        progressDialogView.layer.cornerRadius = 10
        progressDialogView.backgroundColor = .white
        progressDialogView.layer.masksToBounds = false
        progressDialogView.layer.shadowOffset = CGSize(width: 0, height: 0)
        progressDialogView.layer.shadowRadius = 8
        progressDialogView.layer.shadowOpacity = 0.3
        self.view.backgroundColor = Colors.dialogBackground
    }
}
