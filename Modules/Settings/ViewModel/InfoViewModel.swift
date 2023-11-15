//
//  InfoViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 20/02/23.
//

import Foundation
import Alamofire
import UIKit
class InfoViewModel: NSObject {

    var infoResult: Observable<FAQModel?, Error?> = Observable(nil, nil)
    var infoGalleryResult: Observable<InfoGalleryModel?, Error?> = Observable(nil, nil)
    private let service: ServiceManager
    
    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }

    func getInfoContentAPI(completionHandler : (() -> Void)? = nil) {
        let endPoint = EndPoint(baseUrl: .aboutBusInfo, methodName: URLs.aboutBusInfoContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParam: Encodable {}
        let param = DefaultParam()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: param, res: FAQModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(faq):
                self.infoResult.value = faq
            case let .failure(error):
                self.infoResult.error = error
            }
            if let completionHandler = completionHandler { completionHandler() }
        }
    }
    
    func getInfoContentGallery(completionHandler : (() -> Void)? = nil) {
        let endPoint = EndPoint(baseUrl: .aboutBusInfo, methodName: URLs.aboutBusInfoGallery, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParam: Encodable {}
        let param = DefaultParam()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: param, res: InfoGalleryModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(faq):
                self.infoGalleryResult.value = faq
            case let .failure(error):
                self.infoGalleryResult.error = error
            }
            if let completionHandler = completionHandler { completionHandler() }
        }
    }
    
    func getInfoTitle() -> String? {
        if let model = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic, let items = model.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0, let nestTedContentField = contentFields[0].nestedContentFields, nestTedContentField.count > 0 {
            let title = contentFields[0].contentFieldValue?.data
            return title
        } else {
            return nil
        }
    }
    
    func getInfoContent() -> String? {
        if let model = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic, let items = model.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0, let nestTedContentField = contentFields[0].nestedContentFields, nestTedContentField.count > 0 {
            let content = nestTedContentField[0].contentFieldValue?.data
            return content
        } else {
            return nil
        }
    }
    
    func numberOfRows() -> Int {
        if let model = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic, let items = model.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0, let nestTedContentField = contentFields[0].nestedContentFields, nestTedContentField.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func numberOfImagesURLForGallery() -> [String] {
        if let model = ServiceManager.sharedInstance.infoGalleryModel, let items = model.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0, let nestTedContentField = contentFields[0].nestedContentFields, nestTedContentField.count > 0 {
            let imagesURL = nestTedContentField.compactMap({$0.contentFieldValue?.image?.contentURL})
            return imagesURL
        } else {
            return []
        }
    }
    
    func setImageArray() {
        if let model = ServiceManager.sharedInstance.infoGalleryModel, let items = model.items, items.count > 0 , let contentFields = items[0].contentFields, contentFields.count > 0, let nestTedContentField = contentFields[0].nestedContentFields, nestTedContentField.count > 0 {
            let imagesURL = nestTedContentField.compactMap({$0.contentFieldValue?.image?.contentURL})
            var arrayOfImages: [UIImage] = []
            let imageGroup = DispatchGroup()
            for i in 0 ..< imagesURL.count {
                imageGroup.enter()
                let urlString = URLs.busContentURL + (imagesURL[i])
                if let url = URL(string: urlString ) as URL? {
                    ServiceManager.sharedInstance.downloadImage (url: url ) { [weak self] result in
                        if case let .success(newImage) = result {
                            if arrayOfImages.count > 0 {
                                if arrayOfImages.contains(newImage) == false {
                                    arrayOfImages.append(newImage)
                                }
                            } else {
                                arrayOfImages = [newImage]
                                
                            }
                        }
                        imageGroup.leave()
                    }
                }
                
            }
            
            imageGroup.notify(queue: .main) {
                ServiceManager.sharedInstance.images = arrayOfImages
            }
        }
    }
    
    
}



