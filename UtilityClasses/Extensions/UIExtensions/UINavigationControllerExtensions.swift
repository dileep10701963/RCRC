//
//  UINavigationControllerExtensions.swift
//  RCRC
//
//  Created by Errol on 24/05/21.
//

import UIKit

extension UINavigationController {
    func replaceTopViewController(with viewController: UIViewController, animated: Bool) {
        var viewControllers = self.viewControllers
        viewControllers[viewControllers.count - 1] = viewController
        setViewControllers(viewControllers, animated: true)
    }
}
