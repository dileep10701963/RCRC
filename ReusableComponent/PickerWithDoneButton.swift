//
//  PickerWithDoneButton.swift
//  RCRC
//
//  Created by Errol on 27/04/21.
//

import UIKit

protocol PickerWithDoneButtonDelegate: AnyObject {
    func tappedOnShadow()
    func doneTapped(at index: Int?, value: String?)
}

extension PickerWithDoneButtonDelegate {
    func tappedOnShadow() {}
    func doneTapped(at index: Int?, value: String?) {}
}

// Reusable Picker view with table view and done button.
/// Accepts data in [String] format and includes an initial selected index.
class PickerWithDoneButton: UIView {

    private var selected: Int
    weak var delegate: PickerWithDoneButtonDelegate?
    private var pickerData: [String]
    private var showDatePicker: Bool = false
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
        button.backgroundColor = Colors.newGreen
        button.setTitle("Done".localized, for: .normal)
        button.titleLabel?.font = Fonts.RptaSignage.eighteen
        button.cornerRadius = 10
        return button
    }()

    private var heightConstraint: NSLayoutConstraint?
    var viewHeight: CGFloat?

    required init(pickerData: [String] = [], selected: Int = 0, showDatePicker: Bool = false) {
        self.pickerData = pickerData
        self.selected = selected
        self.showDatePicker = showDatePicker
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
        tableView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: showDatePicker ? 10: 20).isActive = true
        tableView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: showDatePicker ? -10: -20).isActive = true
        heightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        heightConstraint?.isActive = true
        addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
        doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: showDatePicker ? 10: 20).isActive = true
        doneButton.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: showDatePicker ? 10: 20).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: showDatePicker ? -10: -20).isActive = true
        doneButton.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: showDatePicker ? -10: -20).isActive = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.cornerRadius = 10
        tableView.register(DatePickerButtonCell.self, forCellReuseIdentifier: "DatePickerButtonCell")
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: "DatePickerCell")
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
        return self.showDatePicker ? 2 : pickerData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch showDatePicker {
        case true:
            switch indexPath.row {
            case 0:
                let cell: DatePickerButtonCell = tableView.dequeue(cellForRowAt: indexPath)
                return cell
            default:
                let cell: DatePickerCell = tableView.dequeue(cellForRowAt: indexPath)
                return cell
            }
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.backgroundColor = Colors.pickerBackground
            cell.textLabel?.font = Fonts.CodecRegular.sixteen//RptaSignage.eighteen
            cell.textLabel?.text = pickerData[indexPath.row].localized
            if selected != -1, selected == indexPath.row {
                cell.imageView?.image = Images.greenFilledCircle//checked
            } else {
                cell.imageView?.image = Images.greenCircle //unchecked
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selected = -1
        tableView.reloadData()
        let cell = tableView.cellForRow(at: indexPath)
        cell?.imageView?.image = Images.greenFilledCircle//checked
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
