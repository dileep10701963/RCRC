//
//  RecentCommunicationViewModel.swift
//  RCRC
//
//  Created by Saheba Juneja on 16/09/22.
//

import Foundation
import UIKit
import Alamofire

class RecentCommunicationViewModel: NSObject {
    static let shared = RecentCommunicationViewModel()
    var recentCommunication = RecentCommunicationResponseModel(items: nil)
    // Api call
    func fetchRecentCommunication(endpoint: String = URLs.recentCommunication, completionHandler : @escaping (RecentCommunicationResponseModel, NetworkError) -> Void) {
        let endPoint = EndPoint(baseUrl: .serviceRequest, methodName: URLs.recentCommunication, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: RecentCommunicationResponseModel.self) { result in
            switch result {
            case .success((let data, _)):
                self.recentCommunication = RecentCommunicationResponseModel(items: data?.items)
                completionHandler(self.recentCommunication, .caseIgnore)
            case .failure(let errr):
                print("Error-->", errr)
                completionHandler(self.recentCommunication,errr)

            }
        }
    }
}

extension RecentCommunicationViewModel: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return recentCommunication.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecentCommunicationCell = tableView.dequeue(cellForRowAt: indexPath)
        cell.recentCommunicationItemModel = recentCommunication.items?[indexPath.section] ?? Item()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
