//
//  GlobalConstants.swift
//  RCRC
//
//  Created by Errol on 22/10/20.
//

import Foundation
import UIKit
import GoogleMaps

let emptyString = ""
let zero = "0"
var apiDataType: ApiDataType = .realtime
let cancel = "Cancel"
let ok = "OK"
let proceed = "Proceed"
let done = "Done"
let tryAgain = "Try Again"
let space = " "
let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
var loginRootView: LoginRootView = .appGuide
let isConnected = Utilities.Connectivity.isConnectedToInternet() ? true : false
var isOffline:Bool {
    !Utilities.Connectivity.isConnectedToInternet()
}
enum ApiDataType {
    case stub
    case realtime
}

enum Languages: String {
    case english = "en"
    case arabic = "ar"
    case urdu = "ur"
}

enum TimeZones: Int {
    case GMT = 0
    case AST = 10800
    case IST = 19800
    
}

enum Keychain {
    static let kUserKey = "UserName"
    static let kPasswordKey = "Password"
}

public enum DialogType: Int {
    case alert
    case progressBar
}

enum ReusableViews {
    static let routeSelectionView = "RouteSelectionView"
    static let proceedButtonView = "ProceedButtonView"
}

// MARK: - Global Constants
enum Constants {
    static let sideMenu = "sideMenu"
    static let propertyListName = "PropertyList.plist"
    static let doubleZeroString = "00"
    static let didLaunchBeforeKey = "didLaunchBefore"
    static var isAppOpen: Bool = false
    static let qrCodeCIFilter = "CIQRCodeGenerator"
    static let qrCodeFilterKey = "inputMessage"
    static let biometricsKey = "biometrics"
    static let error = "Error"
    static let loginUserDefaultKey = "login"
    static let profileImageKey = "profileImage"
    static let borderWidth = 1.0
    static let cornerRadius = 10.0
    static let guidelinesKey = "guidelinesKey"
    static let isTicketVisited = "ticketVisited"
    static let mapAPICalledKey = "mapAPICalled"
    static let appVersionCheckedKey = "appVersionChecked"
    static let emailConfirmEmailShouldSame = "Email & Confirm email should be same."
    static let passwordConfirmPasswordShouldSame = "Password & Confirm password should be same."
    static let confirmMobileShouldSame = "Mobile number & Confirm Mobile number should be same."
}

// MARK: - Alert Pop Up Constants
extension Constants {
    static let noLocationAlertTitle = "Location Services Disabled"
    static let noLocationAlertMessage = "Please enable location Services"
    static let goToSettings = "Settings"
    static let noResultsAlertTitle = "No Results Found"
    static let noResultsAlertMessage = "Please search using another keyword"
    static let noRoutesAlertTitle = "No Routes Available"
    static let noRoutesAlertMessage = "No route available for the selected Source and Destination. Please try again!"
    static let validationFailed = "Validation Failed"
    static let dateOfIncidenceMissing = "Please enter date of Incidence"
    static let issueMissing = "Please select issue"
    static let nameMissing = "Please enter name"
    static let emailMissing = "Please enter the email address"
    static let messageMissing = "Please enter your message"
    static let contactMissing = "Please enter contact numer"
    static let categoryMissing = "Please select Category"
    static let placeofIncidenceMissing = "Please enter place of Incidence"
    static let emailValidationError = "Please enter the valid email address"
    static let noInternetAlertMessage = "Please check your Internet Connection and Try Again"
    static let noInternetAlertTitle = "No Internet"
    static let serverErrorAlertMessage = "Technical error, please try again later"
    static let serverErrorAlertTitle = "Technical Error"
    static let cameraErrorAlertMessage = "Oops! Problem with your camera"
    static let cameraErrorAlertTitle = "Warning"
    static let contactValidationError = "Please enter the valid contact number"
    static let saveLocationAlertTitle = "Add Favorite Location"
    static let saveLocAlertTitle = "location?"
    static let saveLocationAlertMessage = ", will be saved as your"
    static let saveLocAlertMessage = " location."
    static let removeHomeLocation = " will be removed from saved home locations list."
    static let removeWorkLocation = " will be removed from saved Work locations list."
    static let removeSchoolLocation = "will be removed from saved School locations list."
    static let removeFavouriteLocation = " will be removed from saved Favorite places list."
    static let sessionExpiredTitle = "Session Expired"
    static let deleteRecentSearchTitle = "Delete Recent Search"
    static let deleteRecentSearchMessage = "Please confirm deleting recent search?"
    static let deleteAllRecentSearchTitle = "Delete All Recent Search"
    static let deleteAllRecentSearchMessage = "Please confirm deleting all recent search?"
}

