//
//  RestConfig.swift
//  RCRC
//
//  Created by Ganesh Shinde on 07/08/20.
//

import Foundation
import Alamofire

class RestConfig: NSObject {
    public static var manager: Session {
        let manager = AF
        manager.session.configuration.timeoutIntervalForRequest = 120
        return manager
    }
}

class SSLRestConfig: NSObject {

    public static let manager: Session = {
        //print("cert publicKeys: \(Bundle.main.af.publicKeys)")
        let manager = ServerTrustManager(evaluators: ["37.224.41.117": DisabledTrustEvaluator(), "192.168.59.11": DisabledTrustEvaluator(), "192.168.59.12": DisabledTrustEvaluator(), "riyadh.mentz.net": DisabledTrustEvaluator(), "46.44.112.210": DisabledTrustEvaluator(), "sitgw.riyadhbus.sa": PublicKeysTrustEvaluator(), "sitidam.riyadhbus.sa": PublicKeysTrustEvaluator(), "sit.riyadhbus.sa":PublicKeysTrustEvaluator(), "maps.googleapis.com": DisabledTrustEvaluator(), "gw.riyadhbus.sa": PublicKeysTrustEvaluator(), "idam.riyadhbus.sa": PublicKeysTrustEvaluator(), "www.riyadhbus.sa": PublicKeysTrustEvaluator()])
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 50
        let interceptor = NetworkInterceptor()
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return Session(configuration: configuration, interceptor: interceptor, serverTrustManager: manager, cachedResponseHandler: ResponseCacher(behavior: .doNotCache))
    }()

    private static let certificates = [
        "37.224.41.117":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "192.168.59.11":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "192.168.59.12":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "riyadh.mentz.net":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "46.44.112.210":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: true,
                performDefaultValidation: true,
                validateHost: true),
        "sitgw.riyadhbus.sa":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "sitidam.riyadhbus.sa":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        "sit.riyadhbus.sa":
            PinnedCertificatesTrustEvaluator(
                acceptSelfSignedCertificates: false,
                performDefaultValidation: false,
                validateHost: false),
        
    ]

    //    private static let certificates = [
    //       "192.168.59.12":
    //         PinnedCertificatesTrustEvaluator(certificates: [Certificates.certificate],
    //                                          acceptSelfSignedCertificates: false,
    //                                          performDefaultValidation: false,
    //                                          validateHost: false)
    //     ]

    private static let serverTrustPolicy = ServerTrustManager(
        allHostsMustBeEvaluated: false,
        evaluators: certificates
    )
}

// SSL pinning Certificate

struct Certificates {

    static let certificate: SecCertificate = Certificates.certificate(filename: "certificateFileName")

    private static func certificate(filename: String) -> SecCertificate {

        var secCertificate: SecCertificate?
        if let filePath = Bundle.main.path(forResource: filename, ofType: "fileExtension") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                secCertificate = SecCertificateCreateWithData(nil, data as CFData)
            } catch {
                print(error.localizedDescription)
            }
        }
        guard let certificate = secCertificate else {
            fatalError()
        }
        return certificate
    }
}

struct EndPoint {
    let baseUrl: API_TYPE
    let methodName: String
    let method: HTTPMethod
    let encoder: ParameterEncoder
}

// There are 3 types of api in app. So API_TYPE enum binds api base url and headers with api type i.e journeyPlanner, liferay and google.

enum API_TYPE: String {
    case journeyPlanner
    case googleMap
    case frequentlyAskedQuestions
    case latestNews
    case contact
    case login
    case email
    case logout
    case liferay
    case forgotPassword
    case signUp
    case getProfile
    case editProfile
    case fetchTravelPreference
    case saveTravelPreference
    case wso2Token
    case serviceRequest
    case documentTypes
    case delete
    case allPaymentMethod
    case addPaymentMethodHTMLSession
    case addNewPaymentMethod
    case busNetworkContent
    case eventList
    case eventSearch
    case activateProduct
    case kaptInfoHeaderImage
    case kaptInfoHeader
    case kaptInfoContent
    case kaptInfoURLContent
    case termAndConditions
    case aboutBusInfo
    case privacyPolicy
    case busNetworkHeader
    case homeMap
    case appInfo
    case busStopOnMap
    case travelHistory
    case purchaseHistory
    case applePay
    case liveBusStatus
    case stopSearchList
    case stopRoutes
    case nextBusInfo
    
