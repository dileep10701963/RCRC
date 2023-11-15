//
//  OnBoardingViewController.swift
//  RCRC
//
//  Created by Errol on 08/12/20.
//

import UIKit

enum OnboardingScenes {
    case planATrip
    case kaprptNetwork
    case placesOfInterest
    case automatedFare
    case personalization
}

protocol OnBoardingDelegate: AnyObject {
    func nextButtonTapped()
    func pageSelected(tag: Int, toPage: Int)
    func skipButtonTapped()
    func getStartedButtonTapped()
    func signUpButtonTapped()
}

class OnBoardingPageViewController: UIPageViewController {

    var planATrip: PlanATrip = PlanATrip.instantiate(appStoryboard: .onBoarding)
    var kaprptNetwork: Kaprpt = Kaprpt.instantiate(appStoryboard: .onBoarding)
    var placesOfInterest: PlacesOfInterest = PlacesOfInterest.instantiate(appStoryboard: .onBoarding)
    var personalization: Personalization = Personalization.instantiate(appStoryboard: .onBoarding)
    //var automatedFare: AutomatedFare = AutomatedFare.instantiate(appStoryboard: .onBoarding)

    let logoAnimationView = LogoAnimationView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppDefaults.shared.isAppLaunched {
            logoAnimationView.logoGifImageView.startAnimatingGif()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDefaults.shared.isAppLaunched {
            view.addSubview(logoAnimationView)
            logoAnimationView.pinEdgesToSuperView()
            logoAnimationView.logoGifImageView.delegate = self
        }
        
        dataSource = self
        setViewControllers([planATrip], direction: .forward, animated: false, completion: nil)
        configureDelegates()
    }

    func configureDelegates() {
        planATrip.delegate = self
        kaprptNetwork.delegate = self
        placesOfInterest.delegate = self
        personalization.delegate = self
        //automatedFare.delegate = self
    }
}

extension OnBoardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: Personalization.self) {
            return placesOfInterest
        } else if viewController.isKind(of: AutomatedFare.self) {
            return placesOfInterest
        } else if viewController.isKind(of: PlacesOfInterest.self) {
            return kaprptNetwork
        } else if viewController.isKind(of: Kaprpt.self) {
            return planATrip
        } else {
            return nil
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: PlanATrip.self) {
            return kaprptNetwork
        } else if viewController.isKind(of: Kaprpt.self) {
            return placesOfInterest
        } else if viewController.isKind(of: PlacesOfInterest.self) {
            return personalization
        } else if viewController.isKind(of: AutomatedFare.self) {
            return personalization
        } else {
            return nil
        }
    }

    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 4
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension OnBoardingPageViewController: OnBoardingDelegate {

    func signUpButtonTapped() {
        AppDefaults.shared.didLaunchBefore = true
        loginRootView = .appGuide
        let viewController: SignUpViewController = SignUpViewController.instantiate(appStoryboard: .authentication)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func getStartedButtonTapped() {
        AppDefaults.shared.didLaunchBefore = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(rootViewController)
    }

    func skipButtonTapped() {
        AppDefaults.shared.didLaunchBefore = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
        (UIApplication.shared.delegate as? AppDelegate)?.changeRootViewController(rootViewController)
    }

    func nextButtonTapped() {
        self.goToNextPage()
    }

    func pageSelected(tag: Int, toPage: Int) {
        switch tag {
        case 0:
            if toPage == 1 {
                self.goToNextPage()
            }
        case 1:
            if toPage == 2 {
                self.goToNextPage()
            } else {
                self.goToPreviousPage()
            }
        case 2:
            if toPage == 3 {
                self.goToNextPage()
            } else {
                self.goToPreviousPage()
            }
        case 3:
            if toPage == 4 {
                self.goToNextPage()
            } else {
                self.goToPreviousPage()
            }
        case 4:
            if toPage == 3 {
                self.goToPreviousPage()
            }
        default:
            break
        }
    }
}

extension OnBoardingPageViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
        AppDefaults.shared.isAppLaunched = false
    }
}
