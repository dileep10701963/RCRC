//
//  BusNetworkViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 21/10/22.
//

import Foundation
import UIKit
import Alamofire

var busImageCache = NSCache<BusImageCache, UIImage>()

class BusImageCache: Hashable {

    let id = UUID()
    let url: NSURL

    init(url: NSURL) {
        self.url = url
    }

    static func == (lhs: BusImageCache, rhs: BusImageCache) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

protocol BusNetworkViewModelDelegate: AnyObject {
    func viewTimeTableClicked(cell: UITableViewCell)
}

class BusNetworkViewModel: NSObject {
    
    static let shared = BusNetworkViewModel()
    let mediaCache = NSCache<AnyObject, AnyObject>()
    var selectedIndexPath: IndexPath?
    weak var delegate: BusNetworkViewModelDelegate?
    
    var busResult: BusModel? = nil
    
    func getBusNetworkContent(endpoint: String = URLs.busNetworkContent, completionHandler : @escaping (BusModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .busNetworkContent, methodName: URLs.busNetworkContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: BusModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.busResult = data
                completionHandler(self.busResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.busResult,errr)
                
            }
        }
    }
    
    private func getAboutBusNetworkContent(indexPath: IndexPath) -> (title: String, description: NSMutableAttributedString?, documents: [String?]?) {
        
        guard let busResult = busResult else {
            return ("", NSMutableAttributedString(string: ""), [""])
        }
        
        let title = busResult.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].contentFieldValue?.data ?? ""
        let description = busResult.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].contentFieldValue?.data?.htmlToAttributedString(font: Fonts.CodecRegular.sixteen, color: Colors.rptHtmlGrey)
        let nestedContentFields = busResult.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields
        let documents = nestedContentFields?.map{$0.contentFieldValue?.document?.contentURL}.compactMap({$0})
        
        return (title, description, documents)
    }
    
    private func isOtherFacilitiesCell(indexPath: IndexPath) -> Bool {
        let value = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].contentFieldValue?.data ?? ""
        return value == emptyString ? false: true
    }
    
    private func setOtherFacilitiesCellValue(indexPath: IndexPath) -> (title: String, description: NSMutableAttributedString?) {
        let title = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].contentFieldValue?.data ?? ""
        let desciption = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].contentFieldValue?.data?.htmlToAttributedString(font: Fonts.CodecRegular.sixteen, color: Colors.rptHtmlGrey)
        return (title, desciption)
    }
    
    private func setBusContent(indexPath: IndexPath) -> String {
        return busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].contentFieldValue?.data ?? ""
    }
    
    private func getMediaContent(indexPath: IndexPath, completionHandler: @escaping(_ imageContent: UIImage?,_ urlString: String?, _ isImageContent: Bool) -> Void){
        
        let fileExtension = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.fileExtension ?? ""

        let contentPath = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.contentURL ?? ""
        let contentURL = URLs.baseUrl + contentPath
        if let url = URL(string: contentURL) as NSURL? {
            
            switch fileExtension.lowercased() == "pdf" {
            case true:
                if let image = mediaCache.object(forKey: contentURL as AnyObject) {
                    completionHandler(image as? UIImage, contentURL, false)
                } else {
                    NetworkImage.shared.fetchPDF((url as URL)) { [weak self] (pdfData) in
                        if let pdfData = pdfData, let image = self?.drawPDFfromPDFData(data: pdfData) {
                            self?.mediaCache.setObject(image, forKey: contentURL as AnyObject)
                            self?.busResult?.pdfData = pdfData
                            completionHandler(image, url.absoluteString, false)
                        } else {
                            completionHandler(nil, url.absoluteString, false)
                        }
                    }
                }
            case false:
                if let image = mediaCache.object(forKey: contentURL as AnyObject) {
                    completionHandler(image as? UIImage, contentURL, true)
                } else {
                    NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                        if let image = image {
                            self?.mediaCache.setObject(image, forKey: contentURL as AnyObject)
                            completionHandler(image, url.absoluteString, true)
                        } else {
                            completionHandler(nil, url.absoluteString, true)
                        }
                    }
                }
            }
            
        } else {
            completionHandler(nil, contentURL, true)
        }
    }
    
    func getPDFData(url: URL, completionHandler: @escaping(_ data: Data?) -> Void) {
        NetworkImage.shared.fetchPDF((url as URL)) { [weak self] (pdfData) in
            if let pdfData = pdfData {
                completionHandler(pdfData)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    private func drawPDFfromPDFData(data: Data) -> UIImage? {
        
        let pdfData = data as CFData
        guard let provider: CGDataProvider = CGDataProvider(data: pdfData) else { return nil }
        guard let document:CGPDFDocument = CGPDFDocument(provider) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.drawPDFPage(page)
        }
        return img
    }
}

extension BusNetworkViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let result = self.busResult, result.items?.count ?? 0 > 0 {
            return self.busResult?.items?[0].contentFields?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busResult?.items?[0].contentFields?[section].nestedContentFields?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.busResult?.items?[0].contentFields?[indexPath.section].contentFieldValue?.data ?? "" == Constants.riyadhBus {
        case true:
            
            let documents = getAboutBusNetworkContent(indexPath: indexPath).documents
            if let documents = documents, !documents.isEmpty {
                
                let cell: BusDetailsCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configure(title: getAboutBusNetworkContent(indexPath: indexPath).title, selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath, description: getAboutBusNetworkContent(indexPath: indexPath).description, documents: documents)
                cell.busImages = documents
                cell.busCollectView.reloadData()
                cell.cellTapped = { [weak self] clickedCell in
                    guard let indexPath = tableView.indexPath(for: clickedCell) else { return }
                    if self?.selectedIndexPath == indexPath {
                        self?.selectedIndexPath = IndexPath(row: -1, section: -1)
                    } else {
                        self?.selectedIndexPath = indexPath
                    }
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
                return cell
            } else {
                
                let cell: BusTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configure(title: getAboutBusNetworkContent(indexPath: indexPath).title, selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath, description: getAboutBusNetworkContent(indexPath: indexPath).description)
                cell.cellTapped = { [weak self] clickedCell in
                    guard let indexPath = tableView.indexPath(for: clickedCell) else { return }
                    if self?.selectedIndexPath == indexPath {
                        self?.selectedIndexPath = IndexPath(row: -1, section: -1)
                    } else {
                        self?.selectedIndexPath = indexPath
                    }
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
                return cell
            }
            
        case false:
            
            switch isOtherFacilitiesCell(indexPath: indexPath) {
            case true:
                
                let cell: BusTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
                let otherFacilitiesCellValue = setOtherFacilitiesCellValue(indexPath: indexPath)
                cell.configure(title: otherFacilitiesCellValue.title, selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath, description: otherFacilitiesCellValue.description)
                cell.cellTapped = { [weak self] clickedCell in
                    guard let indexPath = tableView.indexPath(for: clickedCell) else { return }
                    if self?.selectedIndexPath == indexPath {
                        self?.selectedIndexPath = IndexPath(row: -1, section: -1)
                    } else {
                        self?.selectedIndexPath = indexPath
                    }
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
                return cell
                
            case false:
                
                let fileExtension = busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.fileExtension ?? ""
                
                let cell: BusViewTimeTableCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configure(title: setBusContent(indexPath: indexPath), selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath, isPDF: fileExtension.lowercased() == "pdf")
                cell.timeTableTapped = delegate?.viewTimeTableClicked
                cell.cellTapped = { [weak self] clickedCell in
                    guard let indexPath = tableView.indexPath(for: clickedCell) else { return }
                    if self?.selectedIndexPath == indexPath {
                        self?.selectedIndexPath = IndexPath(row: -1, section: -1)
                    } else {
                        self?.selectedIndexPath = indexPath
                    }
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                    tableView.reloadData()
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPath == indexPath {
            selectedIndexPath = IndexPath(row: -1, section: -1)
        } else {
            selectedIndexPath = indexPath
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String.className(BusNetworkHeaderView.self)) as? BusNetworkHeaderView
        headerView?.headerLabel.text = self.busResult?.items?[0].contentFields?[section].contentFieldValue?.data ?? ""
        return headerView
    }
}
