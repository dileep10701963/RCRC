//
//  EventsLoader.swift
//  RCRC
//
//  Created by Errol on 24/06/21.
//

import Foundation
import Alamofire

final class EventsLoader {
    let service: ServiceManager

    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }

    func fetchEvents(completion: @escaping (Result<[Event], Error>) -> Void) {
        let endPoint = EndPoint(baseUrl: .eventList, methodName: URLs.events, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        service.withRequest(endPoint: endPoint, params: parameters, res: EventRoot.self) { result in
            completion(EventsResultHandler.handleNetworkResult(result))
        }
    }

    func searchEvents(keyword: String, completion: @escaping (Result<[Event], Error>) -> Void) {
        guard let urlString = (URLs.eventsSearch + keyword).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            let error = NSError(domain: "Invalid URL", code: 404, userInfo: .none)
            completion(.failure(error))
            return
        }
        let endpoint = EndPoint(baseUrl: .eventList, methodName: urlString, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()
        service.withRequest(endPoint: endpoint, params: parameters, res: EventRoot.self) { result in
            completion(EventsResultHandler.handleNetworkResult(result))
        }
    }
}

struct EventsResultHandler {
    static func handleNetworkResult(_ result: Result<EventRoot, Error>) -> Result<[Event], Error> {
        switch result {
        case let .success(eventsData):
            return .success(eventsData.events)
        case let .failure(error):
            return .failure(error)
        }
    }
}
