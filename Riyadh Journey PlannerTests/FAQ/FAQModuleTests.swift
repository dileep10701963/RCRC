//
//  FAQModuleTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 01/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class FAQModuleTests: XCTestCase {

    func test_FaqAPI_returnsValidResponse() {
        let sut = FrequentlyAskedQuestionViewModel()
        let exp = expectation(description: "Fetch FAQs from API")

        sut.getFAQ {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_calculateNumberOfFAQs_returnsValidNumberOfFAQs() {

        let sut = FrequentlyAskedQuestionViewModel()
        let exp = expectation(description: "Fetch FAQs from API")

        sut.getFAQ {
            XCTAssertEqual(sut.numberOfSection(), 5)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_methodSetQuestionText_returnsValidFAQQuestion() {
        let sut = FrequentlyAskedQuestionViewModel()
        let exp = expectation(description: "Fetch FAQs from API")
        let indexPath = IndexPath(row: 0, section: 0)

        sut.getFAQ {
            XCTAssertEqual(sut.setQuestionText(indexPath: indexPath), "How do I add money to my bus card from within the app?")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }

    func test_methodSetAnswerText_returnsValidFAQAnswer() {
        let sut = FrequentlyAskedQuestionViewModel()
        let exp = expectation(description: "Fetch FAQs from API")
        let indexPath = IndexPath(row: 0, section: 0)

        sut.getFAQ {
            //XCTAssertEqual(sut.setAnswerText(indexPath: indexPath), "Put money on your Hop card anywhere, anytime, using the Hop website, app ... Cards are available at Fred Meyer, Safeway and Plaid Pantry stores, plus many more. ... at a ticket machine, boarding a bus, or at your transit agency's ticket office.")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
    }
}
