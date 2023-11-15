//
//  AboutKRPTViewController.swift
//  RCRC
//
//  Created by anand madhav on 03/02/21.
//

import UIKit

class AboutKRPTViewController: UIViewController {

    @IBOutlet weak var aboutTableView: UITableView!
    var aboutList = [Constants.kaptInfo, Constants.faq, Constants.facebook, Constants.twitter, Constants.instagram, Constants.youtube]
    var imageList = ["Info", "Page", "facebook", "twitter", "instagram","youtube"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.aboutKaprpt.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .aboutKRPT)
        self.aboutTableView.dataSource = self
        self.aboutTableView.delegate = self
        self.aboutTableView.register(MyAccountTableViewCell.nib, forCellReuseIdentifier: MyAccountTableViewCell.identifier)
        self.disableLargeNavigationTitleCollapsing()
    }
}

extension AboutKRPTViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyAccountTableViewCell.identifier, for: indexPath) as? MyAccountTableViewCell
        cell?.accessoryType = .none
        tableView.separatorStyle = .none
        cell?.optionLabel.textColor = Colors.green
        cell?.optionLabel.text = aboutList[indexPath.row]
        cell?.optionImage.image = UIImage(named: imageList[indexPath.row])
        return cell ?? UITableViewCell()
    }
    
    // DidSelect Row Code Updated As Per Updated About List
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let KAPRPTInfo = KAPRPTInfoViewController.instantiate(appStoryboard: .aboutKRPT)
            self.navigationController?.pushViewController(KAPRPTInfo, animated: true)
        case 1:
            let faqViewController = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions) as FrequentlyAskedQuestionViewController
            faqViewController.setRootView = false
            self.navigationController?.pushViewController(faqViewController, animated: true)
        case 2:
            ApplicationSchemes.shared.open(.facebook)
        case 3:
            ApplicationSchemes.shared.open(.twitter)
        case 4:
            ApplicationSchemes.shared.open(.instagram)
        case 5:
            ApplicationSchemes.shared.open(.youtube)
        default:
            break
        }
    }

    /*
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     tableView.deselectRow(at: indexPath, animated: true)
     switch indexPath.row {
     case 0:
     // Todo New screen will display
     //            let aboutInfo = MyAccountViewController.instantiate(appStoryboard: .myAccount)
     //            self.navigationController?.pushViewController(aboutInfo, animated: true)
     break
     case 1:
     // Todo New screen will display
     //            let frequentlyAskedQuestion = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)
     //            self.navigationController?.pushViewController(frequentlyAskedQuestion, animated: true)
     break
     case 2:
     let frequentlyAskedQuestion = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)
     self.navigationController?.pushViewController(frequentlyAskedQuestion, animated: true)
     // break
     case 3:
     ApplicationSchemes.shared.open(.facebook)
     // break
     case 4:
     ApplicationSchemes.shared.open(.twitter)
     // break
     case 5:
     ApplicationSchemes.shared.open(.instagram)
     // break
     // it will required in future.(todo)
     //        case 6:
     //          //  ApplicationSchemes.shared.open(.youtube)
     //            break
     default:
     break
     }
     }
     */
}
