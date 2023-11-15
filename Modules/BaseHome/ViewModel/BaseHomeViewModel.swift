//
//  BaseHomeViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 23/03/23.
//

import Foundation
import Alamofire

class BaseHomeViewModel: NSObject {
    
    static let shared = BaseHomeViewModel()
    
    var baseHomeResult: BaseHomeModel? = nil
    
    func getHomeMap(completionHandler : @escaping (BaseHomeModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .homeMap, methodName: URLs.homeMap, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: BaseHomeModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.baseHomeResult = data
                completionHandler(self.baseHomeResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.baseHomeResult,errr)
                
            }
        }
    }
    
    func getMapPDFURL() -> String? {
        var pdfURL: String? = nil
        if let baseHomeResult = baseHomeResult {
            if let items = baseHomeResult.items, items.count > 0 , let contentFieldValue = items[0].contentFields, contentFieldValue.count > 0 {
                let contentURL = contentFieldValue[0].contentFieldValue?.document?.contentURL
                if let contentURL = contentURL, contentURL != "" {
                    pdfURL = "\(URLs.busContentURL)\(contentURL)"
                }
            }
        }
        return pdfURL
    }
    
    func savePDFViewAndReturnPath() {
        
        let fileManager = FileManager.default
        let documentURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
        if let documentURL = documentURL {
            if let sourcePath = Bundle.main.path(forResource: "Home_Map", ofType: "pdf"), let fullDestPath = NSURL(fileURLWithPath: documentURL).appendingPathComponent("Home_Map.pdf") {
                if fileManager.fileExists(atPath: fullDestPath.path) {
                    print("File is exist in \(fullDestPath.path)")
                } else {
                    do {
                        try fileManager.copyItem(atPath: sourcePath, toPath: fullDestPath.path)
                    } catch {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        }
        
    }
    
    func openPdfFile() -> (fileManagerURL: URL?, bundleURL: URL?){
        
        let documentDir = FileManager.SearchPathDirectory.documentDirectory
        let userDir    = FileManager.SearchPathDomainMask.userDomainMask
        let paths      = NSSearchPathForDirectoriesInDomains(documentDir, userDir, true)
        
        var fileManagerURL: URL? = nil
        var bundleURL: URL? = nil
        
        if let dirPath   = paths.first
        {
            let pdfURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Home_Map.pdf")
            do {
                let data = try? Data(contentsOf: pdfURL)
                if data != nil {
                    fileManagerURL = pdfURL
                } else {
                    bundleURL = Bundle.main.url(forResource: "Home_Map", withExtension: "pdf")
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        
        return (fileManagerURL, bundleURL)
        
    }
    
    func saveDownloadedPDFFile(pdfData: Data){
        
        let documentDir = FileManager.SearchPathDirectory.documentDirectory
        let userDir    = FileManager.SearchPathDomainMask.userDomainMask
        let paths      = NSSearchPathForDirectoriesInDomains(documentDir, userDir, true)
        
        if let dirPath   = paths.first
        {
            let pdfURL = URL(fileURLWithPath: dirPath).appendingPathComponent("Home_Map.pdf")
            do {
                try? pdfData.write(to: pdfURL, options: .atomic)
                print(pdfURL)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
     func getMapData(completionHandler: @escaping(_ data: Data?) -> Void) {
         print("Data is calling")
         self.getHomeMap { [weak self] baseHomeModel, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if baseHomeModel != nil {
                    if let urlIs = URL(string: self.getMapPDFURL() ?? emptyString) {
                        AF.download(urlIs).responseData { response in
                            if let data = response.value {
                                completionHandler(data)
                            }
                        }
                    }
                }
            }
        }
    }
}
