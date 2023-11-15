//
//  Lines.swift
//  RCRC
//
//  Created by Errol on 08/01/21.
//

import UIKit

class Line: UIView {

    var color: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let constraints = [NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 3)]
        self.addConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.bounds.midX, y: self.bounds.minY))
        path.addLine(to: CGPoint(x: self.bounds.midX, y: self.bounds.maxY))
        path.lineWidth = 3.0
        color?.setStroke()
        path.stroke()
    }
}

class DottedLine: UIView {

    var color: UIColor? {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let constraints = [NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 3)]
        self.addConstraints(constraints)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        let  path = UIBezierPath()
        let  p0 = CGPoint(x: self.bounds.midX, y: self.bounds.minY)
        path.move(to: p0)
        let  p1 = CGPoint(x: self.bounds.midX, y: self.bounds.maxY)
        path.addLine(to: p1)
        let  dashes: [ CGFloat ] = [ 0.0, 10.0 ]
        path.setLineDash(dashes, count: dashes.count, phase: 0.0)
        path.lineWidth = 5.0
        path.lineCapStyle = .round
        color?.setStroke()
        path.stroke()
    }
}
