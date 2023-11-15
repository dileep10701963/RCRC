//
//  SearchPreference.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 17/06/21.
//

import Foundation

final class SearchPreference {
	var mainOptions: [Option<String>] = [
		Option(isSelected: true, value: Constants.now),
		Option(isSelected: false, value: Constants.leave),
		Option(isSelected: false, value: Constants.arrive)
	]
	var dateOptions: [Option<Date>] = Utilities.DateTime.fetchFiveDatesFromNow().map { Option(isSelected: false, value: $0) }
	var hourOptions: [Option<String>] = []
	var minuteOptions: [Option<String>] = []

	var selectedMainOption: Option<String> {
		return mainOptions.filter { $0.isSelected }.first ?? Option(isSelected: true, value: Constants.now)
	}

	var selectedDate: Option<Date> {
		return dateOptions.filter { $0.isSelected }.first ?? Option(isSelected: true, value: Date())
	}

	var selectedHour: Option<String> {
		return hourOptions.filter { $0.isSelected }.first ?? Option(isSelected: true, value: Date().hour.string)
	}

	var selectedMinute: Option<String> {
		return minuteOptions.filter { $0.isSelected }.first ?? Option(isSelected: true, value: Date().minute.string)
	}

	private func makeHourOptions(date: Date) -> [Option<String>] {
		let calendar = Calendar(identifier: .gregorian)
		let currentHour = calendar.component(.hour, from: date)

		if date.dateString == Date().dateString {
			return (currentHour ..< 24)
				.map { Option(isSelected: false, value: $0.string) }
		}
		return (0 ..< 24)
			.map { Option(isSelected: false, value: $0.string) }
	}

	private func makeMinuteOptions(hour: Int, date: Date) -> [Option<String>] {
		let calendar = Calendar(identifier: .gregorian)
		let currentHour = calendar.component(.hour, from: date)
		let currentMinute = calendar.component(.minute, from: date)

		if currentHour == hour {
			return (currentMinute ..< 60)
				.filter { $0 % 5 == 0 }
				.map { Option(isSelected: false, value: $0.string) }
		}
		return (0 ..< 60)
			.filter { $0 % 5 == 0 }
			.map { Option(isSelected: false, value: $0.string) }
	}

	private func reset() {
		dateOptions = dateOptions.map { Option(isSelected: false, value: $0.value) }
		hourOptions = []
		minuteOptions = []
	}

	func selectMainOption(at index: Int) {
		mainOptions = mainOptions.map { Option(isSelected: false, value: $0.value) }
		mainOptions[index].isSelected = true
		if index == 0 {
			reset()
		}
	}

	func selectDate(at index: Int) {
		dateOptions = dateOptions.map { Option(isSelected: false, value: $0.value) }
		dateOptions[index].isSelected = true
		hourOptions = makeHourOptions(date: dateOptions[index].value)
	}

	func selectHour(at index: Int) {
		hourOptions = hourOptions.map { Option(isSelected: false, value: $0.value) }
		hourOptions[index].isSelected = true
		minuteOptions = makeMinuteOptions(hour: hourOptions[index].value.toInt(),
		                                  date: selectedDate.value)
	}

	func selectMinute(at index: Int) {
		minuteOptions = minuteOptions.map { Option(isSelected: false, value: $0.value) }
		minuteOptions[index].isSelected = true
	}

	var selectedPreferences: SelectedSearchPreferences {
		SelectedSearchPreferences(availability: selectedMainOption.value,
		                          date: selectedDate.value,
		                          hour: selectedHour.value,
		                          minute: selectedMinute.value)
	}

	struct Option<T> {
		var isSelected: Bool
		var value: T
	}
}
