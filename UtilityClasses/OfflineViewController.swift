//
//  OfflineViewController.swift
//  RCRC
//
//  Created by Errol on 05/04/21.
//

import UIKit
import Alamofire

class OfflineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tryAgainTapped(_ sender: Any) {
        if NetworkReachabilityManager()!.isReachable {
            self.dismiss(animated: true, completion: nil)
        } else {
            return
        }
    }
}
