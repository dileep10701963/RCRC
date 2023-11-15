//
//  NewsModuleTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 02/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class NewsModuleTests: XCTestCase {

    func test_NewsResultIsEmptyOnInitialization() {
        let sut = makeSUT()
        XCTAssertNil(sut.newsResult.value)
    }

    func test_NewsResultOnSuccess_returnsNewsResult() {
        let sut = makeSUT()
        let exp = expectation(description: "Fetch Latest News from API")

        sut.fetchNews()
        sut.newsResult.bind { response, error in
            if response == nil && error == nil {}
            else {
                XCTAssertGreaterThanOrEqual(sut.newsResult.value?.count ?? 0, 0)
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 20.0)
    }

    func test_newsCount_returnsValidCount() {
        let sut = makeSUT()
        let exp = expectation(description: "Check news count")

        sut.fetchNews { [weak sut] in
            let newCount = sut?.newsCount
            XCTAssertGreaterThanOrEqual(newCount ?? -1, 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_getNewsAtInvalidIndex_returnsNil() {
        let sut = makeSUT()
        let exp = expectation(description: "News at invalid index")

        sut.fetchNews { [weak sut] in
            XCTAssertNil(sut?.fetchNews(index: 20))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_getNewsAtValidIndex_returnsNewsModel() {
        let sut = makeSUT()
        let exp = expectation(description: "News at valid index")

        sut.fetchNews { [weak sut] in
            XCTAssertNotNil(sut?.fetchNews(index: 1))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_ImageCache_hasDifferentInstancesAndHashValuesForDifferentURLs() {
        let news1 = NewsImageCache(url: NSURL(string: "https://www.any-url1.com")!)
        let news2 = NewsImageCache(url: NSURL(string: "https://www.any-url2.com")!)

        XCTAssertNotEqual(news1.hashValue, news2.hashValue)
        XCTAssertNotEqual(news1, news2)
    }

    
    // MARK: - Helpers
    private func makeSUT() -> NewsViewModel {
        let sut = NewsViewModel()
        checkForMemoryLeak(sut)
        return sut
    }

    private func checkForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
