//
//  URLs.swift
//  RCRC
//
//  Created by Errol on 22/10/20.
//

import Foundation

enum URLs {
    static let googleApiUrl = "https://maps.googleapis.com/maps/api/"
    //
    
    // Global Network
//    static let baseUrl = "https://192.168.59.11:8080"
    
    // Cisco VPN Staging Network
    
#if STAGING
        static let baseUrl = "https://sitgw.riyadhbus.sa/"
        static let busContentURL = "https://sit.riyadhbus.sa"
#else
    static let baseUrl = "https://www.riyadhbus.sa/"
    static let busContentURL = "https://www.riyadhbus.sa"
#endif
        
    // Cisco VPN
    //    static let baseUrl = "https://10.200.24.181:8080"
    
    // Updated Finder URL
    static let stopFinderUrl = "planningstop-sf/1.0.0/stop"
    // Old Finder URL
    //static let stopFinderUrl = "planning-sf/1.0.0/stop"
    
    static let tripRequestUrl = "planning-trip/1.0.0/trip"
    static let faqURL = "http://37.224.41.117/" //"http://37.224.41.117:8080/"
    
    
    static let routeEndPoints = "planning-trip/1.0.0/trip"
    
    // New Weather API End Point
    static let weatherEndpointUrl = "miweather-api/1.0.0/miweather"
    // OLD Weather API End Point
    //static let weatherEndpointUrl = "utilities-weather/1.0.0/weather"
    
    static let googleGeocode = "geocode/json?"
    static let distanceMatrix = "distancematrix/json?"
    static let latestNewsStartEndpoint = "news/"
    static let newsEndEndpoint = "/0/10"
    