// MARK: - Plan a Trip Constants
extension Constants {
    static let planATrip = "Plan a Trip"
    static let selectYourDestination = "Arrival Station"
    static let dashboardBottomViewCollapsed: CGFloat = 0.0
    static let dashboardBottomViewExpanded: CGFloat = 200.0
    static let routeSelectionViewCollapsed: CGFloat = -292
    static let routeSelectionViewExpanded: CGFloat = 0.0
    static let selectSourceOnMap = " Select Source On Map "
    static let selectDestinationOnMap = " Select Destination On Map "
    static let noFavorites = "No Favorites"
    static let now = "Now"
    static let leave = "Leave"
    static let arrive = "Arrive"
    static let noRecentSearches = "No Recent Searches"
    static let selectLocationExpandedHeight: CGFloat = 85
    static let selectLocationCollapsedHeight: CGFloat = 0
    static let enterYourLocation = "Enter Your Location"
    static let routeTitleSearch = "Search"
    static let routeTitleAvailableRoutes = "Available Routes"
    static let routeAvailable = "Routes Available"
    static let oneRouteAvailable = "Route Available"
    static let noFavoriteRouteAvailable = "No Favorite Routes Available"
    static let footPathTitle = "footpath"
    static let walkTitle = " Min walk"
    static let busTitle = "Bus"
    static let ModeTitle = "Mode"
    static let nextTravelModeNumber = "nextTravelModeNumber"
    static let minuteTitle = " Min "
    static let stopTitle = " stops"
    static let endWalkTitle = "endWalk"
    static let metroTitle = "Metro"
    static let trainTitle = "train"
    static let currencyTitle = " SAR"
    static let walkStringTitle = "walk-1"
    static let busYellowTitle = "busYellow"
    static let travelModeName = "travelModeName"
    static let transportationName = "transportationName"
    static let stopsCount = "stopsCount"
    static let legsCount = "legsCount"
    static let timeDuration = "timeDuration"
    static let destinationName = "destinationName"
    static let originName = "originName"
    static let travelCost = "travelCost"
    static let nextTravelModeName = "nextTravelModeName"
    static let ticketDescription = "ticketDescription"
    static let totalDuration = "TotalDuration"
    static let journeys = "journeys"
    static let info = "Info"
    static let notifications = "Notifications"
    static let noNotifications = "No Notifications"
    static let stop = "stop"
    static let coordinate = "coordinate"
    static let yourCurrentLocation = "Current Location"
    static let enterOrigin = "Departure Station"
    static var selectLocationOnMapTapped: Bool = false
    static let searchResultsTableHeaderHeight: CGFloat = 15.0
    static let distanceTolerance = 10.0
    static let sameSourceDestinationTitle = "Same Source and Destination"
    static let sameSourceDestinationMessage = "The stations are in the same locations, please select another departure or arrival station"//"Please select different departure and arrival stations"
    static let noDataAvailable = "No search results found. For further information, please contact 19933."//"Selected location is outside the current Riyadh bus network service"
    //static let noDataAvailable = "Bus service is not available on the selected route"
    //static let noDataAvailable = "No routes available for current selection. \n Kindly refine your location or change time"
    
    static let locationOutOfRiyadhCity = "Riyadh Bus service is only available within Riyadh City."
    static let locationOutOfRiyadhCityTitle = "Location is outside Riyadh city"
    static var mapViewZoomLevel: Float = 17
    static let locationWhenUnavailable: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)
    static let home = "My Home"
    static let work = "Work"
    static let favorites = "My Favorites"
    static let school = "School"
    static let nearbyStations = "Nearby Stations"
    static let events = "Events"
    static let bus = "bus"
    static let train = "train"
    static let walk = "walk"
    static let metro = "metro"
    static let mapRouteStrokeWidth = CGFloat(6.0)
    static let mapRouteStrokeLength = 10
    static let date = "Date"
    static let hour = "Hr. "
    static let minute = "Min. "
    static let arrival = "arr"
    static let departure = "dep"
    static let searchPreferencePickerHeight: CGFloat = 150
    static let minuteRoute = "Min"
    static let minutesRoute = "Mins"
    static let stopRoute = "Stops"
    static let minDrive = "Min Drive"
    static let noRecordsFound = "No records found"
    static let addPaymentMethod = "Payment Method"
    static let fareAndTicketing = "Fares and Ticketing"
    static let navBarWithPadding: CGFloat = 67
    
    static let whereto = "Select your destination"
    static let more = "More"
    static let showMoreHistory = "Show more history"
    
    static let leaveBy = "Leave By"
    static let arriveBy = "Arrive By"
    static let listSavedFavoritePlaces = "List of Saved Favorite Places"
    
    static let recentSearchDelete = "will be removed from recent search location list"
    static let clearAll = "Clear all"
    static let clearAllMessage = "All the recent search location will be removed."
    static let showOnMap = "Bus Tracker"//"Select Route"
    static let deleteFavLocationTitle = "Delete Favorite Location"
    static let deleteFavLocationMessage = "Please confirm deleting favorite location?"
    
    static let deleteFavRouteTitle = "Delete Favourite Route"
    static let deleteFavRouteMessage = "Please confirm deleting favourite route?"
    static let favoriteRouteErrorMessage = "You must select departure and arrival stations to save as favorite route"
    static let recentSearch = "Recent Search"
    static let whereFrom = "Where from?"
    static let saveLater = "Save for later"
    static let addFourote = "Add to favourites"
    static let busRoutesJP = "Bus routes"
    static let busRoutesSuggested = "Suggested for you"
    static let favouriteRoutes = "Favourites routes"
    static let changeStop = "Change stop"
    static let byATicektTitle = "Buy a ticket"
}

