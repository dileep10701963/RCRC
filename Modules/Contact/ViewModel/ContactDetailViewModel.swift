//
//  ContactDetailViewModel.swift
//  RCRC
//
//  Created by Admin on 22/03/21.
//

import UIKit
import Alamofire

class ContactDetailViewModel: NSObject {

    var userData: ValueObservable<MyAccountDataModel?> = ValueObservable(nil)
    var email: String?
    var phone: String?
    var name: String?
    var emailSendRequest: SendEmailRequest?
    var isSentMail: ValueObservable<Bool?> = ValueObservable(nil)

    func isValidEmail(email: String) -> Bool {
        return Validation.shared.isValidEmail(email: email)
    }
    func isValidPhoneNumber(phone: String) -> Bool {
        return Validation.shared.isValidPhone(phone: phone)
    }

    func fetchUserProfile() {
        if let records = UserProfileDataRepository.shared.fetchAll(), let record = records.first {
            let image = Utilities.getProfileImage(record.image)
            let data = MyAccountDataModel(fullName: record.fullName, mobileNumber: record.mobileNumber, emailAddress: record.emailAddress, image: image)
            userData.value = data
        } else {
            userData.value = nil
        }
    }

    func performSendEmailRequest(endpoint: String = URLs.sendEmailUrl, completion: ((_ location: SendEmailResponse?) -> Void)? = nil) {
        let endPoint = EndPoint(baseUrl: .email, methodName: endpoint, method: .post, encoder: JSONParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: emailSendRequest, res: SendEmailResponse.self) { result in
            if case let .success(result) = result {
                if result.sendEmailAttachment?.emailSentStatus == Constants.success {
                    self.isSentMail.value = true
                } else {
                    self.isSentMail.value = false
                }
                if let  completion = completion {
                    completion(result)
                }
            } else {
                self.isSentMail.value = false
                if let  completion = completion {
                    completion(nil)
                }
            }
        }
    }

}
