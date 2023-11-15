//
//  EventLoaderTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 24/06/21.
//

import XCTest
import Alamofire
@testable import Riyadh_Journey_Planner

class EventLoaderTests: XCTestCase {

    func test_fetchEvents_returnsValidNumberOfEvents() {
        let sut = makeSUT()

        let exp = expectation(description: "Fetch Events")
        sut.fetchEvents { result in
            switch result {
            case let .success(events):
                XCTAssertGreaterThan(events.count, 0)
            case let .failure(error):
                XCTAssertNotNil(error)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_loadEvents_returnsValidNumberOfCellViewModels() {
        let sut = EventListViewModel(eventsLoader: EventsLoader())
        let exp = expectation(description: "Load Events")

        sut.loadEvents { events in
            exp.fulfill()
            XCTAssertGreaterThan(events.currentEvents.count, 0)
        }
        wait(for: [exp], timeout: 10.0)
    }
    
    func test_SearchEvents_returnsValidNumberOfCellViewModels() {
        let sut = EventListViewModel(eventsLoader: EventsLoader())
        let exp = expectation(description: "Search Events")
        
        sut.searchEvents(keyword: "test 3") { events in
            exp.fulfill()
            XCTAssertGreaterThan(events.currentEvents.count, 0)
        }
        
        wait(for: [exp], timeout: 10.0)
    }
    
    // MARK: - Helpers
    private func makeSUT() -> EventsLoader {
        let sut = EventsLoader()
        return sut
    }

    private func checkForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
