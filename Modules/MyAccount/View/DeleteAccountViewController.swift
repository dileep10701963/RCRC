//
//  DeleteAccountViewController.swift
//  RCRC
//
//  Created by pcadmin on 19/03/21.
//

import UIKit

class DeleteAccountViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var deleteAccountButton: LoadingButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var sorryMessageLabel: UILabel!
    let myAccountViewModel = MyAccountViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.deleteAccount.localized)
        self.headerTitle.text = Constants.deleteAccount.localized
        descriptionTextView.isEditable = true
        let description = Constants.deleteDescription.localized
        let faqRange = (description as NSString).range(of: Constants.faq)
        let contactUsRange = (description as NSString).range(of: Constants.contactUs)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let mutableAttributedString = NSMutableAttributedString(string: description, attributes: [.font: Fonts.CodecRegular.eighteen as Any, .foregroundColor: Colors.rptGrey, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        mutableAttributedString.addAttribute(.link, value: Constants.faq, range: faqRange)
        mutableAttributedString.addAttribute(.link, value: "ContactUs", range: contactUsRange)
        descriptionTextView.attributedText = mutableAttributedString
        descriptionTextView.linkTextAttributes = [.foregroundColor: Colors.newGreen]
        descriptionTextView.isEditable = false
        
        sorryMessageLabel.attributedText = NSMutableAttributedString(string: Constants.deleteSorryMessage, attributes: [.font: Fonts.CodecRegular.eighteen as Any, .foregroundColor: Colors.rptGrey, NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    private func configureView() {
        deleteAccountButton.setTitle(Constants.deleteMyAccount.localized, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .deleteAccount)
//        self.addBackgroundImage()
        descriptionTextView.delegate = self
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let faqViewController = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions) as FrequentlyAskedQuestionViewController
        faqViewController.setRootView = false
        self.navigationController?.pushViewController(faqViewController, animated: true)
        /*if URL.absoluteString == Constants.faq {
            let faqViewController = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)
            self.navigationController?.pushViewController(faqViewController, animated: true)
        } else if URL.absoluteString == "ContactUs" {
            let contactUsViewController = ContactInformationViewController.instantiate(appStoryboard: .contactInformation)
            self.navigationController?.pushViewController(contactUsViewController, animated: true)
        }*/
        return false
    }

    @IBAction func deleteMyAccountTapped(_ sender: UIButton) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        deleteAccountButton.showLoading()
        myAccountViewModel.deleteAccount(completion: handleResponseResult(_:))
    }
    
    private func handleResponseResult(_ result: NetworkResult) {
        deleteAccountButton.hideLoading()
        switch result {
        case .success:
            
            AppDefaults.shared.isUserLoggedIn = false
            UserProfileDataRepository.shared.delete()
            UserDefaultService.deleteUserName()

            let deletionSuccessViewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
            deletionSuccessViewController.headerText = Constants.deletionSuccess
            deletionSuccessViewController.descriptionText = Constants.deletionSuccessDescription
            deletionSuccessViewController.proceedButtonText = done
            deletionSuccessViewController.modalPresentationStyle = .fullScreen
            deletionSuccessViewController.modalTransitionStyle = .crossDissolve
            deletionSuccessViewController.delegate = self
            self.present(deletionSuccessViewController, animated: true, completion: nil)
        case .failure(let networkError):
            self.handleDeleteFailure(networkError)
        }
    }
    
    private func handleDeleteFailure(_ error: NetworkError) {
        switch error {
        case .invalidData, .invalidURL:
            self.showAlert(for: .serverError)
        case .invalidToken:
            self.showAlert(for: .invalidToken)
        default:
            self.showAlert(for: .serverError)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text, let textRange = Range(range, in: textViewText) {
            let updatedText = textViewText.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
    
}

extension DeleteAccountViewController: SuccessViewDelegate {

    func didTapProceed() {
        self.navigateToDashboard()
    }
}

extension UITapGestureRecognizer {
    func didTapAttributedText(in label: UILabel, range: NSRange, offset: Int = 0) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText ?? NSAttributedString(string: ""))
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        let locationOfTouch = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouch.x - textContainerOffset.x,
                                                     y: locationOfTouch.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter + offset, range)
    }
}
