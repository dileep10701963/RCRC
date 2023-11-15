enum Keys {
    static let appleLanguageKey = "AppleLanguages"
    static var apiKey = ""
    
    static var authToken = ""
    
    // Updated Google API Key
    static var googleApiKey: String {
        return UserTokenService.retrieveGoogleApiKey() ?? ""
    }
    
    // Development
    static var wso2Authorisation: String {
#if DEBUG
        print("DEBUG")
        return UserTokenService.retrieveBasicAuthKeyDebugMode() ?? ""
#elseif STAGING
        print("STAGING")
        return UserTokenService.retrieveBasicAuthKeyStagingMode() ?? ""
#else
        print("Production")
        return UserTokenService.retrieveBasicAuthKeyProductionMode() ?? ""
#endif
    }
}