// MARK: - My Account Constants
extension Constants {
    static let myAccount = "My Account"
    static let fareMedia = "Fare Media"
    static let paymentMethods = "Payment Methods"
    static let correspondence = "Correspondence"
    static let favoritePlaces = "Favorite Places"
    static let favoriteRoutes = "Favorite Routes"
    static let deleteAccount = "Delete Account"
    static let logOut = "Log Out"
    static let recentCommunication = "Recent Communication"
    static let reportAnIncident = "Report an Incident"
    static let reportLostAndFound = "Report Lost & Found"
    static let deleteMyAccount = "Delete My Account"
    static let tickets = "Tickets"
    static let languageSettings = "Language Settings"
    static let applePay = "Apple Pay"
    static let dateTo = "Date To"
    static let dateFrom = "Date From"
    static let to = "To"
    static let from = "From"
    
    /// Fare Media
    static let gridCellIdentifier = "GridCollectionViewCell"
    static let mySmartCardtitle = "My Smart Card"
    static let cardOptiontitle = "Card Options"
    static let myAccountBalanceTitle = "My Account Balance"
    static let availableFareMedia = "Available Fare Media"
    static let cardBlockTitle = "Block My Card"
    static let cardUnBlockTitle = "UnBlock My Card"
    static let cardDeleteTitle = "Delete My Card"
    static let adultSinglePass = "1"
    static let familyPass = "1"
    static let tenTripPass = "10"
    static let twentyTripPass = "20"
    static let monthlyTripPass = "M"
    static let yearlyTripPass = "Y"
    static let adultSinglePassTitle = "Adult Single Pass"
    static let familyPassTitle = "Family Pass"
    static let tenTripPassTitle = "10 Trip Pass"
    static let twentyTripPassTitle = "20 Trip Pass"
    static let monthlyTripPassTitle = "Monthly Pass"
    static let yearlyTripPassTitle = "Yearly Pass"
    static let isBlockedTitle = "isBlocked"
    static let blockTitle = "isBlocked"
    static let cardUnblockTitle = "Card Unblocked Successful"
    static let cardUnblockDescriptionTitle = "The card has been unblocked successfully. You can start using the card and make payment for fare media."
    static let cardBlockDetailTitle = "Card Block Successful"
    static let cardBlockDescriptionTitle = "The card has been blocked successfully. You can start your trips using new fare media."
    static let cardDeleteText = "Account Deleted Successful"
    static let cardDeleteDescriptionTitle = "Your account has been delete permanently and you will be redirected to home screen. You can also tap on ‘Proceed’ button to continue."
    static let isDeleted = "isDeleted"
    static let creditcard = "creditcard"
    static let comments = "My New Card"
    static let dictionaryKeyPaymentMethodTypeId = "paymentMethodTypeId"

    /// Report An Incident
    static let incidentCategory = "Select Incident Category"
    static let incidentType = "Select Incident Type"
    static let incidentPlace = "Where did the incident happen?"
    static let incidentDate = "When did the incident happen?"
    static let incidentDescription = "Describe the incident"
    static let incidentAttachmentLabel = "Attach photos, videos of the incident"
    static let incidentPrivacyNotice = "By clicking on 'Report', you acknowledge having read our Privacy notice and consent to receive additional information."
    static let report = "Report"

    /// Report Lost & Found
    static let lostAnItem = "I have lost an Item"
    static let foundAnItem = "I have found an Item"
    static let lostAndFoundDescription = "Description of the lost/found item"
    static let lostAndFoundAttachmentLabel = "Attach photos, videos of the item"

    /// Delete Account
    static let deleteDescription = "Whether you have a question about features, or require If you are facing any issue, then kindly check our ‘FAQ’ section and still if you have any concern you can get in touch with us from ‘Contact us’ section.\n\nDeleting your account will permanently remove all your info, saved fare media, favorites and customization along with your user ID, that you cannot retrieve it back."
    static let deletionSuccess = "Account Deleted Successful"
    static let deletionSuccessDescription = "Your account has been delete permanently and you will be redirected to home screen. You can also tap on ‘Proceed’ button to continue."
    static let contactUs = "Contact us"
    static let deleteSorryMessage = "We are sorry that you are thinking to delete your account!"

    // Favourite route
    static let favouriteRouteDeleteMessage = "Are you really want to delete this location from favorite location list"
    static let origin = "Origin :"
    static let destination = "Destination :"
    static let deleteFavoriteRouteSuccess = "Favorite Route Deleted successfully"
    
