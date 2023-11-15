//
//  EventTableViewCell.swift
//  RCRC
//
//  Created by pcadmin on 23/06/21.
//

import UIKit
import GoogleMaps

class EventTableViewCell: UITableViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var eventDuration: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventCostView: UIView!
    @IBOutlet weak var eventCost: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var durationIcon: UIImageView!
    private var viewModel: EventCellViewModel?

    var readMoreTapped: ((EventCellViewModel) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        maskEventCostView()
    }

    func initialize(with viewModel: EventCellViewModel) {
        self.viewModel = viewModel
        let isLocationInvalid = viewModel.distance == nil || viewModel.address == nil
        locationIcon.isHidden = isLocationInvalid
        distanceLabel.text = viewModel.distance
        eventAddress.text = viewModel.address
        eventName.text = viewModel.name.localized
        eventDuration.attributedText = viewModel.duration
        eventCost.attributedText = viewModel.entryFee
        eventDescription.text = viewModel.description

        viewModel.getAddress { [weak self] address in
            self?.locationIcon.isHidden = address == nil
            self?.eventAddress.text = address
        }

        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            viewModel.getDistance(from: location?.coordinate) { [weak self] distance in
                self?.updateDistance(distance)
            }
        }

        viewModel.loadImage { [weak self] image in
            self?.eventImage.image = image
        }
    }

    private func updateDistance(_ distance: String?) {
        DispatchQueue.main.async {
            if let distance = distance {
                self.distanceLabel.text = "Apprx. " + distance
            } else {
                self.distanceLabel.text = nil
            }
        }
    }

    private func configureView() {
        footerView.backgroundColor = Colors.tableViewHeader
    }

    private func maskEventCostView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: eventCostView.bounds.minX, y: eventCostView.bounds.maxY))
        path.addLine(to: CGPoint(x: eventCost.frame.minX - 5, y: eventCostView.bounds.minY))
        path.addLine(to: CGPoint(x: eventCostView.bounds.maxX, y: eventCostView.bounds.minY))
        path.addLine(to: CGPoint(x: eventCostView.bounds.maxX, y: eventCostView.bounds.maxY))
        path.addLine(to: CGPoint(x: eventCostView.bounds.minX, y: eventCostView.bounds.maxY))
        path.close()

        let mask = CAShapeLayer()
        mask.fillColor = UIColor.red.cgColor
        mask.path = path.cgPath

        eventCostView.layer.mask = mask
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    @IBAction func readMoreTapped(_ sender: UIButton) {
        guard let viewModel = self.viewModel else { return }
        readMoreTapped?(viewModel)
    }
}
