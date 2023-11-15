//
//  PlanATrip.swift
//  RCRC
//
//  Created by Errol on 08/12/20.
//

import UIKit

class PlanATrip: UIViewController {

    @IBOutlet weak var pageControl: CustomPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var stipImageView: UIImageView!
    
    @IBOutlet weak var bannerImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var skipImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    @IBOutlet weak var bottomBanner: UIImageView!
    
    weak var delegate: OnBoardingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSkipAndBackButton(skipButton: self.skipButton, backButton: backButton, nextButton: self.nextButton)
        hideButtonImagesFromOnboardingScreen(skipImage: self.skipImageView, backImage: self.nextImageView)
        configureView()
    }
    
    private func configureView() {
        headerLabel.text = Constants.planATrip
        contentLabel.text = Constants.planTripContent
        bannerImage.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.onBoardingHeaderAppearence()
        contentLabel.onBoardingHeaderContentAppearence()
        
        bannerImage.image = Images.appGuidePlanTrip!
        bannerImageHeight.constant = bannerImage.updateImageHeight(image: Images.appGuidePlanTrip!)
        bannerImage.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageControl.currentPage = 0
        pageControl.updateTintColorForOnboardingScreen()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        delegate?.nextButtonTapped()
    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        delegate?.pageSelected(tag: sender.tag, toPage: sender.currentPage)
    }

    @IBAction func skipButtonTapped(_ sender: UIButton) {
        delegate?.skipButtonTapped()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideSkipAndBackButton(skipButton: UIButton, backButton: UIButton, nextButton: UIButton) {
        if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
            skipButton.isHidden = true
            nextButton.isHidden = true
        } else {
            backButton.isHidden = true
        }
    }
    
    func hideButtonImagesFromOnboardingScreen(skipImage: UIImageView, backImage: UIImageView) {
        if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
            skipImage.isHidden = true
            backImage.isHidden = true
        }
    }
}

extension UIImageView {
    
    func updateImageHeight(image: UIImage) -> CGFloat {
        let ratio = image.size.width / image.size.height
        let updatedHeight = self.frame.width / ratio
        return updatedHeight
    }
}
