//
//  TravelPreferencesTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Aashish Singh on 25/11/22.
//

import XCTest
@testable import Riyadh_Journey_Planner

class TravelPreferencesTests: XCTestCase {
    
    func test_TravelPreferencesValidAPITest_returnsResults() {
        let sut = TravelPreferencesViewModel()
        let exp = expectation(description: "TravelPreferences Test API")

        sut.fetchTravelPreferencesResult()
        sut.travelPreferencesResult.bind { result, error in
            if result == nil && error == nil {}
            else {
                XCTAssertNotNil(result)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 10.0)
    }
    
    func test_TravelPreferencesWithInvalidURL_returnsDefaultValue() {
        let sut = TravelPreferencesViewModel()
        let exp = expectation(description: "TravelPreferences Test API Invalid URL")

        sut.fetchTravelPreferencesResult(endpoint: "Inavlid EndPoint", input: "Invalid Input")
        sut.travelPreferencesResult.bind { result, error in
            if result == nil && error == nil {}
            else {
                XCTAssertEqual(result?.maxTime, .fifteenMin)
                XCTAssertTrue(result?.busTransport ?? false)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 10.0)
    }
    
    func test_SaveTravelPreferencesWithInvalidURL_returnsDefaultValue() {
        let sut = TravelPreferencesViewModel()
        let exp = expectation(description: "Save TravelPreferences Test API Invalid URL")

        let modal = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: false, maxTime: .thirtyMin, metroTransport: false, routePreference: .least, uberTransport: false, walkSpeed: .normal)
        sut.saveTravelPreferences(endpoint: " ", preferenceModel: modal) { result in
            switch result {
            case .success:
                XCTFail("Expected Error from server, received response instead")
            case .failure(let networkError, _):
                XCTAssertNotNil(networkError)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 10.0)
    }
    
    func test_SaveTravelPreferences_returnsResponse() {
        let sut = TravelPreferencesViewModel()
        let exp = expectation(description: "Save TravelPreferences Test API")

        let modal = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: false, maxTime: .fifteenMin, metroTransport: false, routePreference: .least, uberTransport: false, walkSpeed: .normal)
        sut.saveTravelPreferences(preferenceModel: modal) { result in
            switch result {
            case .success:
                exp.fulfill()
            case .failure(_, _):
                XCTFail("Expected Success from server, received error instead")
            }
        }
        
        wait(for: [exp], timeout: 10.0)
    }
    
}
