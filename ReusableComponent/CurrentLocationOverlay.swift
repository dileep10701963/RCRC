//
//  CurrentLocationOverlay.swift
//  RCRC
//
//  Created by Errol on 28/04/21.
//

import UIKit

protocol CurrentLocationOverlayDelegate: AnyObject {
    func yourCurrentLocationTapped()
    func selectLocationOnMapTapped()
    func shadowTapped()
}

extension CurrentLocationOverlayDelegate {
    func yourCurrentLocationTapped() {}
    func selectLocationOnMapTapped() {}
    func shadowTapped() {}
}

class CurrentLocationOverlay: UIView {

    weak var delegate: CurrentLocationOverlayDelegate?

    private let shadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.shadowGray
        view.layer.opacity = 0.5
        return view
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.white.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        return view
    }()

    private let yourCurrentLocationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Fonts.RptaSignage.eighteen
        button.tintColor = Colors.green
        button.setImage(Images.useCurrentLocation, for: .normal)
        button.setTitle("Use Current Location".localized, for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.semanticContentAttribute = (currentLanguage == Languages.english) ? .forceRightToLeft : .forceLeftToRight
        return button
    }()

    private let selectLocationOnMapButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = Fonts.RptaSignage.eighteen
        button.tintColor = Colors.green
        button.setImage(Images.menuPlanATripGreen, for: .normal)
        button.setTitle("Select Location From Map".localized, for: .normal)
        button.setTitleColor(Colors.green, for: .normal)
        button.semanticContentAttribute = (currentLanguage == Languages.english) ? .forceRightToLeft : .forceLeftToRight
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addSubview(shadowView)
        shadowView.pinEdgesToSuperView()
        shadowView.addGestureRecognizer(tapGesture)

        addSubview(overlayView)
        addSubview(yourCurrentLocationButton)
        addSubview(selectLocationOnMapButton)

        overlayView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor).isActive = true

        yourCurrentLocationButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 30).isActive = true
        yourCurrentLocationButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true

        selectLocationOnMapButton.topAnchor.constraint(equalTo: yourCurrentLocationButton.bottomAnchor, constant: 20).isActive = true
        selectLocationOnMapButton.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor).isActive = true
        selectLocationOnMapButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -30).isActive = true

        yourCurrentLocationButton.addTarget(self, action: #selector(yourCurrentLocationTapped), for: .touchUpInside)
        selectLocationOnMapButton.addTarget(self, action: #selector(selectLocationFromMapTapped), for: .touchUpInside)
    }

    @objc private func yourCurrentLocationTapped() {
        delegate?.yourCurrentLocationTapped()
    }

    @objc private func selectLocationFromMapTapped() {
        delegate?.selectLocationOnMapTapped()
    }

    @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
        if sender.view == shadowView {
            delegate?.shadowTapped()
        }
    }
}