    static let editProfile = "Edit Account"
}

// MARK: - Contact Constants
extension Constants {
    static let sendMessage = "Send Message"
    static let contact = "Contact"
    static let contactDescriptionTitle = "We'd love to hear from you!!"
    static let contactDescription = "Whether you have a question about features, or require assistance with all sales related inquiries or anything else, you can find a host of brilliant articles in our FAQ knowledge base. If you can't find what you're looking for, our team is ready to answer all your questions and point you in the right direction. Please feel free to send us an email or even give us a call."
    static let success = "success"
    static let done = "Done"
}

// MARK: - News Constants
extension Constants {
    static let news = "News"
    static let subscribe = "Subscribe"
    static let readMoreNews = "Read More News"
    static let moreNews = "More News"
    static let moreNewsAlertMessage = "Additional news items require opening of your web browser outside this app."
}

// MARK: - About KAPRPT Constants
extension Constants {
    static let aboutKaprpt = "About KAPT"
    static let faq = "FAQ"
    static let sendQuery = "Send Query"
    static let userQuery = "User Query"
    static let kaptInfo = "KAPT Information"
    static let facebook = "Facebook"
    static let twitter = "Twitter"
    static let instagram = "Instagram"
    static let youtube = "Youtube"
    static let clickSend = "By clicking on 'Send Message', you acknowledge having read our "
    static let receiveInfo = "and consent to receive additional information."
    static let privacyNotice = "privacy notice"
    static let query = "Query"
    static let typeYourMessage = "Type your message here"
    static let yourEmailAddress = "Your Email Address*"
    static let privacyNoticeMessage = "By clicking on 'Send Message', you acknowledge having read our Privacy and Data Protection Policy and consent to receive additional information."
    static let purchaseHistory = "Purchase History"
    static let travelHistory = "Travel History"
}

// MARK: - Send Query Constants
extension Constants {
    static let sendQueryMessage = "Hi, there. If you have any questions, we are here to help you."
    static let selectTopic = "Select a Related Topic";
}

// MARK: - Settings Constants
extension Constants {
    static let settings = "Settings"
    static let buildDate = "Release Date: "
    static let buildVersion = "Version"
    static let launchTutorial = "Launch Tutorial"
}

// MARK: - Miscellaneous Constants
extension Constants {
    static let shimmerLayerName = "shimmerEffect"
    static let shimmerKeyPath = "locations"
    static let shimmerKey = "shimmerEffectAnimation"
    static let shimmerContentView = "contentView"
    static let shimmerSubview = "subview"
    static let shimmerLocations = "locations"
    static let am = "AM"
    static let pm = "PM"
    static let progressDialogNib = "ProgressDialog"
    static let alertDialogNib = "AlertDialog"
    static let loadingError = "Could not load nib"
    static let initError = "init(coder:) has not been implemented"
    static let loadingTitle = "Loading"
    static let gallery = "Gallery"
    static let chooseImage = "Choose Image"
    static let camera = "Camera"
    static let authenticationNib = "TouchIDAuthentication"
    static let policyError = "Can't evaluate policy"
    static let authenticationFailure = "Failed to authenticate"
    static let authenticationReason = "Please confirm your Identity"
    static let deviceIncompatible = "Device Incompatible"
    static let deviceNotSupported = "Sorry, your device does not support this feature"
    static let textColor = "textColor"
    static let datePickerTitle = "UIDatePicker"
    static let datePickerViewTitle = "UIDatePickerWeekMonthDayView"
    static let datePickerContentViewTitle = "UIDatePickerContentView"
    static let yyyyMMdd = "yyyyMMdd"
    static let HHmm = "HHmm"
    static let timeDoubleDigitFormat = "%02d%02d"
    static let stopParameter = "any"
    static let coordinateParameter = "coord"
    static let coordinateFormat: String = "WGS84[DD.DDDDD]"
    static let postalCodeSuffix = "postal_code_suffix"
    static let postalCode = "postal_code"
    static let updateTabbarIndex = "updateTabbarIndex"
    static let regularTableViewHeaderHeight: CGFloat = 22
    static let largeTableViewHeaderHeight: CGFloat = 60
    static let headerViewHeight: CGFloat = 40
    static let largeTableViewHeaderHeightForHomeWorkFav: CGFloat = 50
    static let textFieldCornerRadius: CGFloat = 10
    static let textFieldBorderWidth: CGFloat = 1
}

// MARK: - Login Module
extension Constants {
    static let signIn = "Sign In"
    static let index = "index"
    static let loginFailed = "Login Failed"
    static let registerFailed = "Registration Failed"
}

// MARK: - Json Key
extension Constants {
    static let geoJsonFileName = "RiyadhGeoJSON"
    static let jsonType = "json"
    static let random = "random"
    static let randomOne = "random1"
}

// MARK: - Polygon Constants
extension Constants {
    static let polygonaAlphaComponent: CGFloat = 0.2
    static let polygonBorderWidth: CGFloat = 2
    static let polygonZeroCoordinate: CGFloat = 0
    static let polygonScale: CGFloat = 1
}

