//
//  NetworkServices.swift
//  AlamofireDemo
//
//  Created by Sagar Tilekar on 20/05/20.
//  Copyright © 2020 Sagar Tilekar. All rights reserved.
//

import UIKit
import Alamofire

 // MARK: - Network Service class
class NetworkServices<T: Codable>: NSObject {

    // This response is used when we get response in Array of Dictionaries format
    typealias ResponseHandler = (_ userResponse: [T]?, Error?) -> Void

    // This response is used when we get response in Dictionary format
    typealias DictionaryResponseHandler = (_ userResponse: T?, Error?) -> Void

    var baseUrl = "https://riyadh.mentz.net/rda/"

    var url: String {
        return baseUrl
    }

    override init() {}

    // MARK: - GET list without parameters
    func getGenericList(urlById: String, completionHandler:@escaping ResponseHandler) {
        let completeUrl = baseUrl + urlById

        AF.request(completeUrl).response { response in
            if let data = response.data {
                do {
                    let userResponse = try JSONDecoder().decode([T].self, from: data)
                    completionHandler(userResponse, nil)

                } catch let err {
                    print(err.localizedDescription)
                    completionHandler(nil, err)

                }
            }
        }

    }

    // MARK: - GET list with parameters
    func getGenericDataUsingParameter(urlById: String, parameters: [String: Any], completionHandler:@escaping (ResponseHandler)) {
        let completeUrl = baseUrl + urlById
        AF.request(completeUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).response { response in

            guard let data = response.data else {
                completionHandler(nil, response.error)
                return
            }

            do {
             let userResponse = try JSONDecoder().decode([T].self, from: data)
                completionHandler(userResponse, nil)
            } catch let error {
                completionHandler(nil, error)
            }

        }
    }

    // MARK: - GET dictionary with parameters
    func getGenericDictionaryDataUsingParameter(urlById: String, parameters: [String: Any], completionHandler:@escaping (DictionaryResponseHandler)) {
        let completeUrl = URLs.faqURL + urlById
        let headers: HTTPHeaders = [
            .authorization(username: "test", password: "test"),
            .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
        ]

        AF.request(completeUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).response { response in

            guard let data = response.data else {
                completionHandler(nil, response.error)
                return
            }
            do {
             let userResponse = try JSONDecoder().decode(T.self, from: data)
                completionHandler(userResponse, nil)
            } catch let error {
                completionHandler(nil, error)
            }

        }
    }

    // MARK: - POST request
    func postRequest(urlById: String, parameters: [String: Any], completionHandler:@escaping (ResponseHandler)) {
        let completeUrl = baseUrl + urlById
        let headers: HTTPHeaders =  ["Content-type": "application/json; charset=UTF-8"]
        AF.request(completeUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).response { (response) in
            guard let data = response.data else {
                           completionHandler(nil, response.error)
                           return
                       }
                       do {
                        let userResponse = try JSONDecoder().decode([T].self, from: data)
                           completionHandler(userResponse, nil)
                       } catch let error {
                           completionHandler(nil, error)
                       }
        }
    }

    // MARK: - PUT request
    func putRequest(urlById: String, parameters: [String: Any], completionHandler:@escaping (ResponseHandler)) {
        let completeUrl = baseUrl + urlById
        let headers: HTTPHeaders =  ["Content-type": "application/json; charset=UTF-8"]
        AF.request(completeUrl, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).response { (response) in
            guard let data = response.data else {
                completionHandler(nil, response.error)
                return
            }
            do {
                let userResponse = try JSONDecoder().decode([T].self, from: data)
                completionHandler(userResponse, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }

    }

    // MARK: - DELETE request
    func deleteRequest(urlById: String, parameters: [String: Any], completionHandler:@escaping (ResponseHandler)) {
        let completeUrl = baseUrl + urlById
        AF.request(completeUrl, method: .delete, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseJSON { (response) in
            guard let data = response.data else {
                completionHandler(nil, response.error)
                return
            }
            do {
                let userResponse = try JSONDecoder().decode([T].self, from: data)
                completionHandler(userResponse, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
    }

    // MARK: - GET Request with HTTP Headers
    func getGenericDictionaryDataUsingParameter(urlById: String, parameters: [String: Any], headers: HTTPHeaders?, completionHandler:@escaping (DictionaryResponseHandler)) {
        let completeUrl = baseUrl + urlById
        guard let headers = headers else {
            return
        }
        AF.request(completeUrl, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers, interceptor: nil, requestModifier: nil).response { response in

            guard let data = response.data else {
                completionHandler(nil, response.error)
                return
            }
            do {
             let userResponse = try JSONDecoder().decode(T.self, from: data)
                completionHandler(userResponse, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
    }
}

class NetworkImage: NSObject {

    static let shared = NetworkImage()

    func fetchImage(_ url: URL, completion: @escaping ((UIImage?) -> Void)) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        session.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                if let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func fetchPDF(_ url: URL, completion: @escaping ((Data?) -> Void)) {
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        session.dataTask(with: url) { (data, _, error) in
            if let data = data, error == nil {
                completion(data)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
}

extension NetworkImage: URLSessionDelegate {

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}
