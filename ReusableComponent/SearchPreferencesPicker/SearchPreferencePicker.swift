//
//  SearchPreferencePicker.swift
//  RCRC
//
//  Created by Errol on 16/03/21.
//

import UIKit

class SearchPreferencePicker: NSObject, UIGestureRecognizerDelegate {
	var tapGesture = UITapGestureRecognizer()
	var tableView = UITableView()
	var shadowView = UIView()
	var tableViewHeight = Constants.searchPreferencePickerHeight

	func show(superview: UIView, for button: UIButton) {
		tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
		tapGesture.delegate = self
		showShadow(for: superview)
		showTableView(below: button)
	}

	fileprivate func showTableView(below button: UIButton) {
		tableView.register(SearchPreferenceTableViewCell.nib, forCellReuseIdentifier: SearchPreferenceTableViewCell.identifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.layer.cornerRadius = 10
		tableView.tableFooterView = UIView()
		shadowView.addSubview(tableView)
		tableView.topAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
		tableView.leadingAnchor.constraint(equalTo: button.leadingAnchor).isActive = true
		tableView.trailingAnchor.constraint(equalTo: button.trailingAnchor).isActive = true
		tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
	}

	fileprivate func showShadow(for superview: UIView) {
		shadowView.backgroundColor = Colors.shadowGray
		shadowView.translatesAutoresizingMaskIntoConstraints = false
		shadowView.addGestureRecognizer(tapGesture)
		superview.addSubview(shadowView)
		shadowView.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
		shadowView.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
		shadowView.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
		shadowView.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
	}

	@objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
		if sender.view == shadowView {
			hide()
		}
	}

	func hide() {
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.5) {
				self.shadowView.removeFromSuperview()
				self.tableView.removeFromSuperview()
				self.tapGesture.removeTarget(self, action: nil)
			}
		}
	}

	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		guard let view = touch.view else { return true }
		if view.isDescendant(of: tableView) {
			return false
		} else {
			return true
		}
	}
}
