//
//  ShimmerView.swift
//  RCRC
//
//  Created by Errol on 15/09/20.
//

import UIKit

extension UIView {

    func addGradientLayer() -> CAGradientLayer {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [UIColor(white: 0.85, alpha: 1.0).cgColor, UIColor(white: 0.95, alpha: 1.0).cgColor, UIColor(white: 0.85, alpha: 1.0).cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        return gradientLayer
    }

    func addAnimation() -> CABasicAnimation {

        let animation = CABasicAnimation(keyPath: Constants.shimmerKeyPath)
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }

    func startShimmering() {

        let gradientLayer = addGradientLayer()
        let animation = addAnimation()
        gradientLayer.add(animation, forKey: animation.keyPath)
    }

    func stopShimmering() {
        self.layer.mask = nil
        self.layer.sublayers?.removeLast()
    }
    

        /// Flip view horizontally.
        func flipX() {
            transform = CGAffineTransform(scaleX: -transform.a, y: transform.d)
        }

        /// Flip view vertically.
        func flipY() {
            transform = CGAffineTransform(scaleX: transform.a, y: -transform.d)
        }
     
}
