//
//  ServiceManager.swift
//  RCRC
//
//  Created by Ganesh Shinde on 07/08/20.
//

import Foundation
import Alamofire
import UIKit

enum NetworkError: Error {
    case connectivity
    case invalidData
    case invalidURL
    case invalidToken
    case caseIgnore
    case notLoggedIn
}

class ServiceManager {
    static let sharedInstance = ServiceManager()
    private init() {}
    var profileModel: ProfileModel?
    var infoContentModelEng: FAQModel?
    var infoContentModelArabic: FAQModel?
    var infoGalleryModel: InfoGalleryModel?
    var images: [UIImage]?
    var routeModelArabic: RouteModel?
    var routeModelEng: RouteModel?
    var routeModelTitleArabic: RouteModel?
    var routeModelTitleEng: RouteModel?
    var pdfScaleFactor: CGFloat = 0.0
   // var busStopsModel: BusStopModel?
    var stopsItemData: [StopsItem]?
    var stopListItemData: [StopsItem]?
    var StopItemModel: StopsItem?
    
    // MARK: - Reqeust/Response handler for GET/POST method

    func withRequest<T: Decodable, U: Encodable>(endPoint: EndPoint, params: U?, res: T.Type, uploadProgress: ((Double?) -> Void)? = nil, completion: @escaping (Result<T, Error>) -> Void) {

        // MARK: - Check if Device is connected to Internet before sending Request
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            guard let param = params else {return}
            var requestManager: Session
            requestManager = SSLRestConfig.manager
            var headers = endPoint.baseUrl.headers
            headers?.add(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")

            let request = requestManager.request(
                requestURL,
                method: endPoint.method,
                parameters: param, encoder: endPoint.encoder, headers: headers).validate()
            if let uploadProgress = uploadProgress {
                request.uploadProgress { (progress) in
                    uploadProgress(progress.fractionCompleted)
                }
            }
            request.responseDecodable(of: res) { response in
                
                // Pretty Print
                if let data = response.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: response.response?.url?.absoluteString))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(response.error == nil ? "Success" : "Failed with error: " + response.error.debugDescription)
                      ---------------------------------------------------------------------------------
                      """)
                switch response.result {
                case let .success(result):
                    completion(.success(result))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Download image from the server

    func downloadImage(url: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        AF.request(url).responseImage { response in
            switch response.result {
            case let .success(image):
                completionHandler(.success(image))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func downloadImage(url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        var requestManager: Session
        requestManager = SSLRestConfig.manager
        requestManager.request(url).responseImage { response in
            switch response.result {
            case let .success(image):
                completionHandler(.success(image))
            case let .failure(error):
                completionHandler(.failure(error))
            }
        }
    }

    func withRequest<T: Decodable, U: Encodable>(endPoint: EndPoint, parameters: U, resultData: T.Type, completion: @escaping (Result<(T?, HTTPURLResponse), NetworkError>) -> Void) {
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            let requestManager: Session = SSLRestConfig.manager
            
            var headers = endPoint.baseUrl.headers
            headers?.add(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
            let request = requestManager.request(requestURL,
                                                 method: endPoint.method,
                                                 parameters: parameters, encoder: endPoint.encoder, headers: headers).validate()
            request.response { result in
                
                request.responseString { Data in
                    print("Success----->", Data)
                }
                // Pretty Print
                if let data = result.data {
                    print("Resultttttt", result)
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: result.response?.url?.absoluteString))
                      Headers:      | \(String(describing: endPoint.baseUrl.headers))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(result.error == nil ? "Success" : "Failed with error: " + result.error.debugDescription)
                      Parameters:   | \(parameters)
                      ---------------------------------------------------------------------------------
                      """)
                
