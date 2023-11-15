//
//  CoreDataTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Admin on 02/03/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class CoreDataTests: XCTestCase {

    var contactRepository: ContactInfoDataRepository?
    var faqRepository: FaqDataRepository?
    var userProfileRepository: UserProfileDataRepository?
    var favouriteRouteRepository: FavoriteRouteDataRepository?
    var recentSearchRepository: RecentSearchDataRepository?
    var homeLocationRepository: HomeLocationsDataRepository?
    var workLocationRepository: WorkLocationsDataRepository?
    var favouriteLocationRepository: FavoriteLocationDataRepository?

    var travelPreferenceRepository: TravewlPreferenceDataRepository?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        contactRepository = ContactInfoDataRepository()
        faqRepository = FaqDataRepository()
        userProfileRepository = UserProfileDataRepository()
        favouriteRouteRepository = FavoriteRouteDataRepository()
        recentSearchRepository  = RecentSearchDataRepository()
        homeLocationRepository = HomeLocationsDataRepository()
        workLocationRepository = WorkLocationsDataRepository()
        travelPreferenceRepository = TravewlPreferenceDataRepository()
        favouriteLocationRepository = FavoriteLocationDataRepository()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        contactRepository = nil
        faqRepository = nil
        userProfileRepository = nil
        favouriteRouteRepository = nil
        recentSearchRepository = nil
        homeLocationRepository = nil
        workLocationRepository = nil
        travelPreferenceRepository = nil
        favouriteLocationRepository = nil
    }

    // CoreData Test Cases
    // FAQ
    func testFaqInsert() {
        let info = FAQResponse(question: "test question", answer: "test Answer")
        faqRepository!.create(record: info)
        let records = faqRepository!.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testFaqDelete() {
        faqRepository?.deleteAll(entity: .faq)
        let records = faqRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    // CONTACT
    func testContactInsert() {
        let contactInfo = ContactInformation(address: "Pune", phoneNumber: "9000000000", emailId: "email@test.com") //contacdt(question: "test question", answer: "test Answer")
        contactRepository!.create(record: contactInfo)
        let records = contactRepository!.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testContactDelete() {
        contactRepository?.deleteAll(entity: .contact)
        let records = faqRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    // User profile
    func testProfileInfoInsert() {
        let info = ProfileInformation(emailAddress: "ganeshn.shinde@lntinfotech.com", mobileNumber: "9900000000", fullName: "Sam", image: Data())
        userProfileRepository!.create(record: info)
        let records = userProfileRepository!.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testProfileInfoDeleteAll() {
        userProfileRepository?.deleteAll(entity: .profile)
        let records = userProfileRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    func testProfileInfoDelete() {
        let allRecords = userProfileRepository?.fetchAll()
        userProfileRepository?.delete()
        let records = userProfileRepository?.fetchAll()
        if allRecords?.count ?? 0 > 1 {
            XCTAssertEqual((allRecords?.count ?? 0) - 1, records?.count)
        }else {
            XCTAssertEqual(records?.count ?? 0, 0)
        }
    }

    func testProfileInfoUpdate(){
        userProfileRepository?.deleteAll(entity: .profile)
        let userData = ProfileInformation(emailAddress: "test@gmail.com", mobileNumber: "9900000000", fullName: "Test", image: nil)
        userProfileRepository?.create(record: userData)
        let updateData = ProfileInformation(emailAddress: "test@gmail.com", mobileNumber: "9900000000", fullName: "Test1", image: nil)
        userProfileRepository?.update(record: updateData)
        let records = UserProfileDataRepository.shared.fetchAll()
        let profileInfo = records?.first
        XCTAssertEqual("Test1", profileInfo?.fullName ?? "")
        
    }
    // Favourite
    func testFavouriteRouteDataInsert() {
        let info = FavoriteRoute(sourceType: "id", destinationType: "id", sourceId: "12", destinationId: "13", sourceAddress: "Riyadh", destinationAddress: "Riyadh ATM", sourceLatitude: "41.26", destinationLatitude: "41.26433", sourceLongitude: "41.333333", destinationLongitude: "42.13333")
        favouriteRouteRepository?.create(record: info)
        let records = favouriteRouteRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)

    }
    func testFavouriteRouteDataDeleteAll() {
        favouriteRouteRepository?.deleteAll(entity: .favoriteRoute)
        let records = favouriteRouteRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    func testFavouriteRouteDataDelete() {
        favouriteRouteRepository?.deleteAll(entity: .favoriteRoute)
        let info = FavoriteRoute(sourceType: "id", destinationType: "id", sourceId: "12", destinationId: "13", sourceAddress: "Riyadh", destinationAddress: "Riyadh ATM", sourceLatitude: "41.26", destinationLatitude: "41.26433", sourceLongitude: "41.333333", destinationLongitude: "42.13333")
        favouriteRouteRepository?.create(record: info)
        favouriteRouteRepository?.delete(record: info)
        let records = favouriteRouteRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    // Recent Search
    func testRecentSearchDataInsert() {
        let info = RecentSearch(id: "80000223", location: "Arfat 08", address: "Riyadh", latitude: 24.52799, longitude: 46.54322, type: "stop")
        recentSearchRepository?.create(record: info)
        let records = recentSearchRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testRecentSearchDataDeleteAll() {
        recentSearchRepository?.deleteAll(entity: .recentSearches)
        let records = recentSearchRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }
    
    func testRecentSearchDataDelete() {
        recentSearchRepository?.deleteAll(entity: .recentSearches)
        let info = RecentSearch(id: "80000223", location: "Arfat 08", address: "Riyadh", latitude: 24.52799, longitude: 46.54322, type: "stop")
        recentSearchRepository?.create(record: info)
        recentSearchRepository?.delete(record: info)
        let records = recentSearchRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    // MARK: - Home Locations
    func testHomeLocationsInsert() {
        let homeLocation = SavedLocation(location: "Arfat 08", address: "Riyadh", id: "80000223",
                                         latitude: 24.52799, longitude: 46.54322, type: "stop")
        homeLocationRepository?.create(record: homeLocation)
        let records = homeLocationRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testHomeLocationsDeleteAll() {
        homeLocationRepository?.deleteAll(entity: .homeLocations)
        let records = homeLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    func testHomeLocationsDelete() {
        homeLocationRepository?.deleteAll(entity: .homeLocations)
        let homeLocation = SavedLocation(location: "Arfat 08", address: "Riyadh", id: "80000223",
                                         latitude: 24.52799, longitude: 46.54322, type: "stop")
        homeLocationRepository?.create(record: homeLocation)
        
        homeLocationRepository?.delete(record: homeLocation)
        let records = homeLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    
    // MARK: - Work Locations
    func testWorkLocationsInsert() {
        let workLocation = SavedLocation(location: "Arfat 08", address: "Riyadh", id: "80000223",
                                         latitude: 24.52799, longitude: 46.54322, type: "stop")
        workLocationRepository?.create(record: workLocation)
        let records = workLocationRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testWorkLocationsDeleteAll() {
        workLocationRepository?.deleteAll(entity: .workLocations)
        let records = workLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }
    
    func testWorkLocationsDelete() {
        workLocationRepository?.deleteAll(entity: .workLocations)
        let workLocation = SavedLocation(location: "Arfat 08", address: "Riyadh", id: "80000223",
                                         latitude: 24.52799, longitude: 46.54322, type: "stop")
        workLocationRepository?.create(record: workLocation)        
        WorkLocationsDataRepository.shared.delete(record: workLocation)
        let records = workLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    // MARK: - Favourite Location
    
    func testFouriteLocationInsert(){
        let info = SavedLocation(location: "Test", address: "Test Address", id: "33", latitude: 33.22, longitude: 44.33, type: "test")
        favouriteLocationRepository?.create(record: info)
        let records = favouriteLocationRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }
    
    func testFouriteLocationDeleteAll(){
        favouriteLocationRepository?.deleteAll(entity: .favoriteLocation)
        let records = favouriteLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }
    
    func testFouriteLocationDelete(){
        favouriteLocationRepository?.deleteAll(entity: .favoriteLocation)
        let info = SavedLocation(location: "Test", address: "Test Address", id: "33", latitude: 33.22, longitude: 44.33, type: "test")
        favouriteLocationRepository?.create(record: info)
        favouriteLocationRepository?.delete(record: info)
        let records = favouriteLocationRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }
    
    // MARK: - Travel Preference

    func testTravelPreferenceInsert() {
        let travelPref = TravelPreference(mobilityImpairedFriendly: "TestMobilityImpairedFriendly", sortingType: "Ascending", transportMethod: "TestMethod")
        travelPreferenceRepository?.create(record: travelPref)
        let records = travelPreferenceRepository?.fetchAll()
        XCTAssertGreaterThan(records?.count ?? 0, 0)
    }

    func testTravelPreferenceDelete() {
        travelPreferenceRepository?.deleteAll(entity: .workLocations)
        let records = travelPreferenceRepository?.fetchAll()
        XCTAssertEqual(records?.count ?? 0, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
