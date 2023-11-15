//
//  SuccessViewController.swift
//  RCRC
//
//  Created by pcadmin on 19/03/21.
//

import UIKit
import Lottie
import AVKit

protocol SuccessViewDelegate: AnyObject {
    func didTapProceed()
}

extension SuccessViewDelegate {
    func didTapProceed() {}
}

class SuccessViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var backTohomeButton: UIButton!
    @IBOutlet weak var tickImageView: UIImageView!
    
    var screenTitle: String?
    weak var delegate: SuccessViewDelegate?
    var animation: LottieAnimationView = Animations.shared.tick
    var headerText: String?
    var descriptionText: String?
    var proceedButtonText: String?
    var wantToShowGIF = false
    
    private var verifiedImage: UIImageView = {
        let image = UIImageView(image: Images.verifiedInfoImage)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .paymentSuccess)
        descriptionLabel.setAlignment()
        headerLabel.setAlignment()
        guard let headerText = self.headerText else { return }
        headerLabel.text = headerText.localized
        guard let descriptionText = self.descriptionText else { return }
        descriptionLabel.text = descriptionText.localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if wantToShowGIF {
            backTohomeButton.isHidden = false
            playVideo()
        } else {
            backTohomeButton.isHidden = true
            self.animationView.addSubview(verifiedImage)
            verifiedImage.pinEdgesToSuperView()
            proceedButton.setTitle(proceedButtonText?.localized, for: .normal)
            proceedButton.setBackgroundImage(Images.button_dark_light?.setNewImageAsPerLanguage(), for: .normal)
        }
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

    @IBAction func proceedTapped(_ sender: UIButton) {
        delegate?.didTapProceed()
        self.dismiss(animated: true, completion: nil)
    }
    
    func navigateToFareMediaScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: FareMediaViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backTohomeButtonClickAction(_ sender: UIButton) {
        self.navigateToFareMediaScreen()
    }
}

