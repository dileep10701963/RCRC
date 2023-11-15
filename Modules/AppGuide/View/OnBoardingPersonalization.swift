//
//  OnBoardingFifthViewController.swift
//  RCRC
//
//  Created by Errol on 12/11/20.
//

import UIKit

class OnBoardingPersonalization: UIViewController {

    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signUpButton: UIButton!
    let signUpButtonRadius: CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGestures()
    }

    func configureGestures() {
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        rightSwipeGesture.direction = .right
        self.view.addGestureRecognizer(rightSwipeGesture)
    }

    @objc func handleSwipeGesture(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == .right {
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
        self.pageControl.currentPage = 4
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.tabBar.isHidden = true
        self.signUpButton.layer.cornerRadius = signUpButtonRadius
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        if sender.currentPage == 3 {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
    }
}