    static let loginEndpoint = "account-login/1.0.0/login"
    static let uploadFileUrl = "sendemailattachment/1.0.0/fileupload"
    static let sendEmailUrl = "sendemailattachment/1.0.0/sendemail"
    static let emailBaseURL = "https://37.224.41.117:8243/"
    static let logoutEndpoint = "account-logout/1.0.0/logout"
    static let liferay = "https://37.224.41.117:8080/"
    static let events = "api/jsonws/events.eventdetail/get-status/start/-1/end/-1"
    static let nearbyPlacesOfInterest = "place/nearbysearch/json?"
    static let eventsSearch = "api/jsonws/events.eventdetail/get-status-name/eventnames/"
    static let fareMediaIntegrated = "account-userbarcode/1.0.0/products"
    static let fareMediaBarcode = "account-barcode/1.0.0/eticket"
    static let fareMediaTransactionStart = "payment-transaction/1.0.0/transaction-start"
    static let fareMediaTransactionUpdate = "payment-transaction/1.0.0/transaction-status"
    static let fareMediaPaymentMethods = "payment-methodType/1.0.0/paymentmethods"
    static let forgotPasswordEndPoint = "recover-password/1.0.0/customers/password"
    static let signUpEndPoint = "customer-create/1.0.1/customers"
    static let documentTypes = "get-documenttypes/1.0.0/document-types"
    static let getCustomerDetail = "getcustomer/1.0.0/customers"
    static let editCustomerDetail = "customer-update/1.0.0/customers"
    static let travelPreferences = "mp-travelpreferences/1.0.0/travel-preferences"
    static let token = "token"
    static let recentCommunication = "serivce-request/1.0.0/service-requests"
    static let deleteAccount = "customerDelete/1.0.0/customers"
    static let allPaymentMethod = "get-allpaymentmethods/1.0.0/customers/payment-methods"
    static let addPaymentMethodHTMLSession = "gethtmlsession/1.0.0/customers/payment-methods/htmls"
    static let addNewPaymentMethod = "newpayment/1.0.0/customers/payment-methods"
    static let activateProduct = "activate-product/1.0.0/media-types"
    static let phoneCode = "phonecode/1.0.0/"
    static let appInfoURL = "http://itunes.apple.com/lookup?bundleId="
    static let busStopPoints = "planning-coord/1.0.0/coordinate"
    static let purchaseHistory = "purchase-history/1.0.0/media-types"
    static let barcodeStack = "account-barcode/1.0.0/etickets"
    static let getTransactionByID = "payment-transaction/1.0.0/transactionbyid"
    static let liveBusStatus = "tracking/1.0.0/veloc"
    static let stopSearchList = "stoplist/1.0.0/stopcoords"
    static let stopRoute = "veloc/1.0.0"
    static let nextBusInfo = "plan-dm/1.0.0/XML_DM_REQUEST"
    //static let busStopPointsOnMap = "stoplist/1.0.0/busstationcoords"
    static let listCord = "stoplist/1.0.0/listcoords"
    
#if DEBUG
    static let faqEndPoints = "o/headless-delivery/v1.0/content-structures/99343/structured-contents"
    static let contactEndpoint = "o/headless-delivery/v1.0/content-structures/99012/structured-contents"
    static let busNetworkContent = "o/headless-delivery/v1.0/content-structures/216194/structured-contents"
    static let busTimeTableContent = "o/headless-delivery/v1.0/content-structures/219697/structured-contents"
    static let kaptInfoHeaderImageContent = "o/headless-delivery/v1.0/content-structures/44772/structured-contents"
    static let kaptInfoHeaderContent = "o/headless-delivery/v1.0/content-structures/35763/structured-contents"
    static let kaptInfoContent = "o/headless-delivery/v1.0/content-structures/44841/structured-contents"
    static let kaptInfoURLContent = "o/headless-delivery/v1.0/content-structures/44931/structured-contents"
    static let termsAndConditions = "o/headless-delivery/v1.0/content-structures/141514/structured-contents"
    static let aboutBusInfoContent = "o/headless-delivery/v1.0/content-structures/156799/structured-contents"
    static let aboutBusInfoGallery = "o/headless-delivery/v1.0/content-structures/156830/structured-contents"
    static let privacyPolicy = "o/headless-delivery/v1.0/content-structures/159426/structured-contents"
    static let routesHeader = "o/headless-delivery/v1.0/content-structures/66492/structured-contents"
    static let homeMap = "o/headless-delivery/v1.0/content-structures/192627/structured-contents"
    
#elseif STAGING
    static let faqEndPoints = "o/headless-delivery/v1.0/content-structures/131986/structured-contents"
    static let contactEndpoint = "o/headless-delivery/v1.0/content-structures/131982/structured-contents"
    static let busNetworkContent = "o/headless-delivery/v1.0/content-structures/90169/structured-contents"
    static let busTimeTableContent = "/o/headless-delivery/v1.0/content-structures/171001/structured-contents?page=0"//"o/headless-delivery/v1.0/content-structures/171001/structured-contents"
    static let kaptInfoHeaderImageContent = "o/headless-delivery/v1.0/content-structures/59001/structured-contents"
    static let kaptInfoHeaderContent = "o/headless-delivery/v1.0/content-structures/58985/structured-contents"
    static let kaptInfoContent = "o/headless-delivery/v1.0/content-structures/59005/structured-contents"
    static let kaptInfoURLContent = "o/headless-delivery/v1.0/content-structures/59009/structured-contents"
    static let termsAndConditions = "o/headless-delivery/v1.0/content-structures/141514/structured-contents"
    static let aboutBusInfoContent = "o/headless-delivery/v1.0/content-structures/156799/structured-contents"
    static let aboutBusInfoGallery = "o/headless-delivery/v1.0/content-structures/156830/structured-contents"
    static let privacyPolicy = "o/headless-delivery/v1.0/content-structures/159426/structured-contents"
    static let routesHeader = "o/headless-delivery/v1.0/content-structures/195475/structured-contents"
    static let homeMap = "o/headless-delivery/v1.0/content-structures/192627/structured-contents"
    
#else
    static let faqEndPoints = "o/headless-delivery/v1.0/content-structures/36528/structured-contents"
    static let contactEndpoint = "o/headless-delivery/v1.0/content-structures/36524/structured-contents"
    static let busNetworkContent = "o/headless-delivery/v1.0/content-structures/90169/structured-contents"
    static let busTimeTableContent = "o/headless-delivery/v1.0/content-structures/61943/structured-contents?page=0"
    static let kaptInfoHeaderImageContent = "o/headless-delivery/v1.0/content-structures/59001/structured-contents"
    static let kaptInfoHeaderContent = "o/headless-delivery/v1.0/content-structures/58985/structured-contents"
    static let kaptInfoContent = "o/headless-delivery/v1.0/content-structures/59005/structured-contents"
    static let kaptInfoURLContent = "o/headless-delivery/v1.0/content-structures/59009/structured-contents"
    static let termsAndConditions = "o/headless-delivery/v1.0/content-structures/57223/structured-contents"
    static let aboutBusInfoContent = "o/headless-delivery/v1.0/content-structures/57247/structured-contents"
    static let aboutBusInfoGallery = "o/headless-delivery/v1.0/content-structures/156830/structured-contents"
    static let privacyPolicy = "o/headless-delivery/v1.0/content-structures/57251/structured-contents"
    static let routesHeader = "o/headless-delivery/v1.0/content-structures/66492/structured-contents"
    static let homeMap = "o/headless-delivery/v1.0/content-structures/88932/structured-contents"
#endif
    
    enum ApplicationSharing {

        static let instagramApp = "instagram://user?username="
        static let instagramWeb = "https://instagram.com/"
        static let facebookApp = "fb://profile/"
        static let facebookWeb = "https://facebook.com/"
        static let twitterApp = "twitter://user?screen_name="
        static let twitterWeb = "https://twitter.com/"
        static let youtubeApp = "youtube://www.youtube.com/user/"
        static let youtubeWeb = "https://www.youtube.com/user/"
        static let riyadhbus = "https://www.riyadhbus.sa/"
    }
}

struct BaseApiTypeKeys {
    static let journeyPlannerBaseKey         = "JourneyPlannerBaseURL"
    static let frequentlyAskedQuestionsKey   = "FrequentlyAskedQuestionsURL"
    static let latestNewsKey = "LatestNewsURL"
    static let contactKey = "ContactURL"
    static let loginKey = "LoginURL"
    static let liferay = "Liferay"
    static let wso2TokenUrl = "Wso2TokenUrl"
}
