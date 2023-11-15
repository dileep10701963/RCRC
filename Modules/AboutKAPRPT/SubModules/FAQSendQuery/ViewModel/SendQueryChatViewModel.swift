//
//  SendQueryChatViewModel.swift
//  RCRC
//
//  Created by Errol on 09/04/21.
//

import Foundation
import UIKit
import Alamofire

var currentTime: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a"
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    let dateString = formatter.string(from: Date())
    return dateString
}

class SendQueryChatViewModel: NSObject {

    var serverMessages: [ServerMessage]?
    var userMessages: [UserMessage]? = [UserMessage]()
    var isSentMail: ValueObservable<Bool?> = ValueObservable(nil)
    var emailSendRequest: SendEmailRequest?
    var privacyPolicyResult: Observable<LanguageSelectionModel?, Error?> = Observable(nil, nil)

    func sendMessage(_ message: String?) {
        userMessages?.append(UserMessage(time: currentTime, message: message))
        retriveMessages()
    }

    func retriveMessages() {
        serverMessages = [ServerMessage(time: currentTime, message: "Thank you for contacting customer support. We will reply back to you within the next 24 Hours.")]
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
    
    func getPrivacyPolicy(endpoint: String = URLs.privacyPolicy, completionHandler : (() -> Void)? = nil) {

        let endPoint = EndPoint(baseUrl: .privacyPolicy, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParam = TermsCondition()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: requestParam, resultData: LanguageSelectionModel.self) { result in
            switch result {
            case let .success((data, _)):
                if let data = data {
                    self.privacyPolicyResult.value = data
                }
            case .failure(_):
                break
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    func getAttributedString(model: LanguageSelectionModel) -> NSMutableAttributedString? {
        if let items = model.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 {
            
            var pContent: NSMutableAttributedString? = nil
            
            if let content = contentField.first(where: {$0.label?.lowercased() == "HTML".lowercased()}), let data = content.contentFieldValue?.data {
                pContent = data.htmlToAttributedString(font: Fonts.CodecRegular.fourteen, color: Colors.textColor)
            }
            return pContent
        } else {
            return nil
        }
    }
    
    func isArabicContentWithData(model: LanguageSelectionModel) -> (isStringEmpty: Bool, isArabic: Bool) {
        if let items = model.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 , let contentFieldValue = contentField[0].contentFieldValue, let data = contentFieldValue.data {
            return (false, data.isArabic)
        } else {
            return (true, false)
        }
    }
    
}

extension SendQueryChatViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let serverMessages = serverMessages, serverMessages.isEmpty, let userMessages = userMessages, !userMessages.isEmpty {
            return userMessages.count
        } else if let serverMessages = serverMessages, !serverMessages.isEmpty, let userMessages = userMessages, !userMessages.isEmpty {
            return userMessages.count * 2
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let serverMessages = serverMessages, serverMessages.isEmpty, let userMessages = userMessages, !userMessages.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserChatTableViewCell.identifier, for: indexPath) as? UserChatTableViewCell
            let index = indexPath.row / 2
            cell?.messageTimeLabel.text = "You at " + (userMessages[index].time ?? emptyString)
            cell?.messageLabel.text = userMessages[index].message
            return cell ?? UITableViewCell()
        } else if let serverMessages = serverMessages, !serverMessages.isEmpty, let userMessages = userMessages, !userMessages.isEmpty {
            if indexPath.row % 2 == 0 {
                let userCell = tableView.dequeueReusableCell(withIdentifier: UserChatTableViewCell.identifier, for: indexPath) as? UserChatTableViewCell
                let index = indexPath.row / 2
                userCell?.messageTimeLabel.text = "You at " + (userMessages[index].time ?? emptyString)
                userCell?.messageLabel.text = userMessages[index].message
                return userCell ?? UITableViewCell()
            } else {
                let serverCell = tableView.dequeueReusableCell(withIdentifier: ServerChatTableViewCell.identifier, for: indexPath) as? ServerChatTableViewCell
//                let index = ((indexPath.row + 1) / 2) - 1 (TO DO)
                serverCell?.messageTimeLabel.text = "Automatic Reply at " + (serverMessages[safe: 0]?.time ?? emptyString)
                serverCell?.messageLabel.text = serverMessages[safe: 0]?.message
                return serverCell ?? UITableViewCell()
            }
        } else {
            return UITableViewCell()
        }
    }
}