    var rawValue: String {
        switch self {
        case .frequentlyAskedQuestions:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? "")
        case .journeyPlanner:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? "")
        case .latestNews:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.latestNewsKey] as? String) ?? "")
        case .googleMap:
            return URLs.googleApiUrl
        case .contact:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.contactKey] as? String) ?? emptyString)
        case .login:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .email:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .logout:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? "")
        case .liferay:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.liferay] as? String) ?? emptyString)
        case .forgotPassword:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .signUp:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .getProfile:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .editProfile:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .fetchTravelPreference:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .saveTravelPreference:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .wso2Token:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.wso2TokenUrl] as? String) ?? emptyString)
        case .serviceRequest:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .documentTypes:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .delete:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .allPaymentMethod:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .addPaymentMethodHTMLSession:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .addNewPaymentMethod:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .busNetworkContent:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.contactKey] as? String) ?? emptyString)
        case .eventList:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .eventSearch:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .activateProduct:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .kaptInfoHeader, .kaptInfoContent, .kaptInfoHeaderImage, .kaptInfoURLContent:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.contactKey] as? String) ?? emptyString)
        case .termAndConditions:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .aboutBusInfo:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .privacyPolicy:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .busNetworkHeader:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .homeMap:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.frequentlyAskedQuestionsKey] as? String) ?? emptyString)
        case .appInfo:
            return emptyString
        case .busStopOnMap:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .travelHistory:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .purchaseHistory:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .applePay:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .liveBusStatus:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .stopSearchList:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .stopRoutes:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        case .nextBusInfo:
            return ((Bundle.main.infoDictionary?[BaseApiTypeKeys.journeyPlannerBaseKey] as? String) ?? emptyString)
        }
    }
    
    var headers: HTTPHeaders? {
        
        var lifeRayDetail: (String, String) = ("","")
        
#if STAGING
        lifeRayDetail = ("test", "test")
#else
        lifeRayDetail = ("liferayadmin", "_RcRc@dmin")
#endif
        
        switch self {
        case .email:
            return ["Authorization": UserTokenService.retrieveWsoToken(),
                    "Content-Type": "application/json"]
        case .frequentlyAskedQuestions:
            return [
                .acceptLanguage(currentLanguage == .arabic ? "ar": "en"),
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .journeyPlanner:
            return ["Authorization": UserTokenService.retrieveWsoToken()]
        case .latestNews:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json")
            ]
        case .googleMap:
            return nil
        case .contact:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(currentLanguage.rawValue)
            ]
        case .login:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
                "Content-Type": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage
            ]
        case .liferay:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(currentLanguage.rawValue)
            ]
        case .logout:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Content-Type": "application/json"
            ]
        case .forgotPassword:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Content-Type": "application/json"
            ]
        case .signUp:
            return [
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Content-Type": "application/json",
                "Authorization": UserTokenService.retrieveWsoToken(),
            ]
        case .getProfile, .editProfile:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Content-Type": "application/json"
            ]
        case .fetchTravelPreference, .saveTravelPreference:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
            ]
        case .wso2Token:
            return [
                "Authorization": Keys.wso2Authorisation,
                "Content-Type": "application/x-www-form-urlencoded"
            ]
        case .serviceRequest:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .documentTypes:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .delete:
            return [
                "Authorization": UserTokenService.retrieveWsoToken(),
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Content-Type": "application/json"
            ]
        case .allPaymentMethod:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .addPaymentMethodHTMLSession:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .addNewPaymentMethod:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .busNetworkContent:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .eventList:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .eventSearch:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .activateProduct:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .kaptInfoHeaderImage, .kaptInfoContent, .kaptInfoHeader, .kaptInfoURLContent:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .termAndConditions:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"),
                .acceptLanguage(currentLanguage == .arabic ? "ar-SA": "en-US")
            ]
        case .aboutBusInfo:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"),
                .acceptLanguage(currentLanguage == .arabic ? "ar": "en")
            ]
        case .privacyPolicy:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"),
                .acceptLanguage(currentLanguage == .arabic ? "ar": "en")
            ]
        case .busNetworkHeader:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
                ]
        case .homeMap:
            return [
                .authorization(username: lifeRayDetail.0, password: lifeRayDetail.1),
                .accept("application/json"), .acceptLanguage(LanguageService.currentAppLanguage())
            ]
        case .appInfo:
            return nil
        case .busStopOnMap:
            return ["Authorization": UserTokenService.retrieveWsoToken()]
        case .travelHistory:
            return [
                "accept": "application/json",
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                "Authorization": UserTokenService.retrieveWsoToken()
            ]
        case .purchaseHistory:
                    return [
                        "accept": "application/json",
                        "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                        "X-AFC-Auth": UserTokenService.retrieve() ?? "",
                        "Authorization": UserTokenService.retrieveWsoToken()
                    ]
        case .applePay:
            return [
                "X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                "Authorization": UserTokenService.retrieveWsoToken(),
            ]
        case .liveBusStatus:
            return ["Authorization": UserTokenService.retrieveWsoToken()]
        case .stopSearchList:
            return ["accept": "application/json",
                    //"X-AFC-Lang": AFCAPIHeaders.afcLanguage,
                    "Authorization": UserTokenService.retrieveWsoToken()]
        case .stopRoutes:
            return ["Authorization": UserTokenService.retrieveWsoToken()]
        case .nextBusInfo:
            return ["accept": "application/json",
                    "Authorization": UserTokenService.retrieveWsoToken()]
        }
    }
}


