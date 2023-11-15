//
//  ReportPicker.swift
//  RCRC
//
//  Created by Errol on 27/04/21.
//

import UIKit

protocol ReportPickerDelegate: AnyObject {
    func tappedOnShadow()
    func doneTapped(at index: Int?, value: String?)
}

extension ReportPickerDelegate {
    func tappedOnShadow() {}
    func doneTapped(at index: Int?, value: String?) {}
}

/// Reusable Picker view with table view and done button.
class PickerWithDoneButton: UIView {

    private var selected: Int
    weak var delegate: ReportPickerDelegate?
    private var pickerData: [String]
    private var selectedData: (Int?, String?)
    var tableViewHeight: CGFloat {
        if let viewHeight = self.viewHeight, tableView.contentSize.height > viewHeight {
            return viewHeight
        } else {
            return tableView.contentSize.height
        }
    }

    private let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.shadowGray
        view.layer.opacity = 0.5
        return view
    }()

    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = Colors.green
        button.setTitle("Done".localized, for: .normal)
        button.titleLabel?.font = Fonts.RptaSignage.eighteen
        button.cornerRadius = 10
        return button
    }()

    private var heightConstraint: NSLayoutConstraint?
    var viewHeight: CGFloat?

    required init(pickerData: [String], selected: Int) {
        self.pickerData = pickerData
        self.selected = selected
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGesture.delegate = self
        addSubview(shadowView)
        shadowView.pinEdgesToSuperView()
        shadowView.addGestureRecognizer(tapGesture)
        addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -20).isActive = true
        heightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        heightConstraint?.isActive = true
        addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
        doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 20).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: -20).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: -20).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.cornerRadius = 10
        DispatchQueue.main.async {
            self.heightConstraint?.constant = CGFloat.greatestFiniteMagnitude
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.heightConstraint?.constant = self.tableViewHeight
        }
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.view == shadowView {
            delegate?.tappedOnShadow()
        }
    }

    @objc private func doneTapped(_ sender: UIButton) {
        if selectedData.0 == nil {
            delegate?.doneTapped(at: selected, value: selectedData.1)
        } else {
            delegate?.doneTapped(at: self.selectedData.0, value: self.selectedData.1)
        }
    }
}

extension PickerWithDoneButton: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = Fonts.RptaSignage.eighteen
        cell.textLabel?.text = pickerData[indexPath.row]
        if selected != -1, selected == indexPath.row {
            cell.imageView?.image = Images.checked
        } else {
            cell.imageView?.image = Images.unchecked
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selected = -1
        tableView.reloadData()
        let cell = tableView.cellForRow(at: indexPath)
        cell?.imageView?.image = Images.checked
        self.selectedData = (indexPath.row, pickerData[indexPath.row])
    }
}

extension PickerWithDoneButton: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: tableView) {
            return false
        } else {
            return true
        }
    }
}
