//
//  AutomatedFare.swift
//  RCRC
//
//  Created by Errol on 09/12/20.
//

import UIKit

class AutomatedFare: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    @IBOutlet weak var nextButton: UIButton!
    weak var delegate: OnBoardingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        hideSkipAndBackButton(skipButton: self.skipButton, backButton: backButton, nextButton: self.nextButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageControl.currentPage = 3
    }

    @IBAction func pageSelected(_ sender: UIPageControl) {
        delegate?.pageSelected(tag: sender.tag, toPage: sender.currentPage)
    }

    @IBAction func skipButtonTapped(_ sender: Any) {
        delegate?.skipButtonTapped()
    }
    @IBAction func nextButtonTapped(_ sender: Any) {
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
