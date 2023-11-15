//
//  OnBoardingFourthViewController.swift
//  RCRC
//
//  Created by Errol on 12/11/20.
//

import UIKit

class OnBoardingAutomatedFare: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
    }

    func configureGestures() {
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        rightSwipeGesture.direction = .right
        self.view.addGestureRecognizer(rightSwipeGesture)
    }

    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .left {
                let onBoardingPersonalization = OnBoardingPersonalization.instantiate(appStoryboard: .onBoarding)
                self.navigationController?.pushViewController(onBoardingPersonalization, animated: true)
            } else if swipeGesture.direction == .right {
                self.navigationController?.popViewController(animated: true)
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
        self.pageControl.currentPage = 3
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
        if sender.currentPage == 2 {
            self.navigationController?.popViewController(animated: true)
        } else if sender.currentPage == 4 {
            let onBoardingPersonalization = OnBoardingPersonalization.instantiate(appStoryboard: .onBoarding)
            self.navigationController?.pushViewController(onBoardingPersonalization, animated: true)
        }
    }
}