// MARK: - Polygon

struct RiyadhPolygon {

    struct Coordinates: Decodable {
        let features: [Feature]
    }
    struct Feature: Decodable {
        let geometry: Geometry
    }

    struct Geometry: Decodable {
        let coordinates: [[[Double]]]
    }

    static var bound: [CLLocationCoordinate2D] {
        if let path = Bundle.main.path(forResource: "RiyadhGeoJSON", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONDecoder().decode(Coordinates.self, from: data)
                let coords = jsonResult.features[1].geometry.coordinates[0].compactMap {
                   return CLLocationCoordinate2D(latitude: $0[1], longitude: $0[0])
                }
                return coords
            } catch {
                return []
            }
        }
        return []
    }
}

// MARK: - Report incidence
extension Constants {
    static let emailSuccess = "Email sent successfully"
    static let emailFailed = "Sorry, we are unable to send your email. Please try again."
    static let emailStatus = "Email Status"
    static let uploadingAttachment = "Attachment is uploading. Please wait."
    static let allFieldsRequired = "All fields are required"
    static let attachmentSizeLimit  = "File Size Exceed 25 MB"
}
// MARK: - Logout
extension Constants {
    static let logoutAlertTitle = "Log out"
    static let logoutAlertMessage = "Are you sure you want to log out?"
    static let logout = "Logout"
    static let logoutFailureMessage = "Could not log you out due to some technical error. Please try again!"
}

// MARK: - Places of Interest
extension Constants {
    static let placesOfInterest = "Places of Interest"
    static let selectLocationFromSearchResults = "Select Location from Search Results"
    static let selectLocationFromCategory = "Select Location from Category"
    static let searchForLocation = "Search for location"
}

// MARK: - Events
extension Constants {
    static let noEventsMessage = "No events available at this moment."
    static let thatsAll = "That's All"
    static let currentEvents = "Current Events"
    static let upcomingEvents = "Upcoming Events"
    static let dateFormatForEvents = "MM/dd/yyyyhh:mm a"
    static let entryFee = "Entry Fee  "
    static let noEventsSearchMessage = "No events available for the searched keyword."
}

// MARK: - Screen
enum ScreenName: String {
    case event = "Event"
    case eventDetails = "Event Details"
    case placesOfInterest = "Places of Interest"
    case plaesOfInterestCategory = "Places of Interest Category"
    case favourite = "Favorite"
    case liveTracking = "Live Tracking"
    case routesSelection = "Routes Selection"
    case home = "My Home"
    case locationSelectionOnMap = "Location Selection on Map"
    case notification = "Notification"
    case travelPreference = "Travel Preferences"
    case availableRoutes = "Available Routes"
    case myAccount = "My Account"
    case favouriteRoute = "Favorite Route"
    case favouriteLocation = "Favorite Location"
    case deleteAccount = "Delete Account"
    case stopSelection = "Stop Selection"
    case reportIncidence = "Report Incidence"
    case reportLostAndFound = "Report Lost And Found"
    case correspondance = "Correspondence"
    case cardOption = "Card Options"
    case fareMedia = "Fare Media"
    case editProfile = "Edit Profile"
    case contactInfo = "Contact Information"
    case news = "News"
    case newsDetails = "News Details"
    case sendQuery = "Send Query"
    case faq = "Frequently Asked Questions"
    case aboutKRPT = "About KRPT"
    case settings = "Settings"
    case profile = "Profile"
    case login = "Login"
    case signUp = "Sign Up"
    case paymentSuccess = "Payment Success"
    case busNetwork = "Bus"
    case fareTicketing = "Fares and Ticketing"
    case kaptInfo = "KAPT Information"
}

// MARK: - Fare Media
extension Constants {
    static let `true` = "true"
    static let sessionExpiredError = "The session has expired, please log in again."
    static let authenticationIncorrectError = "Authentication incorrect. Login please. "
    static let expiryDateFormat = "dd/MM/yyyy hh:mm"
    static let barcodeType = "barcode"
    static let operationFailedTitle = "Operation Failed!"
    static let operationFailedMessage = "Sorry, We are facing some issue on our side. Please try again later!"
    static let purchasedFareMedia = "My Tickets"
    static let purchasedFareMediaTicket = "Tickets"
    static let purchaseNewPass = "DSPurchaseAnewTicket"
    static let mypurchasedPass = "DSMyPurchasedTickets"
    static let qrCodeGenerationFailed = "Failed to Generate QR Code"
    static let aztecQRCodeFormat = "CIAztecCodeGenerator"
    static let payment = "Payment"
    static let transactionStartFailed = "Could not Initiate Transaction"
    static let transactionCanceled = "Transaction Cancelled"
    static let transactionCanceledMessage = "You have cancelled the payment transaction.";
    static let paymentSuccessful = "Payment Completed Successfully"
    static let paymentSuccessfulDescription = "Payment has been completed successfully."
    static let transactionFailedTitle = "Incomplete Transaction"
    static let transactionFailedMessage = "Could not complete the transaction. Please try again later."
    static let productDetails = "Product Details"
    static let availablePaymentMethods = "Available Payment Methods"
    static let enterDetails = "Enter details"
    static let cardAddedSuccessfulDescription = "Card has been added successfully. You will now be redirected to Payment Method Page in 10 seconds, You can also click on ‘Done’ to continue."
    static let cardAddedSuccessfully = "Card Added"
    static let productExpired = "EXPIRED"
    static let passExpiredAlertMessage = "Pass is expired."
    static let productNeverValidated = "NEVER_VALIDATED"
    
