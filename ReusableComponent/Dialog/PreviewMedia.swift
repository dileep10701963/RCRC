//
//  PreviewMedia.swift
//  RCRC
//
//  Created by Saheba Juneja on 15/06/23.
//

import Foundation
import UIKit

class PreviewMedia: UIView {
    @IBOutlet weak var okButtonOutlet: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!

    class func instanceFromNib(view: UIViewController, image: UIImage) -> PreviewMedia {
        let nib = UINib(nibName: "PreviewMedia", bundle: nil).instantiate(withOwner: self, options: nil).first as? PreviewMedia ?? PreviewMedia()
        nib.imageView.image = image
        nib.okButtonOutlet.setTitle(ok.localized, for: .normal)
        nib.addTapGesture(nib: nib)
        return nib
    }
    
    private func addTapGesture(nib:PreviewMedia) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        nib.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture() {
        self.removeFromSuperview()
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