                if result.response?.statusCode == 401 {
                    completion(.failure(.invalidToken))
                } else if let data = result.data,
                   let response = result.response,
                   let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success((decodedData, response)))
                } else if result.data == nil,
                          let response = result.response {
                    completion(.success((.none, response)))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }

    func withRequestDecodedResult<T: Decodable, U: Encodable>(endPoint: EndPoint, parameters: U, resultData: T.Type, completion: @escaping (Result<T?, NetworkError>) -> Void) {
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            let requestManager: Session = SSLRestConfig.manager
            
            var headers = endPoint.baseUrl.headers
            headers?.add(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
            let request = requestManager.request(requestURL,
                                                 method: endPoint.method,
                                                 parameters: parameters, encoder: endPoint.encoder, headers: headers).validate()
            request.response { result in
                
                request.responseString { Data in
                    print("Success----->", Data)
                }
                // Pretty Print
                if let data = result.data {
                    print("Resultttttt", result)
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: result.response?.url?.absoluteString))
                      Headers:      | \(String(describing: endPoint.baseUrl.headers))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(result.error == nil ? "Success" : "Failed with error: " + result.error.debugDescription)
                      Parameters:   | \(parameters)
                      ---------------------------------------------------------------------------------
                      """)
                
                if result.response?.statusCode == 401 {
                    completion(.failure(.invalidToken))
                } else if let data = result.data,
                   //let response = result.response,
                   let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                    completion(.success(decodedData))
                } else if result.data == nil {
                    completion(.failure((.invalidData)))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
    
    func withRequest<T: Decodable, U: Encodable>(endPoint: EndPoint, parameters: U, headers: HTTPHeaders? = nil, resultData: T.Type, completion: @escaping (Result<T, NetworkError>) -> Void) {
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            let requestManager: Session = SSLRestConfig.manager
            
            let request = requestManager.request(requestURL,
                                                 method: endPoint.method,
                                                 parameters: parameters, encoder: endPoint.encoder, headers: headers)
            request.responseDecodable(of: resultData) { result in
                if let data = result.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: result.response?.url?.absoluteString))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(result.error == nil ? "Success" : "Failed with error: " + result.error.debugDescription)
                      ---------------------------------------------------------------------------------
                      """)
                print(result.response?.url?.absoluteString as Any)
                print(result)
                switch result.result {
                case let .success(result):
                    completion(.success(result))
                case .failure:
                    completion(.failure(.invalidData))
                }
            }
        }
    //}
    }
    
    func withRequest<U: Encodable>(endPoint: EndPoint, parameters: U, completion: @escaping (Result<HTTPURLResponse, NetworkError>) -> Void) {
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            let requestManager: Session = SSLRestConfig.manager
            var headers = endPoint.baseUrl.headers
            headers?.add(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
            let request = requestManager.request(requestURL,
                                                 method: endPoint.method,
                                                 parameters: parameters, encoder: endPoint.encoder, headers: headers)
            request.response { result in
                
                // Pretty Print
                if let data = result.data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: result.response?.url?.absoluteString))
                      Headers:      | \(String(describing: endPoint.baseUrl.headers))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(result.error == nil ? "Success" : "Failed with error: " + result.error.debugDescription)
                      Parameters:   | \(parameters)
                      ---------------------------------------------------------------------------------
                      """)
                if result.response?.statusCode == 401 {
                    completion(.failure(.invalidToken))
                } else if let response = result.response, response.statusCode == 200 {
                    completion(.success(response))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
    
    func fetchWso2Token(completion: @escaping(_ success:Bool) -> Void) {
        let endPoint = EndPoint(baseUrl: .wso2Token, methodName: URLs.token, method: .post, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = Wso2TokenRequest()
        self.withRequest(endPoint: endPoint, parameters: parameters, resultData: Wso2TokenResponse.self) { result in
            switch result {
            case let .success((data, _)):
                if let rsponse = data, let accesstoken = rsponse.accessToken {
                    UserTokenService.saveWsoToken("Bearer " + accesstoken)
                    print("-----------------------------------------\n", "Bearer " + accesstoken)
                    completion(true)
                } else {
                    // handle failure
                    completion(false)
                }

            case .failure(_):
                print("")
            }
        }
    }
    
    func withRequestJSONEncoding<T: Decodable>(endPoint: EndPoint, parameters: [String : Any], resultData: T.Type, completion: @escaping (Result<(T?, HTTPURLResponse), NetworkError>) -> Void) {
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            /*if let viewController: UIWindow = (UIApplication.shared.delegate?.window)! {
                let offlineViewController = OfflineViewController.instantiate(appStoryboard: .main)
                offlineViewController.modalPresentationStyle = .fullScreen
                viewController.rootViewController?.present(offlineViewController, animated: true, completion: nil)
            }*/
            Utilities.Connectivity.showToast(Constants.youAreOffline.localized)
            return
        } else {
            let requestURL = endPoint.baseUrl.rawValue + endPoint.methodName
            let requestManager: Session = SSLRestConfig.manager
            
            var headers = endPoint.baseUrl.headers
            headers?.add(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
            let request = requestManager.request(requestURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            
            
            
            request.responseString { Data in
                print("Success----->", Data)
            }
            
            request.response { result in
                
                // Pretty Print
                if let data = result.data {
                    print("Resultttttt", result)
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                }
                
                let startTime = Date().millisecondsSince1970
                let endTime = Date().millisecondsSince1970
                print("""
                      --------------------------- Network Request Completed ---------------------------
                      Endpoint:     | \(String(describing: result.response?.url?.absoluteString))
                      Headers:      | \(String(describing: endPoint.baseUrl.headers))
                      Start Time:   | \(startTime)
                      End Time:     | \(endTime)
                      Time Taken:   | \(endTime - startTime)ms
                      Result:       | \(result.error == nil ? "Success" : "Failed with error: " + result.error.debugDescription)
                      Parameters:   | \(parameters)
                      ---------------------------------------------------------------------------------
                      """)
                
                if result.response?.statusCode == 401 {
                    completion(.failure(.invalidToken))
                } else if let data = result.data,
                   let response = result.response,
                   let decodedData = try? JSONDecoder().decode(T.self, from: data) {
                    if result.response?.statusCode == 200 {
                        completion(.success((decodedData, response)))
                    } else {
                        completion(.failure(.invalidData))
                    }
                } else if result.data == nil,
                          let response = result.response {
                    completion(.success((.none, response)))
                } else {
                    completion(.failure(.invalidData))
                }
            }
        }
    }
}
