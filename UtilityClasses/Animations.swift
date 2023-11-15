//
//  Animations.swift
//  RCRC
//
//  Created by Errol on 21/08/20.
//

import Foundation
import UIKit
import Lottie

class Animations {

    static let shared = Animations()

    let tick: LottieAnimationView = {
        let animationView = LottieAnimationView(name: LottieAnimations.successTick)
        animationView.animationSpeed = 0.5
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
    }()

    func loadingDots(superView: UIView) -> LottieAnimationView {
        let animationView =  LottieAnimationView(name: LottieAnimations.loadingDots)
        animationView.animationSpeed = 0.5
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        superView.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0).isActive = true
        animationView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: 0).isActive = true
        animationView.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: 0).isActive = true
        animationView.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0).isActive = true
        return animationView
    }
}
