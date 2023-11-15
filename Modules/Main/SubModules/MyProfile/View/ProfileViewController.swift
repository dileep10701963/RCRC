//
//  ProfileViewController.swift
//  RCRC
//
//  Created by anand madhav on 10/06/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit

protocol ProfileDelegate: AnyObject {

    func updateProfile(image: UIImage, name: String)
}

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    let profileViewModel = MyAccountViewModel()
    var myAccountData: MyAccountDataModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .profile)
        self.configureNavigationBar(title: "My Profile".localized)
        configureObserver()
        profileViewModel.fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
    }
}

extension ProfileViewController {

    private func configureObserver() {
        profileViewModel.myAccountData.bind { [weak self] (data) in
            if let data = data {
                self?.nameLabel.text = "Full Name: " + (data.fullName ?? "-----")
                self?.mobileNumberLabel.text = "Mobile Number: " + (data.mobileNumber ?? "-----")
                self?.emailAddressLabel.text = "Email Address: " + (data.emailAddress ?? "-----")
                self?.profileImage.image = data.image
            } else {
                self?.nameLabel.text = "-----"
                self?.mobileNumberLabel.text = "-----"
                self?.emailAddressLabel.text = "-----"
                self?.profileImage.image = Images.profileImagePlaceholder
            }
        }
    }
}
