import XCTest
@testable import Riyadh_Journey_Planner

class Riyadh_Journey_PlannerTests: XCTestCase {

    var homeViewModel: HomeViewModel?
    var searchViewModel: SearchResultsViewModel?
    var frequentlyAskedQuestionModel: FrequentlyAskedQuestionViewModel?
    var contactViewModel: ContactViewModel?
    var reportLostViewModel: ReportLostViewModel?

    override func setUpWithError() throws {
        homeViewModel = HomeViewModel()
        searchViewModel = SearchResultsViewModel()
        frequentlyAskedQuestionModel = FrequentlyAskedQuestionViewModel()
        contactViewModel = ContactViewModel()
        reportLostViewModel = ReportLostViewModel()
    }

    func testStopFinderApi() throws {
        let searchInput = "riyadh"
        let expectation = self.expectation(description: "StopFinder Api testing")
        searchViewModel?.fetchSearchResults(input: searchInput, completionHandler: {
            expectation.fulfill()
        })
        self.waitForExpectations(timeout: 10)
        searchViewModel?.stopFinderResults.bind({ (search, error) in
            XCTAssertNotNil(search, "Getting error from the server")
            XCTAssertGreaterThan(search?.locations.count ?? 0, 0)
            XCTAssertNil(error, "No response from server")
        })
    }

    func testFrequentlyAskedQuestionApi () throws {
        let expectation = self.expectation(description: "Frequently asked question Api testing")
        frequentlyAskedQuestionModel?.getFAQ()
        frequentlyAskedQuestionModel?.faqResult.bind { result, error in
            if result == nil && error == nil {}
            else {
                XCTAssertGreaterThan(result?.items?.count ?? 0, 0)
                XCTAssertNotNil(result, "Getting error from the server")
                XCTAssertNil(error, "No response from server")
            }
        }
        self.wait(for: [expectation], timeout: 35)
    }

    func testWeatherApi() throws {
        let expectation = self.expectation(description: "Weather Api testing")
        homeViewModel?.getWeather {
                expectation.fulfill()
        }
        self.waitForExpectations(timeout: 35)
        homeViewModel?.weatherResult.bind({ (weather, error) in
            XCTAssertNotNil(weather, "Getting error from the server")
            XCTAssertNotNil(weather?.temperature, "Temperature nil")
            XCTAssertNil(error, "Getting error from the server")
        })
    }

    func testWeatherApiReturnsErrorOnInvalidURL() throws {
        let expectation = self.expectation(description: "Weather Api testing")
        homeViewModel?.getWeather(endpoint: " ") {
                expectation.fulfill()
        }
        self.waitForExpectations(timeout: 35)
        homeViewModel?.weatherResult.bind({ (_, error) in
            XCTAssertNotNil(error)
        })
    }

    func testContactApi() {
        let expectation = self.expectation(description: "Contact Api testing")
        contactViewModel?.fetchContactDetails {
                expectation.fulfill()
        }
        self.waitForExpectations(timeout: 10)
        contactViewModel?.contactDetails.bind({ (contact, error) in
            XCTAssertNotNil(contact, "Getting error from the server")
            XCTAssertNotNil(contact?.items.count, "Item nil")
            XCTAssertNil(error, "Getting error from the server")
        })
    }

    func testReportValidationSuccess() {

        reportLostViewModel?.dateOfIncidence = "05/05/2021"
        reportLostViewModel?.issue = "Test issue"
        reportLostViewModel?.name = "Test name"
        reportLostViewModel?.email = "email@email.com"
        reportLostViewModel?.contactNumber = "9000000000"
        reportLostViewModel?.itemCategory = "Lost and found"
        reportLostViewModel?.placeOfIncidence = "Test location"
        reportLostViewModel?.itemDetail = "Item details"
        XCTAssertTrue(reportLostViewModel?.validateReport() ?? false)
    }

    func testReportValidationFailed() {
        reportLostViewModel?.dateOfIncidence = ""
        reportLostViewModel?.issue = ""
        reportLostViewModel?.name = ""
        reportLostViewModel?.email = ""
        reportLostViewModel?.contactNumber = ""
        reportLostViewModel?.itemCategory = ""
        reportLostViewModel?.placeOfIncidence = ""
        reportLostViewModel?.itemDetail = ""
        XCTAssertFalse(reportLostViewModel!.validateReport())
    }

    func test_FavoriteLocationsEquatable() {
        let location1 = FavoriteLocation(id: "80000201", location: "Arfat 01", address: "Riyadh", latitude: 24.42, longitude: 42.21, type: "stop")
        let location2 = FavoriteLocation(id: "80000201", location: "Arfat 01", address: "Riyadh", latitude: 24.42, longitude: 42.21, type: "stop")

        let result = location1 == location2

        XCTAssertTrue(result)
    }

    func test_RecentSearchesEquatable() {
        let location1 = RecentSearch(id: "80000202", location: "Arfat 02", address: "Riyadh", latitude: 24.42, longitude: 42.21, type: "stop")
        let location2 = RecentSearch(id: "80000202", location: "Arfat 02", address: "Riyadh", latitude: 24.42, longitude: 42.21, type: "stop")

        let result = location1 == location2

        XCTAssertTrue(result)
    }

    func test_CorrespondenceList_containsValidListCount() {
        let sut = CorrespondenceViewModel()
        XCTAssertEqual(sut.correspondenceList.count, 3)
        XCTAssertEqual(sut.correspondenceImageList.count, 3)
    }

    func test_GoogleGeocodereuestInit() {
        let request = GoogleGeocodeRequest()
        XCTAssertEqual(request.language, "en")
    }

    override func tearDownWithError() throws {
        homeViewModel = nil
        searchViewModel = nil
        frequentlyAskedQuestionModel = nil
        reportLostViewModel = nil
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
