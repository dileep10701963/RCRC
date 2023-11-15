//
//  FareTicketingViewModal.swift
//  RCRC
//
//  Created by Aashish Singh on 15/11/22.
//


import Foundation
import UIKit
import Alamofire

class FareTicketingViewModal: NSObject {
    
    static let shared = FareTicketingViewModal()
    var selectedIndexPath: IndexPath?
    
    var fareTicketResult: FairTicketModel? = nil
    
    func getFareTicketingContent(endpoint: String = URLs.busNetworkContent, completionHandler : @escaping (FairTicketModel?, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .busNetworkContent, methodName: URLs.busNetworkContent, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: FairTicketModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.fareTicketResult = data
                completionHandler(self.fareTicketResult, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.fareTicketResult,errr)
                
            }
        }
    }
    
    private func getFareTicketContent(indexPath: IndexPath) -> (title: String, description: NSMutableAttributedString?, documents: [String?]?) {
        
        guard let fareTicketResult = fareTicketResult else {
            return ("", NSMutableAttributedString(string: ""), [""])
        }
        
        let title = fareTicketResult.items?[1].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].contentFieldValue?.data ?? ""
        let description = fareTicketResult.items?[1].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].contentFieldValue?.data?.htmlToAttributedString(font: Fonts.CodecRegular.sixteen, color: Colors.rptHtmlGrey)
        let nestedContentFields = fareTicketResult.items?[1].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields
        let documents = nestedContentFields?.map{$0.contentFieldValue?.document?.contentURL}.compactMap({$0})
        return (title, description, documents)
    }
    
}

extension FareTicketingViewModal: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let result = self.fareTicketResult, result.items?.count ?? 0 > 0 {
            return self.fareTicketResult?.items?[1].contentFields?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fareTicketResult?.items?[1].contentFields?[section].nestedContentFields?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BusTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        cell.configure(title: getFareTicketContent(indexPath: indexPath).title, selectedIndexPath: selectedIndexPath, currentIndexPath: indexPath, description: getFareTicketContent(indexPath: indexPath).description)
        if indexPath.row == (tableView.numberOfRows(inSection: indexPath.section) - 1) {
            cell.answerLabelBottomConstraint.constant = 0
        }
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
        headerView?.headerLabel.text = self.fareTicketResult?.items?[1].contentFields?[section].contentFieldValue?.data ?? ""
        return headerView
    }
}
