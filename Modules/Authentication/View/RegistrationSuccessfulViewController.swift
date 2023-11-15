//
//  DeviceLoginViewController.swift
//  RCRC
//
//  Created by Errol on 02/12/20.
//

import UIKit
import LocalAuthentication
import Lottie
import AVKit
import AVFoundation

class RegistrationSuccessfulViewController: UIViewController {

    @IBOutlet weak var registrationSuccessfulMessageLabel: UILabel!
    @IBOutlet weak var verificationRequiredLabel: UILabel!
    @IBOutlet weak var buttonProceed: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    private var verificationImage: UIImageView = {
        let image = UIImageView(image: Images.verificationReqInfoImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let subViews = self.navigationController?.navigationBar.subviews
        if let subviews = subViews {
            for subView in subviews where subView.tag == 1010 || subView.tag == 1040 || subView.tag == 1020 || subView.tag == 1030 || subView.tag == 1090 {
                subView.removeFromSuperview()
            }
        }
        makeNavigationBarTransparent()
        setNavigationBarAppearance(isPrimaryColorSet: false)
        hideNavigationBarBackButton()
        verificationImage.pinEdgesToSuperView()
        self.navigationController?.navigationBar.isHidden = true
        playVideo()
    }
    
    
    private func playVideo() {

        guard let path = Bundle.main.path(forResource: "successVideo", ofType: "mp4") else {
            debugPrint( "not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        playerLayer.backgroundColor = UIColor.clear.cgColor
        self.videoView.layer.addSublayer(playerLayer)
        
        player.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        makeNavigationBarGreen()
        self.navigationController?.navigationBar.isHidden = false
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

    override func viewDidLoad() {
        super.viewDidLoad()
        let messageAttributedText = attributedText(text: Constants.registrationSuccessfulMessage.localized, lineSapcing: 3)
        registrationSuccessfulMessageLabel.attributedText = messageAttributedText
        registrationSuccessfulMessageLabel.textAlignment = .center
        buttonProceed.setBackgroundImage(buttonProceed.currentBackgroundImage?.setNewImageAsPerLanguage(), for: .normal)
        verificationRequiredLabel.text = Constants.verificationRequired.localized
    }
}
