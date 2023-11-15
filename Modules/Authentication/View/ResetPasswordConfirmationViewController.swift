//
//  ResetPasswordConfirmationViewController.swift
//  RCRC
//
//  Created by Errol on 18/01/21.
//

import UIKit
import Lottie
import AVKit

class ResetPasswordConfirmationViewController: UIViewController {
    
    @IBOutlet weak var registrationReqLabel: UILabel!
    @IBOutlet weak var checkYourEmailLabel: UILabel!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var backToProceedButton: UIButton!
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeNavigationBarTransparent()
        self.navigationController?.navigationBar.isHidden = true
        self.playVideo()
    }
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "successVideo", ofType: "mp4") else {
            debugPrint( "not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.animationView.bounds
        playerLayer.backgroundColor = UIColor.clear.cgColor
        self.animationView.layer.addSublayer(playerLayer)
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let messageAttributedText = attributedText(text: Constants.verificationRequiredText.localized, lineSapcing: 8.5)
        registrationReqLabel.attributedText = messageAttributedText
        registrationReqLabel.textAlignment = .center
        
        backToProceedButton.setBackgroundImage(backToProceedButton.currentBackgroundImage?.setNewImageAsPerLanguage(), for: .normal)
        backToProceedButton.setTitle(Constants.backtoAccount.localized, for: .normal)
    }

    @IBAction func proceedTapped(_ sender: UIButton) {
        if let viewController = navigationController?.viewControllers.first(where: { $0.isKind(of: LoginViewController.self) }) {
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.popToViewController(viewController, animated: true)
        } else {
            let viewController = LoginViewController.instantiate(appStoryboard: .authentication)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

