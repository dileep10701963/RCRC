//
//  KAPRPTInfoViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 20/12/22.
//

import Foundation
import UIKit
import Alamofire


class KAPRPTInfoViewModel: NSObject {
    
    static let shared = KAPRPTInfoViewModel()
    let mediaCache = NSCache<AnyObject, AnyObject>()
    
    var kaptHeaderImageResult: KAPTInfoModel? = nil
    var kaptInfoResult: KAPTInfoModel? = nil
    var kaptHeaderContent: KAPTInfoModel? = nil
    var kaptURLResult: KPTUrlModel? = nil
    
    func getKAPTInfoHeaderImageAPI(endpoint: String = URLs.kaptInfoHeaderImageContent, completionHandler : @escaping (KAPTInfoModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .kaptInfoHeaderImage, methodName: URLs.kaptInfoHeaderImageContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: KAPTInfoModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.kaptHeaderImageResult = data
                completionHandler(self.kaptHeaderImageResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.kaptHeaderImageResult,errr)
                
            }
        }
    }
    
    func getKAPTInfoHeaderContentAPI(endpoint: String = URLs.kaptInfoHeaderContent, completionHandler : @escaping (KAPTInfoModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .kaptInfoHeader, methodName: URLs.kaptInfoHeaderContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: KAPTInfoModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.kaptHeaderContent = data
                completionHandler(self.kaptHeaderContent, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.kaptHeaderContent,errr)
                
            }
        }
    }
    
    func getKAPTInfoContentAPI(endpoint: String = URLs.kaptInfoContent, completionHandler : @escaping (KAPTInfoModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .kaptInfoContent, methodName: URLs.kaptInfoContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: KAPTInfoModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.kaptInfoResult = data
                completionHandler(self.kaptInfoResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.kaptInfoResult,errr)
                
            }
        }
    }
    
    func getKAPTInfoURLContentAPI(endpoint: String = URLs.kaptInfoURLContent, completionHandler : @escaping (KPTUrlModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .kaptInfoURLContent, methodName: URLs.kaptInfoURLContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: KPTUrlModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.kaptURLResult = data
                completionHandler(self.kaptURLResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.kaptURLResult,errr)
                
            }
        }
    }
    
    private func getKAPTContentCellModels() -> [KAPTContentField] {
        
        var contentField: [KAPTContentField] = []
        if let items = self.kaptInfoResult?.items, items.count > 0, let contentFields = items[0].contentFields, contentFields.count > 0 {
            contentField = contentFields.filter({$0.nestedContentFields?.count ?? 0 > 0})
        }
        return contentField
    }
    
    private func getKAPTContent() -> [(title: String, description: String)] {
        
        var KAPTContents: [(String, String)] = []
        let models = getKAPTContentCellModels()
        for model in models {
            let title = model.nestedContentFields?[0].contentFieldValue?.data ?? emptyString
            let description = model.nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.data ?? emptyString
            KAPTContents.append((title, description))
        }
        return KAPTContents
    }
        
    private func getMediaContent(indexPath: IndexPath, completionHandler: @escaping(_ imageContent: UIImage?,_ urlString: String?) -> Void){
        
        let contentPath = kaptHeaderImageResult?.items?[0].contentFields?[0].contentFieldValue?.image?.contentURL ?? ""
        let contentURL = URLs.baseUrl + contentPath
        if let url = URL(string: contentURL) as NSURL? {
            if let image = mediaCache.object(forKey: contentURL as AnyObject) {
                completionHandler(image as? UIImage, contentURL)
            } else {
                NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                    if let image = image {
                        self?.mediaCache.setObject(image, forKey: contentURL as AnyObject)
                        completionHandler(image, url.absoluteString)
                    } else {
                        completionHandler(nil, url.absoluteString)
                    }
                }
            }
        } else {
            completionHandler(nil, contentURL)
        }
    }
    
    private func getMediaContentForKAPTInfo(indexPath: IndexPath, completionHandler: @escaping(_ imageContent: UIImage?,_ urlString: String?, _ imageIndex: Int) -> Void){
        
        if self.getKAPTContentCellModels().count < 1 {
            completionHandler(nil, nil, indexPath.row)
            return
        }
        
        let contentPath = self.getKAPTContentCellModels()[indexPath.row].contentFieldValue?.image?.contentURL ?? ""
        let contentURL = URLs.baseUrl + contentPath
        if let url = URL(string: contentURL) as NSURL? {
            if let image = mediaCache.object(forKey: contentURL as AnyObject) {
                completionHandler(image as? UIImage, contentURL, indexPath.row)
            } else {
                NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                    if let image = image {
                        self?.mediaCache.setObject(image, forKey: contentURL as AnyObject)
                        completionHandler(image, url.absoluteString, indexPath.row)
                    } else {
                        completionHandler(nil, url.absoluteString, indexPath.row)
                    }
                }
            }
        } else {
            completionHandler(nil, contentURL, indexPath.row)
        }
    }
    
    private func getHeaderContentForImageScreen() -> (title: String, textAboveImage: String, textBelowHeaderCell: String) {
        var contentFields: KAPTContentField?
        
        var imageTextContent: String = emptyString
        var title: String = emptyString
        var textBelowHeaderCell: String = emptyString
        
        if let items = self.kaptHeaderContent?.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 {
            contentFields = contentField.first(where: {$0.inputControl ?? emptyString == "textarea"})
            title = contentField[0].contentFieldValue?.data ?? emptyString
            
            let infoTextContentFields = contentField.filter({$0.inputControl ?? emptyString == "textarea"})
            if infoTextContentFields.count > 1 {
                textBelowHeaderCell = infoTextContentFields[1].contentFieldValue?.data ?? emptyString
            }
        }
        
        if let contentFields = contentFields {
            imageTextContent = contentFields.contentFieldValue?.data ?? emptyString
        }
        return (title, imageTextContent, textBelowHeaderCell)
    }
    
    private func getStackContentLabel() -> [String] {
        var stackLabels: [String] = []
        if let items = self.kaptInfoResult?.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 {
            stackLabels.append(contentField[1].contentFieldValue?.data ?? emptyString)
        }
        return stackLabels
    }
    
    private func getButtonLinksContent() -> [(title: String, redirectionLink: String)] {
        var stackButtonContent: [(String, String)] = []
        
        if let items = self.kaptURLResult?.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 {
            for contentField in contentField {
                let title = contentField.contentFieldValue?.data ?? emptyString
                var url: String = emptyString
                if contentField.nestedContentFields?.count ?? 0 > 0 {
                    url = contentField.nestedContentFields?[0].contentFieldValue?.data ?? emptyString
                }
                stackButtonContent.append((title, url))
            }
        }
        
        return stackButtonContent
    }
    

}