    static let activatePass = "Once activated, this ticket will be valid for 2 hours only."
    static let activate3DaysPass = "Once activated, this ticket will be valid for 3 days only."
    static let activate7DaysPass = "Once activated, this ticket will be valid for 7 days only."
    static let activate30DaysPass = "Once activated, this ticket will be valid for 30 days only."

    static let activatePassTitle = "Activate Pass"
    static let ticketsVisitedInfo = "To view your tickets or buy a new ticket, you must sign in to your account."
    static let doNotGoBack = "Please do not close the application or go back during the payment process."
    static let needInternetForTickets = "Dear Customer: Your device must be connected to the Internet to use the ticket."
    static let singleTripPassExpire = "Your 2 hours ticket pass will expire in 15 minutes."
    static let threeDaysPassExpire = "Your 3 days ticket pass will expire in 1 hour."
    static let sevenDaysPassExpire = "Your 7 days ticket pass will expire in 1 day."
    static let thirtyDaysPassExpire = "Your 30 days ticket pass will expire in 3 day."
}

// MARK: - Authentication Constants
extension Constants {
    static let userLoginTokenKey = "UserLoginToken"
    static let userWsoTokenKey = "UserWsoToken"
//    static let loginUsername = "mobilityportal10"
//    static let loginPassword = "_12345678Ta_"
    static let loginFailedError = "Could not log you in. Please try again later."
    static let registerFailedError = "Could not register. Please try again later."
    static let googleApiKey = "GoogleApiKey"
    static let basicAuthKeyDebugMode = "BasicAuthKeyDebugMode"
    static let basicAuthKeyStagingMode = "BasicAuthKeyStagingMode"
    static let basicAuthKeyProductionMode = "BasicAuthKeyProductionMode"
    static let passwordKey = "Password"

}

// MARK: - PickerWithDoneButton Constants
extension Constants {
    static let setMaximumDuration = "Set maximum walking duration"
    static let reset = "Reset"
    static let resetNow = "Reset Time"
}

// MARK: - Live Tracker Constants
extension Constants {
    static let defaultSpeed: CLLocationSpeed = 25
}

// MARK: - Travel Preferences
extension Constants {
    static let travelPreferences = "Travel Preferences"
    static let savePreferences = "Save Preferences"
    static let savePreferencesTitle = "Save for all trips"
    static let savePreferencesMessage = "Would you like to apply these preferences for all future trips also?"
    static let buttonNo = "No"
    static let buttonYes = "Yes"
    static let methodsOfTransport = "Methods of Transport"
    static let routePreference = "Route Preference"
    static let maximumWalkTime = "Maximum walk time"
    static let walkingSpeed = "Walking speed"
    static let alternativeStops = "Alternative Stops"
    static let nearbyAlternativeStops = "Include Nearby alternative stops"
    static let headerTextTransport = "Use the following methods of transport for trip planning"
    static let maxWalkTimeHeader = "Set max minutes for walking duration of your journey"
    static let quickestConnection = "Quickest Connection"
    static let fewerInterchanges = "Fewer Interchanges"
    static let leastWalking = "Least Walking"
    static let slow = "Slow"
    static let normal = "Normal"
    static let fast = "Fast"
}

// MARK: - Bus Network
extension Constants {
    static let riyadhBus = "Riyadh Bus"
    static let riyadhBusNetwork = "Riyadh Bus Network"
    static let aboutRiyadhBus = "About Riyadh Bus"
    static let rulesAndEtiquette = "Rules and Etiquette"
    static let ourBuses = "Our Buses"
    static let busStations = "Bus Stations"
    static let viewFullScreen = "View full screen"
    static let viewTimeTable = "View Timetable"
    static let routesMap = "Routes Map"
    static let routesServiceList = "Routes Service List"
    static let otherFacilities = "Other Facilities "
    static let busTimeTable = "Bus Timetable"
    static let stage1BusMap = "Open Stage 1 Bus Map"
    
    static let busRoutes = "Bus Routes"
    static let keyPointsBusTimeTable = "Key points served (neighbourhoods, places of interest)"
    static let busTimetable = "Bus Timetable"
    static let arrivalTime = "Arrival"
    static let busStation = "Bus station"
}

// MARK: - Sign Up
extension Constants {
    
