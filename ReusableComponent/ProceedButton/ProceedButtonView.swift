//
//  ProceedButtonView.swift
//  RCRC
//
//  Created by Errol on 29/10/20.
//

import UIKit

protocol ProceedButtonDelegate: AnyObject {
    func didTapProceed()
    func reloadTableView(hideData: Bool)
}

extension ProceedButtonDelegate {
    func reloadTableView(hideData: Bool) {}
}

class ProceedButtonView: UIView {

   // @IBOutlet weak var buttonImageVIew: UIImageView!
    @IBOutlet weak var proceedButton: UIButton!
    
    var contentView: UIView!
    weak var delegate: ProceedButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureXib()
        //buttonImageVIew.image = buttonImageVIew.image?.setNewImageAsPerLanguage()
    }

    @IBAction func proceedButtonTapped(_ sender: UIButton) {
        delegate?.didTapProceed()
    }

    func hide() {
        delegate?.reloadTableView(hideData: false)
        alpha = 0.0
    }

    func show() {
        delegate?.reloadTableView(hideData: true)
        alpha = 1.0
    }

    func configureXib() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let nibName = ReusableViews.proceedButtonView
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
