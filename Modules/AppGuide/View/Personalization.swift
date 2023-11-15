//
//  Personalization.swift
//  RCRC
//
//  Created by Errol on 09/12/20.
//

import UIKit

class Personalization: UIViewController {

    @IBOutlet weak var pageControl: CustomPageControl!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var getStartedButton: UIButton!
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var bannerImageHeight: NSLayoutConstraint!
    @IBOutlet weak var signUpImageView: UIImageView!
    
    weak var delegate: OnBoardingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
            self.getStartedButton.isHidden = true
            self.signUpButton.isHidden = true
            self.backButton.isHidden = false
        } else {
            self.backButton.isHidden = true
        }
        configureView()
    }
    
    private func configureView() {
        headerLabel.text = Constants.personalization
        contentLabel.text = Constants.PersonalizationContent
        headerLabel.onBoardingHeaderAppearence()
        contentLabel.onBoardingHeaderContentAppearence()
        
        bannerImage.image = Images.appGuidePersonalization!
        bannerImageHeight.constant = bannerImage.updateImageHeight(image: Images.appGuidePersonalization!)
        bannerImage.layoutIfNeeded()
        
        if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
            signUpImageView.isHidden = true
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageControl.currentPage = 3
        pageControl.updateTintColorForOnboardingScreen()
    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        delegate?.pageSelected(tag: sender.tag, toPage: sender.currentPage)
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        delegate?.signUpButtonTapped()
    }

    @IBAction func getStartedButtonTapped(_ sender: Any) {
        delegate?.getStartedButtonTapped()
//        if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
//            self.dismiss(animated: true, completion: nil)
//        } else {
//            delegate?.getStartedButtonTapped()
//        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