    static let riyadhCountryCode = "+966 "
    static let passwordValidationMessage = "The password must be between 8 - 32 characters, contains (uppercases, lowercases, special characters and numbers), different from the current password and must not match with the last three passwords"
    static let repeatPasswordValidationMessage = "Password & Confirm Password do not match"
    static let firstNameValidationMessage = "Please enter characters (uppercase, lowercase, special character and numbers)"
    static let secondNameValidationMessage = "Please enter characters (uppercase, lowercase, special character and numbers)"
    static let notEmptyValidationMessage = "Field cannot be empty"
    static let citizenshipValidationMessage = "Citizenship ID cannot be empty"
    static let userIdValidationMessage = "The username must be 5-45 characters. Username cannot contain capital letters. Please enter only characters(lowercase and number)"
    static let mobileNumberValidationMessage = "Please enter valid mobile number" //"Please enter only digits"
    static let confirmNumberValidationMessage = "Phone number and confirm phone number should be same"
    static let emailValidationMessage = "Please enter a valid email address"
    static let confirmEmailValidationMessage = "Email & Confirm email do not match"
    static let verificationRequiredText = "Once you have entered your email address,if it matches the address of an account then an email will be sent instructing you how to reset your password.If you do not receive the email,please check your junk Email folder or ensure that you have typed the correct email address."
    static let registrationSuccessfulMessage = "An email was sent to the registered email address. Please open the received email and click on Verify to complete the registration. If you do not see the email in a few minutes, check your “junk mail” folder or “spam” folder."
    static let forgotPasswordDescription = "Enter your email address and we will send you a link to reset password"
    static let getStarted = "Get Started"
    static let forgotPassword = "Forgot Password"
    static let proceed = "Proceed"
    static let backtoAccount = "Back to account"
    static let verificationRequired = "Verification Required"
    static let accountInfoUpdatedTitle = "My Account Updated"
    static let accountInfoUpdatedMessage = "My Account has been successfully updated. Please click “Done” to continue or you will be redirected in 10 seconds."
}

// MARK: - Path Description
extension Constants {
    static let timeFormat = "h:mm a"
    static let dateFormatMMDD = "MM/dd/yyyy"
    static let viewCurrentLine = "View Current Bus Lines"
    static let dateTimeFormat = "dd/MM/yyyy hh:mm:ss"
    static let timeFormatForTwentyFour = "HH:mm"
}


// MARK: - OnBoarding Constants
extension Constants {
    static let planTripContent = "Plan or schedule a Trip based on all available modes of transport in accordance with your travel"
    static let skip = "SKIP"
    static let next = "NEXT"
    static let kaprptContent = "Learn about the Riyadh Bus, including bus routes and their timetables"
    static let placesOfInterestContent = "Search for places of interest or events in Riyadh city and plan a journey to or from them"
    static let personalization = "Personalisation"
    static let PersonalizationContent = "Open an account for enhanced personalisation and synching your details across several platforms"
    static let pageControlIcon = "⬥"
    static let onBoardingPlacesOfInterest = "Places of\nInterest"
    static let ScanYourTicket = "Scan your ticket on your device by placing the QR code on the ticket reader"
    static let price = "Price :"
    static let ticketType = "Ticket Type :"
    static let validUntil = "Valid until :"
    static let name = "Name :"
    static let ticketPrice = "Ticket Price :"
    static let ticketValidity = "Ticket Validity :"
    static let payViaCreditCard = "Pay Via Credit Card"
    static let ticketInformation = "Ticket Information"
    static let ticket = "Ticket"
}

// MARK: - Tab Bar Constant
extension Constants {
    static let tabhome = "Home"
    static let timeTable = "Routes"
    static let buyATicket = "Tickets"
    static let tabJourney = "Journey"
    static let tabFares = "Fares"
    static let tabContactUs = "Contact Us"
    static let alert = "Alert"
}

// MARK: - App Language
extension Constants {
    static let language = "Language"
    static let accept = "Accept"
    static let termCondition = "Terms and Conditions"
    static let privacyPolicyTitle = "Privacy and Data Protection Policy"
    static let youAreOffline = "You are offline"
}

