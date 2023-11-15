//
//  AvailableRoutesTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 31/05/21.
//

import XCTest
import GoogleMaps
@testable import Riyadh_Journey_Planner

class AvailableRoutesTests: XCTestCase {

    func test_invalid_Origin_returns_0_CellViewModels() {
        let origin = LocationData(id: "", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let destination = LocationData(id: "80000209", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()
        let expectations = expectation(description: "Fetch Trips")

        sut.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedPreferences, travelPreference: nil) { result in
            XCTAssertEqual(result.count, 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 10)
    }

    func test_invalid_Destination_returns_0_CellViewModels() {
        let origin = LocationData(id: "80000201", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let destination = LocationData(id: "", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()
        let expectations = expectation(description: "Fetch Trips")

        sut.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedPreferences, travelPreference: nil) { result in
            XCTAssertEqual(result.count, 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 10)
    }

    func test_valid_OriginDestination_returns_CellViewModels() {
        let origin = LocationData(id: "80000201", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let destination = LocationData(id: "80000209", address: "Arfat", subAddress: "arfat", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()
        let expectations = expectation(description: "Fetch Trips")

        sut.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedPreferences, travelPreference: nil) { result in
            XCTAssertGreaterThan(result.count, 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 10)
    }

    func test_TripWithMultipleTransportModes_returnsCorrectNumberOfCellViewModels() {
        let origin = LocationData(id: "80000341", address: "Dirab 08", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let destination = LocationData(id: "80000220", address: "Dirab 02", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()
        let expectations = expectation(description: "Fetch Trips")

        sut.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedPreferences, travelPreference: nil) { result in
            XCTAssertGreaterThan(result.count, 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 10)
    }
    
    func test_TripWithTravelPreferences_returnsCorrectNumberOfCellViewModels() {
        let origin = LocationData(id: "80000341", address: "Dirab 08", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let destination = LocationData(id: "80000220", address: "Dirab 02", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), type: .stop)
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()
        let expectations = expectation(description: "Fetch Trips")
        let travelPreferences = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: false, maxTime: .fortyFiveMin, metroTransport: false, routePreference: .least, uberTransport: false, walkSpeed: .normal)

        sut.fetchTrips(origin: origin, destination: destination, searchPreferences: selectedPreferences, travelPreference: travelPreferences) { result in
            XCTAssertGreaterThan(result.count, 0)
            expectations.fulfill()
        }
        wait(for: [expectations], timeout: 10)
    }

    func test_inputPreferenceParametersNow_returnsValidRequestParametersForNow() {
        let fixedDate = Date()
        let selectedPreferences = SelectedSearchPreferences(availability: "Now", date: fixedDate, hour: fixedDate.hour.string, minute: fixedDate.minute.string)
        let sut = makeSUT()

        let (option, date, time) = sut.makeTripPreferenceRequestParameters(selectedPreferences)
        let currentTime = String(format: Constants.timeDoubleDigitFormat, arguments: [fixedDate.hour, fixedDate.minute])
        let currentDate = Utilities.DateTime.getCurrentDate(timeZone: .AST, format: Constants.yyyyMMdd)

        XCTAssertEqual(option, "dep")
        XCTAssertEqual(date, currentDate)
        XCTAssertEqual(time, currentTime)
    }

    func test_inputPreferenceParametersLeave_returnsValidRequestParametersForLeave() {
        let fixedDate = Date()
        let tripPreference = SelectedSearchPreferences(availability: "Leave", date: fixedDate, hour: "12", minute: "20")
        let sut = makeSUT()

        let (option, date, time) = sut.makeTripPreferenceRequestParameters(tripPreference)

        XCTAssertEqual(option, "dep")
        XCTAssertEqual(date, fixedDate.dateString)
        XCTAssertEqual(time, "1220")
    }

    func test_inputPreferenceParametersArrive_returnsValidRequestParametersForArrive() {
        let fixedDate = Date()
        let tripPreference = SelectedSearchPreferences(availability: "Arrive", date: fixedDate, hour: "12", minute: "20")
        let sut = AvailableRoutesViewModel()

        let (option, date, time) = sut.makeTripPreferenceRequestParameters(tripPreference)

        XCTAssertEqual(option, "arr")
        XCTAssertEqual(date, fixedDate.dateString)
        XCTAssertEqual(time, "1220")
    }

    func test_inputLocationParametersForStop_returnsValidRequestParametersForStop() {
        let location = LocationData(id: "80000201", address: "Location Address", subAddress: "Location SubAddress", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .stop)
        let sut = makeSUT()

        let (locationName, locationType) = sut.makeLocationRequestParameters(location)

        XCTAssertEqual(locationName, location.id)
        XCTAssertEqual(locationType, "any")
    }

    func test_inputLocationParametersForCoordinate_returnsValidRequestParametersForCoordinate() {
        let location = LocationData(id: "80000201", address: "Location Address", subAddress: "Location SubAddress", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .coordinate)
        let sut = makeSUT()

        let (locationName, locationType) = sut.makeLocationRequestParameters(location)

        XCTAssertEqual(locationName, "\(location.coordinate?.longitude ?? 24):\(location.coordinate?.latitude ?? 42):WGS84[DD.DDDDD]")
        XCTAssertEqual(locationType, "coord")
    }

    func test_calculateTravelTime_deliversExpectedTravelTime() {
        let data = Data("{\"legs\":[{\"transportation\":{\"product\":{\"id\":1,\"class\":5,\"name\":\"Bus\",\"iconId\":3}},\"duration\":2021,},{\"transportation\":{\"product\":{\"id\":1,\"class\":5,\"name\":\"Bus\",\"iconId\":3}},\"duration\":3043,},{\"transportation\":{\"product\":{\"id\":1,\"class\":5,\"name\":\"Bus\",\"iconId\":3}},\"duration\":105,},{\"transportation\":{\"product\":{\"id\":1,\"class\":5,\"name\":\"Bus\",\"iconId\":3}},\"duration\":505,},{\"transportation\":{\"product\":{\"id\":1,\"class\":5,\"name\":\"Bus\",\"iconId\":3}},\"duration\":506,}]}".utf8)
        let journey = try? JSONDecoder().decode(Journey.self, from: data)

        let sut = TripCellViewModel(journey: journey)

        XCTAssertEqual(sut.travelTime, "103 Mins")
    }

    func test_SaveRouteAsFavoriteAndCheckIfSaved_returnsTrueIfSaved() {
        let sut = makeSUT()
        let origin = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .stop)
        let destination = LocationData(id: "80000205", address: "Arfat 05", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 25, longitude: 43), type: .stop)
        sut.saveRoute(source: origin, destination: destination)

        let isFavorite = sut.isRouteFavorite(source: origin, destination: destination)

        XCTAssertTrue(isFavorite)
    }

    func test_SaveRouteAsFavoriteAndCheckIfSaved_returnsFalseIfNotSaved() {
        let sut = makeSUT()
        let origin = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .stop)
        let destination = LocationData(id: "80000205", address: "Arfat 05", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 25, longitude: 43), type: .stop)
        sut.saveRoute(source: origin, destination: destination)

        let notSavedOrigin = LocationData(id: "80000202", address: "Arfat 02", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .stop)
        let isFavorite = sut.isRouteFavorite(source: notSavedOrigin, destination: destination)

        XCTAssertFalse(isFavorite)
    }

    func test_RemoveSavedRouteFromFavorite() {
        let sut = makeSUT()
        let origin = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24, longitude: 42), type: .stop)
        let destination = LocationData(id: "80000205", address: "Arfat 05", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 25, longitude: 43), type: .stop)
        sut.saveRoute(source: origin, destination: destination)

        sut.removeRoute(source: origin, destination: destination)

        let isSaved = sut.isRouteFavorite(source: origin, destination: destination)
        XCTAssertFalse(isSaved)
    }

    func test_RouteSelectionViewDataModel_initialization() {
        let sut = RouteSelectionViewData()
        XCTAssertNotNil(sut)
    }

    func test_LocationDataEquatable_returnsEqualIfEqual() {
        let location1 = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24.11, longitude: 42.22), type: .stop)
        let location2 = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: CLLocationCoordinate2D(latitude: 24.11, longitude: 42.22), type: .stop)

        XCTAssertEqual(location1, location2)
    }

    func test_LocationDataEquatable_returnsNotEqualIfNotEqual() {
        let location1 = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: nil, type: .stop)
        let location2 = LocationData(id: "80000201", address: "Arfat 01", subAddress: "Riyadh", coordinate: nil, type: .coordinate)

        XCTAssertNotEqual(location1, location2)
    }

    // MARK: - Helpers
    private func makeSUT() -> AvailableRoutesViewModel {
        let sut = AvailableRoutesViewModel()
        checkForMemoryLeak(sut)
        return sut
    }

    private func checkForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