extension KAPRPTInfoViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            var headerCount = kaptHeaderImageResult?.items?.count ?? 0
            if headerCount == 0 {
                headerCount = kaptHeaderContent?.items?.count ?? 0
            }
            
            if self.getHeaderContentForImageScreen().textBelowHeaderCell != emptyString {
                headerCount = headerCount + 1
            }
            return headerCount
        case 1:
            return self.getKAPTContentCellModels().count
        case 2:
            return self.kaptURLResult?.items?.count ?? 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return cellSetupForKAPTInfoImage(tableView: tableView, indexPath: indexPath)
            case 1:
                return cellSetupTextCell(tableView: tableView, indexPath: indexPath)
            default:
                return UITableViewCell()
            }
        case 1:
            return cellSetupForKAPTContentCell(tableView: tableView, indexPath: indexPath)
        case 2:
            return cellSetupTextCellForRedirectionLink(tableView: tableView, indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return self.kaptHeaderImageResult?.items?.count ?? 0 > 0 || self.kaptHeaderContent?.items?.count ?? 0 > 0 ? UITableView.automaticDimension: CGFloat.leastNormalMagnitude
        case 1:
            return self.kaptInfoResult?.items?.count ?? 0 > 0 ? UITableView.automaticDimension: CGFloat.leastNormalMagnitude
        case 2:
            return self.kaptURLResult?.items?.count ?? 0 > 0 ? UITableView.automaticDimension: CGFloat.leastNormalMagnitude
        default:
            return CGFloat.leastNormalMagnitude
        }
    }
    
    private func cellSetupForKAPTInfoImage(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell: KAPTInfoHeaderCell = tableView.dequeue(cellForRowAt: indexPath)
        let textContent = self.getHeaderContentForImageScreen()
        cell.configureHeaderTextContent(descText: textContent.textAboveImage, titleText: textContent.title)
        self.getMediaContent(indexPath: indexPath) { [weak self] imageContent, urlString in
            DispatchQueue.main.async {
                if self != nil {
                    tableView.beginUpdates()
                    cell.configure(kaptHeaderImage: imageContent, headerText: textContent.textAboveImage, headerTitle: textContent.title)
                    tableView.endUpdates()
                }
            }
        }
        return cell
    }
    
    private func cellSetupForKAPTContentCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell: KAPTInfoContentCell = tableView.dequeue(cellForRowAt: indexPath)
        if self.getKAPTContent().count > 0 {
            cell.configure(title: getKAPTContent()[indexPath.row].title, description: getKAPTContent()[indexPath.row].description)
        }
        cell.tag = indexPath.row
        self.getMediaContentForKAPTInfo(indexPath: indexPath) { [weak self] imageContent, urlString, imageIndex in
            DispatchQueue.main.async {
                if self != nil {
                    if cell.tag == imageIndex {
                        cell.configureImageContent(contentImage: imageContent)
                    }
                }
            }
        }
        return cell
    }
    
    private func cellSetupTextCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell: KAPTInfoTextCell = tableView.dequeue(cellForRowAt: indexPath)
        let headerContent = self.getHeaderContentForImageScreen()
        cell.configure(cellTextContent: headerContent.textBelowHeaderCell, keyPoints: self.getStackContentLabel())
        return cell
    }
    
    private func cellSetupTextCellForRedirectionLink(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell: KAPTInfoTextCell = tableView.dequeue(cellForRowAt: indexPath)
        let buttonContents = self.getButtonLinksContent()
        cell.configureContentForButtonLink(buttonContents: buttonContents, tag: indexPath.row)
        return cell
    }
    
}
