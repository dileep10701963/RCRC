//
//  Circles.swift
//  RCRC
//
//  Created by Errol on 08/01/21.
//

import UIKit
let circleSize: CGFloat = 14

class Circle: UIView {

    var color: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let constraints = [NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: circleSize),
                           NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: circleSize)]
        self.addConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        layer.borderColor = color?.cgColor
        layer.borderWidth = 2.0
        layer.cornerRadius = self.frame.size.width/2
    }
}

class FilledCircle: UIView {

    var color: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let constraints = [NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: circleSize),
                           NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: circleSize)]
        self.addConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: self.bounds.width/2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = color?.cgColor
        shapeLayer.strokeColor = color?.cgColor
        shapeLayer.lineWidth = 0.0
        self.layer.addSublayer(shapeLayer)
    }
}
