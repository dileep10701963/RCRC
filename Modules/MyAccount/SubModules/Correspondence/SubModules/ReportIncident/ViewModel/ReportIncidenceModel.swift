//
//  ReportIncidenceModel.swift
//  RCRC
//
//  Created by anand madhav on 09/08/20.
//

import Foundation
import UIKit

// Added from WalkRouteTableViewCell.swift
enum NumberConstant {
    static let leftPadding = 27.5
    static let topPadding = 10
    static let strokeLength = 5
    static let gapLength = 4
    static let width = 3
    static let heightAnchor = 35
    static let travelModeImageWidth = 30
    static let bottomCircleConstraint = 8
    static let bottomTravelImageViewConstraint = 3
    static let borderWidth = 2
    static let distanceLabelTopConstraint = 15
    static let topFourtyPadding = 40
    static let topTwentyPadding = 20
    static let widthConstraintPadding = 22
    static let distanceLabelConstraint = 37.5
}

class ReportIncidenceModel: NSObject {

    func addShadowForView(views: [UIView]) {
        for view in views {
            view.layer.cornerRadius = CGFloat(NumberConstant.topPadding)
            view.layer.borderColor = Colors.reportIncidenceLightGray.cgColor
            view.layer.borderWidth = CGFloat(NumberConstant.borderWidth)
            view.layer.masksToBounds = true
        }
    }

    func makeBackgroundCircle(views: [UIView]) {
        for view in views {
            view.layer.cornerRadius = view.frame.size.width/CGFloat(NumberConstant.borderWidth)
            view.layer.masksToBounds = true
        }
    }

    func setBorderColor(views: [UIView]) {
        for view in views {
            view.layer.borderWidth = CGFloat(NumberConstant.borderWidth)
            view.layer.masksToBounds = true
            view.layer.cornerRadius = CGFloat(NumberConstant.strokeLength)
            view.layer.borderColor = Colors.dialogBackground.cgColor
        }
    }
}
