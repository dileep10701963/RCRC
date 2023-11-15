//
//  EventCellViewModelTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 24/06/21.
//

import XCTest
import GoogleMaps
@testable import Riyadh_Journey_Planner

class EventCellViewModelTests: XCTestCase {


    func test_getAddress_returnsAddressIfLocationIsValid() {
        let sut = makeSUT()
        let exp = expectation(description: "Fetch address")
        sut.getAddress { address in
            exp.fulfill()
            XCTAssertNotNil(address)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_getAddress_returnsNilIfLocationIsInValid() {
        let sut = makeSUT(coordinate: nil)
        let exp = expectation(description: "Fetch address")
        sut.getAddress { address in
            exp.fulfill()
            XCTAssertNil(address)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_getDistance_returnsDistanceIfLocationIsValid() {
        let sut = makeSUT()
        let exp = expectation(description: "Fetch Distance")
        sut.getDistance(from: CLLocationCoordinate2D(latitude: 24.54799, longitude: 46.62155)) { distance in
            exp.fulfill()
            XCTAssertNotNil(distance)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_getDistance_returnsNilIfLocationIsInValid() {
        let sut = makeSUT(coordinate: nil)
        let exp = expectation(description: "Fetch Distance")
        sut.getDistance(from: CLLocationCoordinate2D(latitude: 24.54799, longitude: 46.62155)) { distance in
            exp.fulfill()
            XCTAssertNil(distance)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_loadImage_deliversImageOnSuccess() {
        let sut = makeSUT()
        let exp = expectation(description: "Load Image")
        sut.loadImage { image in
            exp.fulfill()
            XCTAssertNotNil(image)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_loadImage_doesNotDeliverImageOnFailureOrInvalidURL() {
        let sut = makeSUT(url: URL(string: "https://www.google.com")!)
        let exp = expectation(description: "Load Image")
        sut.loadImage { image in
            exp.fulfill()
            XCTAssertNil(image)
        }
        wait(for: [exp], timeout: 10.0)
    }

    // MARK: - Helpers
    private func makeSUT(coordinate: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 24.52799, longitude: 46.65155), url: URL = URL(string: "https://192.168.59.11:8080/documents/20124/70040/201_hokey.jpg")!) -> EventCellViewModel {
        let sut = EventCellViewModel(name: "Event Name", duration: NSAttributedString(string: "06/26/2021, 01:30 PM to 06/29/2021, 06:30 PM"), imageURL: url, entryFee: NSAttributedString(string: "Entry Fee 10 SAR"), description: "Event Description", coordinate: coordinate, entryCost: "", eventType: .current)
        return sut
    }
}
