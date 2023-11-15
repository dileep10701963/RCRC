//
//  StopfinderEndToEndTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 04/06/21.
//

import XCTest
import GoogleMaps
@testable import Riyadh_Journey_Planner

class StopfinderEndToEndTests: XCTestCase {

    func test_StopfinderForValidPOIOrStop_returnsResults() {
        let sut = SearchResultsViewModel()
        let exp = expectation(description: "Stopfinder test for POI/Stop")

        sut.searchText = "Arfat"

        sut.stopFinderResults.bind { result, error in
            if result != nil {
                exp.fulfill()
                XCTAssertGreaterThan(result?.locations.count ?? 0, 0)
            } else if error != nil {
                XCTFail("Stopfinder API is not working for POI")
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_StopfinderForValidCoordinate_returnsResults() {
        let sut = SearchResultsViewModel()
        let exp = expectation(description: "Stopfinder test for Coordinate")
        let coordinate = CLLocationCoordinate2D(latitude: 24.55548, longitude: 46.72643)

        sut.reverseGeocode(input: coordinate) { result in
            XCTAssertGreaterThan(result?.locations.count ?? 0, 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_stopfinderForPOIWithInvalidURL_returnsError() {
        let sut = SearchResultsViewModel()
        let exp = expectation(description: "Stopfinder test for POI/Stop")

        sut.fetchSearchResults(endpoint: " ", input: "Arfat")

        sut.stopFinderResults.bind { result, error in
            if result == nil && error == nil {}
            else {
                if error != nil {
                    exp.fulfill()
                    XCTAssertNil(result)
                } else if result != nil {
                    XCTFail("Expected Error from server, received response instead")
                }
            }
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_stopfinderForCoordinateWithInvalidURL_returnsError() {
        let sut = SearchResultsViewModel()
        let exp = expectation(description: "Stopfinder test for Coordinate")
        let coordinate = CLLocationCoordinate2D(latitude: 24.503398, longitude: 46.633115)

        sut.reverseGeocode(endpoint: " ", input: coordinate) { result in
            XCTAssertNil(result)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_stopfinder_displays0rowsOnInit() {
        let sut = SearchResultsViewModel()
        let tableView = UITableView()

        tableView.dataSource = sut

        XCTAssertEqual(tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0), 0)
    }

    func test_stopfinderWithValidInput_displaysCorrectNumberOfRows() {
        let sut = SearchResultsViewModel()
        let tableView = UITableView()
        tableView.dataSource = sut
        let exp = expectation(description: "Stopfinder tableview testing")

        sut.fetchSearchResults(input: "Arfat") {
            exp.fulfill()
            XCTAssertEqual(sut.stopFinderResults.value?.locations.count, tableView.dataSource?.tableView(tableView, numberOfRowsInSection: sut.stopFinderResults.value?.locations.count ?? 0))
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_stopfinderWithValidInput_displaysCorrectResultAtIndexPath_0_0() {
        let sut = SearchResultsViewModel()
        let tableView = UITableView()
        tableView.register(SearchResultsTableViewCell.nib, forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
        tableView.dataSource = sut
        let exp = expectation(description: "Stopfinder tableview testing")

        sut.fetchSearchResults(input: "Arfat") {
            exp.fulfill()
            let indexPath = IndexPath(row: 0, section: 0)
            let cell = tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as! SearchResultsTableViewCell
            XCTAssertEqual(cell.stopResult?.id, sut.stopFinderResults.value?.locations[0]?.id)
            XCTAssertEqual(cell.stopResult?.name, sut.stopFinderResults.value?.locations[0]?.name)
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_stopfinder_tableView_displaysWithCorrectHeaderHeightAndTitle() {
        let sut = SearchResultsViewModel()
        let tableView = UITableView()
        tableView.dataSource = sut
        tableView.delegate = sut

        XCTAssertEqual(tableView.dataSource?.tableView?(tableView, titleForHeaderInSection: 0), " ")
        XCTAssertEqual(tableView.delegate?.tableView?(tableView, heightForHeaderInSection: 0), 15.0)
    }
}
