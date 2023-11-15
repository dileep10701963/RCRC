//
//  SearchPreferenceDataSource.swift
//  RCRC
//
//  Created by Errol on 03/11/20.
//

import Foundation
import UIKit

protocol SearchPreferenceDelegate: AnyObject {
	func didSelectPreference(preference: SearchPreferences, value: String)
	func didSelect(preferences: SearchPreference)
}

final class SearchPreferenceDataSource: NSObject {
	let searchPreferenceData: SearchPreference
	var searchPreference: SearchPreferences?
	weak var delegate: SearchPreferenceDelegate?

	init(searchPreferences: SearchPreference) {
		self.searchPreferenceData = searchPreferences
	}
}

extension SearchPreferenceDataSource: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch self.searchPreference {
		case .mainOption:
			return searchPreferenceData.mainOptions.count
		case .date:
			return searchPreferenceData.dateOptions.count
		case .hour:
			return searchPreferenceData.hourOptions.count
		case .minute:
			return searchPreferenceData.minuteOptions.count
		default:
			return 0
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: SearchPreferenceTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
		switch self.searchPreference {
		case .mainOption:
			cell.isChecked = searchPreferenceData.mainOptions[indexPath.row].isSelected
			cell.preferenceLabel.text = searchPreferenceData.mainOptions[indexPath.row].value
		case .date:
			cell.isChecked = searchPreferenceData.dateOptions[indexPath.row].isSelected
			cell.preferenceLabel.text = searchPreferenceData.dateOptions[indexPath.row].value.date
		case .hour:
			cell.isChecked = searchPreferenceData.hourOptions[indexPath.row].isSelected
			cell.preferenceLabel.text = searchPreferenceData.hourOptions[indexPath.row].value
		case .minute:
			cell.isChecked = searchPreferenceData.minuteOptions[indexPath.row].isSelected
			cell.preferenceLabel.text = searchPreferenceData.minuteOptions[indexPath.row].value
		default:
			cell.preferenceLabel.text = emptyString
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch searchPreference {
		case .mainOption:
			searchPreferenceData.selectMainOption(at: indexPath.row)
			delegate?.didSelectPreference(preference: .mainOption,
			                              value: searchPreferenceData.mainOptions[indexPath.row].value)
		case .date:
			searchPreferenceData.selectDate(at: indexPath.row)
			delegate?.didSelectPreference(preference: .date,
			                              value: searchPreferenceData.dateOptions[indexPath.row].value.date)
		case .hour:
			searchPreferenceData.selectHour(at: indexPath.row)
			delegate?.didSelectPreference(preference: .hour,
			                              value: searchPreferenceData.hourOptions[indexPath.row].value)
		case .minute:
			searchPreferenceData.selectMinute(at: indexPath.row)
			delegate?.didSelectPreference(preference: .minute,
			                              value: searchPreferenceData.minuteOptions[indexPath.row].value)
		default:
			return
		}
		delegate?.didSelect(preferences: searchPreferenceData)
		tableView.reloadData()
	}
}
