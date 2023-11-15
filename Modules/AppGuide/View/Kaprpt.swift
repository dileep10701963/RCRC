//
//  Kaprpt.swift
//  RCRC
//
//  Created by Errol on 08/12/20.
//

import UIKit

class Kaprpt: UIViewController {

    @IBOutlet weak var pageControl: CustomPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var bannerImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var skipImageView: UIImageView!
    @IBOutlet weak var nextImageView: UIImageView!
    
    weak var delegate: OnBoardingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSkipAndBackButton(skipButton: self.skipButton, backButton: backButton, nextButton: self.nextButton)
        hideButtonImagesFromOnboardingScreen(skipImage: self.skipImageView, backImage: self.nextImageView)
        configureView()
    }
    
    private func configureView() {
        headerLabel.text = Constants.riyadhBus
        contentLabel.text = Constants.kaprptContent
        headerLabel.onBoardingHeaderAppearence()
        contentLabel.onBoardingHeaderContentAppearence()
        
        bannerImage.image = Images.appGuideKAPRPT!
        bannerImageHeight.constant = bannerImage.updateImageHeight(image: Images.appGuideKAPRPT!)
        bannerImage.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageControl.currentPage = 1
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