extension Constants {
    static let privacyPolicy = "The Royal Commission for Riyadh City (RCRC) is committed to protecting the rights of visitors and users of this Website (rcrc.gov.sa) and confidentiality of their sensitive data. We have prepared this Privacy Policy to disclose our approach to collecting, processing and using user’s data.\nPlease read this Privacy Policy carefully to fully understand your relevant rights. If you do not agree to this Privacy Policy in general, or any of its terms, you should immediately stop using the Website.\n\nFor additional enquiries and comments regarding the Privacy Policy, please feel free to email us at: info@rcrc.gov.sa.\n\nWe may change or update this Privacy Policy from time to time, and any changes will be published on this Page. Any updates or changes shall become effective immediately upon publication, which requires you to always review this page for any updates.\n\nCollecting and Using Information\nInformation Provided by You\n\nYou may provide us with personal information when you contact us via contact form, email, telephone, social media, or by subscribing to our newsletters or notifications, or by creating an account.\nWe use your personal information for a variety of purposes including, but not limited to, communicate with you, send newsletters or notifications, contact you by phone or email, identify users, customize the content and services of our Website to suite your interests, enforce our Terms of Use, provide third parties with statistical information, and to keep you updated about our products, services, events, news, and other information that we think may interest you.\n\nTechnical Information\nWhen you visit our website, we automatically collect information that your computer, mobile phone or other device you use to browse our website sends to us. This information includes Internet Protocol (IP) address, and your device information including, but not limited to, operating system, name and type, mobile Internet network information, standard web information such as the type of browser and the pages you visit.\n\nWe collect such information to ensure that the content of the Website suites your interests and device capabilities, improve user experience, enhance Website performance, troubleshoot Website errors, analyze data, perform tests, conduct research, maintain information security, measure the effectiveness of the content we provide, and solve any issues on our servers.\n\nSecure Information Transmission\nUnder this Privacy Policy, we commit to protect and process your information and personal data securely. We also take reasonable physical, administrative and technical measures to protect your personal information from loss, theft, unauthorized use, illegal access or modification. However, the security of the Internet cannot be completely guaranteed, and therefore, we cannot guarantee the security or protection of any personal information provided via our Website, by e-mail or other means. Accordingly, any transmission of information via the Website shall be solely at your own risk.\n\nCookies\nThis website uses cookies. We use cookies to personalize content and ads, to provide social media features and to analyze our traffic. We also share information about your use of our site with our social media, advertising and analytics partners who may combine it with other information that you’ve provided to them or that they’ve collected from your use of their services.\n\nGeo-location\nSometimes, we may ask you to allow us to identify your geolocation to facilitate use of some of the services offered by the Website.\n\n Protecting Personal Information \n"
    
    static let cantTakeScreenShot = "You can't take screenshot of the QR code due to our Security Policy. Please Tap to Proceed to delete the screenshot."
    static let cantTakeScreenShotTitle = "Screenshots are not allowed."
    static let noPurchasedTickets = "You currently do not have any purchased tickets"
    
}

extension Constants {
    static let paymentDoneArabic = "متابعة";
    static let forMoreInfo = "For more information please visit our website:"
    static let emptyFieldMessageSignIn = "Username and password cannot be empty"
    static let twoHoursValidity = "ساعتين"
    static let routeTitle = "Routes"
    static let routeTitleTime = " (from 5AM till 12AM)"
    static let routeFullTitle = "Routes (from 5AM till 12AM)"
    static let bySendingMessage = "Send us a message"
    static let close = "Close"
    static let downloadMap = " Download Map "
}

// MARK: App Update
extension Constants {
    static let newVersionTitle = "New Version Available"
    static let newVersionMessage = "Please update the app to access all the features"
    static let newVersionFirstBtn = "Update"
    static let newVersionSecondBtn = "Cancel"
}

// MARK: Favorite
extension Constants {
    static let favoritesLocation = "Favorites Locations"
    static let myFavoriteRoutes = "Favorite Routes"
}

// MARK: - Apple Pay
extension Constants {
    static let countryCode = "SA"
    static let currencyCode = "SAR"
    //static let merchantIdentifier = "merchant.sa.gov.rcrc.mp"
    
    static let merchantIdentifier = "merchant.sa.gov.rcrc.mp.development"
}

// MARK: - Contact Us
extension Constants {
    static let feedBack = "Feedback"
    static let inquiry = "Inquiry"
    static let lostFound = "Lost & Found"
    static let feedBackSuccessMessage = "Feedback message successfully sent"
    static let inquirySuccessMessage = "Inquiry message successfully sent"
    static let lostFoundSuccessMessage = "Lost & Found message successfully sent"
}

extension Constants {
    static let transactionID = "Transaction ID"
    static let recordDate = "Record Date"
    static let station = "Station"
    static let referenceID = "Reference ID"
    static let paymentTypeName = "Payment Type Name"
    static let product = "Product"
    static let mediumType = "Medium Type"
    static let travelLine = "Travel Line"
    static let stationName = "Station Name"
    static let dateOfTravel = "Date of Travel"
    static let doYouWantToEdit = "Edit Favorite Location"
    static let mobileNumer = "Mobile Number"
    static let transactionDate = "Transaction Date"
    static let transactionFailed = "Transaction Failed"
    static let paymentType = "Payment Type"
    static let attachFile = "Attach File"
}

// MARK: - Live Map
extension Constants {
    static let busRoute = "Bus Route"
    static let allRoutes = "All Routes"
    static let onTime = "On Time"
    static let smallMin = "min"
    static let towards = "towards"
    static let getOff = "get off"
    static let route = "Route"
    static let departureInfo = "Departure"
    static let directionTo = "Direction to:"
    static let comma = currentLanguage == .english ? ",":" ، "
}

