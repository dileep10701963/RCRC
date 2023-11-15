//
//  PlacesOfInterestTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 25/06/21.
//

import XCTest
import CoreLocation
@testable import Riyadh_Journey_Planner

class PlacesOfInterestTests: XCTestCase {

    func test_fetchPlacesOfInterest_deliversPOIsInRiyadhCenter_IfLocationIsOutsideRiyadhOrLocationIsNotSet() {
        let sut = PlacesOfInterestViewModel()
        let exp = expectation(description: "Nearby Places Of Interest")
        sut.fetchPlaces(location: CLLocationCoordinate2D(latitude: 30.7136, longitude: 46.6753), pageToken: .none, text: .none, category: .shoppingMall) { result in
            exp.fulfill()
            switch result {
            case let .success(pois):
                XCTAssertGreaterThan(pois.results?.count ?? 0, 0)
            case .failure:
                XCTFail("Nearby Places of Interest API Failure")
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_fetchPlacesOfInterest_deliversPOIsNearLocation_IfLocationIsInRiyadh() {
        let sut = PlacesOfInterestViewModel()
        let exp = expectation(description: "Nearby Places Of Interest")
        sut.fetchPlaces(location: CLLocationCoordinate2D(latitude: 30.7136, longitude: 46.6753), pageToken: .none, text: .none, category: .shoppingMall) { result in
            exp.fulfill()
            switch result {
            case let .success(pois):
                XCTAssertGreaterThan(pois.results?.count ?? 0, 0)
            case .failure:
                XCTFail("Nearby Places of Interest API Failure")
            }
        }
        wait(for: [exp], timeout: 10.0)
    }
}

