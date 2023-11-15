//
//  ReportIncidenceViewModel.swift
//  RCRC
//
//  Created by Ganesh on 30/06/21.
//

import Foundation
import UIKit
import Alamofire

final class ReportIncidenceViewModel: NSObject {
    var reportData = IncidentModel()
    var isSentMail: ValueObservable<Bool?> = ValueObservable(nil)
    var upLoadProgress: ValueObservable<UploadProgress?> = ValueObservable(nil)
    var uploadStatus: ValueObservable<UploadStatus?> = ValueObservable(nil)
    var attachmentIDs: [String] = []
    var attachedFileName: String = ""
    var emailSendRequest: SendEmailRequest?

    func performFileUploadRequest(endpoint: String = URLs.uploadFileUrl, request: FileUploadRequest, index: Int, completion: ((_ location: FileUploadResponse?) -> Void)? = nil) {

        let endPoint = EndPoint(baseUrl: .email, methodName: endpoint, method: .post, encoder: JSONParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: FileUploadResponse.self) { progress in
            let progres = UploadProgress(progress: Float(progress ?? 0.0), index: index, image: nil)
            self.upLoadProgress.value = progres
        } completion: { result in
            if case let .success(result) = result {
                self.attachmentIDs.append("\(result.attachmentID ?? "")")
                self.attachedFileName = result.fileName ?? ""
                self.uploadStatus.value = UploadStatus(hasUploaded: true, index: index)
                if let completion = completion {
                    completion(result)
                }
            } else {
                self.uploadStatus.value = UploadStatus(hasUploaded: false, index: index)
                if let completion = completion {
                    completion(nil)
                }
            }
        }
    }

    func performSendEmailRequest(endpoint: String = URLs.sendEmailUrl, completion: ((_ location: SendEmailResponse?) -> Void)? = nil) {
        var attachmentID = ""
        if attachmentIDs.count > 1 {
            for id in attachmentIDs {
                if attachmentID.isEmpty {
                    attachmentID = id.fromBase64() ?? ""
                } else {
                    attachmentID = "\(attachmentID)::\(id.fromBase64() ?? "")"
                }
            }
            attachmentID = attachmentID.toBase64()
        } else if  attachmentIDs.count == 1 {
            attachmentID = attachmentIDs[0]
        }
        emailSendRequest?.attachmentId = attachmentID == emptyString ? nil: attachmentID
        guard let sendEmailRequest = emailSendRequest else {
            return
        }
        let endPoint = EndPoint(baseUrl: .email, methodName: endpoint, method: .post, encoder: JSONParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: sendEmailRequest, res: SendEmailResponse.self) { result in
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

struct UploadProgress {
    var progress: Float?
    let index: Int?
    let image: UIImage?
    var hasUploaded = false
}

struct UploadStatus {
    var hasUploaded: Bool
    var index: Int?
}
