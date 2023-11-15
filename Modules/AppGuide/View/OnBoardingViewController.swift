//
//  OnBoardingViewController.swift
//  RCRC
//
//  Created by Errol on 08/12/20.
//

import UIKit

class OnBoardingPageViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([getPlanATrip()], direction: .forward, animated: false, completion: nil)
    }

    func getPlanATrip() -> PlanATrip {
        return PlanATrip.instantiateViewController // storyboard!.instantiateViewController(withIdentifier: "PlanATrip") as! PlanATrip
    }
}

extension OnBoardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }

}