class NetworkInterceptor: RequestInterceptor {
    var isRefreshing: Bool = false
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var oldRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString {
            // update header only for those api failures which contains WSO Authorisation header
            if isURLStringContainsWSOAuthorizationHeader(urlString: urlString) {
                oldRequest.setValue(UserTokenService.retrieveWsoToken(), forHTTPHeaderField: "Authorization")
                completion(.success(oldRequest))
            } else {
                completion(.success(urlRequest))
            }
        } else {
            completion(.success(urlRequest))
        }
        print("Inside Adapt", urlRequest)
        print("Headers  --> ", urlRequest.headers)
        
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        print("Inside retry", request)

        if let statusCode = response?.statusCode {
            if statusCode == 401, request.retryCount < 1 {
                // Call refresh token api
                ServiceManager.sharedInstance.fetchWso2Token { success in
                    if success {
                        // header update
                        print("--------------------\n Token Refreshed and APi re called \n-----------------------")
                        completion(.retry)
                    } else {
                        completion(.doNotRetry)
                    }
                }
            } else {
                completion(.doNotRetry)
            }
        } else {
            return completion(.doNotRetry)
        }
    }
    
    func isURLStringContainsWSOAuthorizationHeader(urlString: String)-> Bool {
        if urlString.contains(URLs.weatherEndpointUrl) ||
            urlString.contains(URLs.travelPreferences) ||
            urlString.contains(URLs.getCustomerDetail) ||
            urlString.contains(URLs.forgotPasswordEndPoint) ||
            urlString.contains(URLs.logoutEndpoint) ||
            urlString.contains(URLs.loginEndpoint) ||
            urlString.contains(URLs.routeEndPoints) ||
            urlString.contains(URLs.stopFinderUrl) ||
            urlString.contains(URLs.fareMediaIntegrated) ||
            urlString.contains(URLs.fareMediaBarcode) ||
            urlString.contains(URLs.fareMediaTransactionStart) ||
            urlString.contains(URLs.fareMediaTransactionUpdate) ||
            urlString.contains(URLs.fareMediaPaymentMethods) {
            return true
        }
        return false
    }
}
