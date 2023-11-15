//
//  SearchPreferencesTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 17/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class SearchPreferencesTests: XCTestCase {
	func test_availabilityContains_Now_Leave_Arrive() {
		let sut = SearchPreference()

		XCTAssertEqual(sut.mainOptions[0].value, "Now")
		XCTAssertEqual(sut.mainOptions[1].value, "Leave")
		XCTAssertEqual(sut.mainOptions[2].value, "Arrive")
	}

	func test_availabiltyOptions_hasOnlyNowOptionSelectedByDefault() {
		let sut = SearchPreference()

		let selectedOption = sut.mainOptions.filter { $0.isSelected }

		XCTAssertEqual(selectedOption.count, 1)
		XCTAssertEqual(selectedOption.first?.value, "Now")
	}

	func test_availabiltyOptions_hasOnlyOneOptionSelectedBeforeAndAfterSelection() {
		let sut = SearchPreference()

		XCTAssertEqual(sut.getSelectedMainOption().count, 1)

		sut.selectMainOption(at: 0)
		XCTAssertEqual(sut.getSelectedMainOption().count, 1)

		sut.selectMainOption(at: 1)
		XCTAssertEqual(sut.getSelectedMainOption().count, 1)

		sut.selectMainOption(at: 2)
		XCTAssertEqual(sut.getSelectedMainOption().count, 1)

		sut.selectMainOption(at: 0)
		XCTAssertEqual(sut.getSelectedMainOption().count, 1)
	}

	func test_selectMainOption_deliversSelectedOptionWithDefaultAsNow() {
		let sut = SearchPreference()

		XCTAssertEqual(sut.selectedMainOption.value, "Now")

		sut.selectMainOption(at: 1)
		XCTAssertEqual(sut.selectedMainOption.value, "Leave")

		sut.selectMainOption(at: 2)
		XCTAssertEqual(sut.selectedMainOption.value, "Arrive")

		sut.selectMainOption(at: 0)
		XCTAssertEqual(sut.selectedMainOption.value, "Now")
	}

	func test_selectDate_deliversSelectedDateWithDefaultDateAsCurrentDate() {
		let sut = SearchPreference()
		let fixedCurrentDate = Date()

		XCTAssertEqual(sut.selectedDate.value.dateString, fixedCurrentDate.dateString)

		sut.selectDate(at: 1)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedCurrentDate.getFutureDate(after: 1).dateString)

		sut.selectDate(at: 2)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedCurrentDate.getFutureDate(after: 2).dateString)

		sut.selectDate(at: 3)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedCurrentDate.getFutureDate(after: 3).dateString)

		sut.selectDate(at: 4)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedCurrentDate.getFutureDate(after: 4).dateString)
	}

	func test_selectTime_deliversSelectedHourAndMinuteWithDefaultAs00() {
		let sut = SearchPreference()
		let fixedDate = Date().getFutureDate(after: 1)

		XCTAssertEqual(sut.selectedHour.value, fixedDate.getHour().string)
		XCTAssertEqual(sut.selectedMinute.value, fixedDate.getMinute().string)

		sut.selectDate(at: 1)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedDate.dateString)

		sut.selectHour(at: 0)
		XCTAssertEqual(sut.selectedHour.value, "0")

		sut.selectMinute(at: 2)
		XCTAssertEqual(sut.selectedMinute.value, "10")
	}

	func test_selectPreference_deliversSelectedPreferences() {
		let sut = SearchPreference()
		let fixedDate = Date()

		sut.selectMainOption(at: 1)
		XCTAssertEqual(sut.selectedMainOption.value, "Leave")

		if fixedDate.getHour() < 23, fixedDate.getMinute() < 55 {
			sut.selectDate(at: 0)
			XCTAssertEqual(sut.selectedDate.value.dateString, fixedDate.dateString)

			sut.selectHour(at: 0)
			XCTAssertEqual(sut.selectedHour.value, fixedDate.getHour().string)

			sut.selectMinute(at: 0)
			XCTAssertEqual(sut.selectedMinute.value, (fixedDate.getMinute() ..< 60).filter { $0 % 5 == 0 }.first?.string)
		}

		sut.selectDate(at: 1)
		XCTAssertEqual(sut.selectedDate.value.dateString, fixedDate.getFutureDate(after: 1).dateString)

		sut.selectHour(at: 10)
		XCTAssertEqual(sut.selectedHour.value, "10")

		sut.selectMinute(at: 6)
		XCTAssertEqual(sut.selectedMinute.value, "30")

		XCTAssertEqual(sut.selectedPreferences.availability, "Leave")
		XCTAssertEqual(sut.selectedPreferences.date.dateString, fixedDate.getFutureDate(after: 1).dateString)
		XCTAssertEqual(sut.selectedPreferences.hour, "10")
		XCTAssertEqual(sut.selectedPreferences.minute, "30")
	}
}

// MARK: - Helpers

private extension SearchPreference {
	func getSelectedMainOption() -> [Option<String>] {
		return self.mainOptions.filter { $0.isSelected }
	}
}

private extension Date {
	func getFutureDate(after days: Int) -> Date {
		let calendar = Calendar(identifier: .gregorian)
		return calendar.date(byAdding: .day, value: days, to: self)!
	}

	func getHour() -> Int {
		let calendar = Calendar(identifier: .gregorian)
		return calendar.component(.hour, from: self)
	}

	func getMinute() -> Int {
		let calendar = Calendar(identifier: .gregorian)
		return calendar.component(.minute, from: self)
	}
}
