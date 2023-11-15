//
//  UIActivityIndicatorViewExtensions.swift
//  RCRC
//
//  Created by Errol on 09/11/20.
//

import UIKit

extension UIActivityIndicatorView {

    func stop() {
        self.stopAnimating()
        self.removeFromSuperview()
    }
//    func stopAnimating()  {
//        self.stopAnimating()
//
//        if let indicatorBG = self.superview as? UIView ,indicatorBG.tag == 101 {
//            indicatorBG.removeFromSuperview()
//        }
//        self.removeFromSuperview()
//    }
}
