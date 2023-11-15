//
//  PlacesOfInterest.swift
//  RCRC
//
//  Created by Errol on 08/12/20.
//

import UIKit

class PlacesOfInterest: UIViewController {

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
        headerLabel.text = Constants.onBoardingPlacesOfInterest
        contentLabel.text = Constants.placesOfInterestContent
        headerLabel.onBoardingHeaderAppearence()
        contentLabel.onBoardingHeaderContentAppearence()
        
        bannerImage.image = Images.appGuidePlaceOfInterest!
        bannerImageHeight.constant = bannerImage.updateImageHeight(image: Images.appGuidePlaceOfInterest!)
        bannerImage.layoutIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageControl.currentPage = 2
        pageControl.updateTintColorForOnboardingScreen()
    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        delegate?.pageSelected(tag: sender.tag, toPage: sender.currentPage)
    }
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        delegate?.skipButtonTapped()
    }
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        delegate?.nextButtonTapped()
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

class CustomPageControl: UIPageControl {

@IBInspectable var currentPageImage: UIImage?

@IBInspectable var otherPagesImage: UIImage?

override var numberOfPages: Int {
    didSet {
        updateDots()
    }
}

override var currentPage: Int {
    didSet {
        updateDots()
    }
}

override func awakeFromNib() {
    super.awakeFromNib()
    
    if #available(iOS 14.0, *) {
        defaultConfigurationForiOS14AndAbove()
    } else {
        pageIndicatorTintColor = .clear
        currentPageIndicatorTintColor = .clear
        clipsToBounds = false
    }
}

private func defaultConfigurationForiOS14AndAbove() {
    if #available(iOS 14.0, *) {
        for index in 0..<numberOfPages {
            let image = index == currentPage ? currentPageImage : otherPagesImage
            setIndicatorImage(image, forPage: index)
        }
        
        // give the same color as "otherPagesImage" color.
        pageIndicatorTintColor = Colors.lightGrey
        
        // give the same color as "currentPageImage" color.
        currentPageIndicatorTintColor = Colors.newGreen
//        tintColor = Colors.weatherBlue
        /*
         Note: If Tint color set to default, Indicator image is not showing. So, give the same tint color based on your Custome Image.
        */
    }
}
    
    func updateTintColorForOnboardingScreen() {
        if #available(iOS 14.0, *) {
            for index in 0..<numberOfPages {
                let image = index == currentPage ? currentPageImage : otherPagesImage
                setIndicatorImage(image, forPage: index)
            }
            
            pageIndicatorTintColor = .white
            currentPageIndicatorTintColor = Colors.green
        }
    }

private func updateDots() {
    if #available(iOS 14.0, *) {
        defaultConfigurationForiOS14AndAbove()
    } else {
        for (index, subview) in subviews.enumerated() {
            let imageView: UIImageView
            if let existingImageview = getImageView(forSubview: subview) {
                imageView = existingImageview
            } else {
                imageView = UIImageView(image: otherPagesImage)
                
                imageView.center = subview.center
                subview.addSubview(imageView)
                subview.clipsToBounds = false
            }
            imageView.image = currentPage == index ? currentPageImage : otherPagesImage
        }
    }
}

private func getImageView(forSubview view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView {
        return imageView
    } else {
        let view = view.subviews.first { (view) -> Bool in
            return view is UIImageView
        } as? UIImageView

        return view
    }
}
}
