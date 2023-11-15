//
//  OnBoardingViewController.swift
//  RCRC
//
//  Created by Errol on 12/11/20.
//

import UIKit

class OnBoardingPlanATrip: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
        if !UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
            skipButton.isHidden = true
        }
    }

    func configureGestures() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)
    }

    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .left {
                let onBoardingKaprptNetwork = OnBoardingKaprptNetwork.instantiate(appStoryboard: .onBoarding)
                self.navigationController?.pushViewController(onBoardingKaprptNetwork, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.pageControl.numberOfPages = ViewControllerConstants.OnBoarding.numberOfPages
        if #available(iOS 14.0, *) {
            self.pageControl.allowsContinuousInteraction = false
        } else {
            // Fallback on earlier versions
        }
        self.pageControl.currentPage = 0
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {

    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        if sender.currentPage == 1 {
            let onBoardingKaprptNetwork = OnBoardingKaprptNetwork.instantiate(appStoryboard: .onBoarding)
            self.navigationController?.pushViewController(onBoardingKaprptNetwork, animated: true)
        }
    }
}
