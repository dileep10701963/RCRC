//
//  Legs.swift
//  RCRC
//
//  Created by Errol on 08/01/21.
//

import UIKit

class InitialFilledLeg: UIView {

    var filledCircle = FilledCircle()
    var line = Line()
    var circle = Circle()

    var circleColor: UIColor? {
        didSet {
            circle.color = circleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            line.color = color
            filledCircle.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        addSubview(filledCircle)
        addSubview(circle)
        let constraints = [NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: filledCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: circle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: circle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: circle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class InitialDottedLeg: UIView {

    var filledCircle = FilledCircle()
    var dottedLine = DottedLine()
    var circle = Circle()

    var circleColor: UIColor? {
        didSet {
            circle.color = circleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            filledCircle.color = color
            dottedLine.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dottedLine)
        addSubview(filledCircle)
        addSubview(circle)
        let constraints = [NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .top, relatedBy: .equal, toItem: filledCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .bottom, relatedBy: .equal, toItem: circle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: circle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: circle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class SingleDottedLeg: UIView {

    var filledCircle = FilledCircle()
    var dottedLine = DottedLine()
    var secondFilledCircle = FilledCircle()

    var color: UIColor? {
        didSet {
            filledCircle.color = color
            dottedLine.color = color
            secondFilledCircle.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dottedLine)
        addSubview(filledCircle)
        addSubview(secondFilledCircle)
        let constraints = [NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .top, relatedBy: .equal, toItem: filledCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .bottom, relatedBy: .equal, toItem: secondFilledCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: secondFilledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: secondFilledCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class SingleFilledLeg: UIView {

    var filledCircle = FilledCircle()
    var line = Line()
    var secondFilledCircle = FilledCircle()

    var color: UIColor? {
        didSet {
            filledCircle.color = color
            line.color = color
            secondFilledCircle.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        addSubview(filledCircle)
        addSubview(secondFilledCircle)
        let constraints = [NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: filledCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: secondFilledCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: secondFilledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: secondFilledCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class FinalFilledLeg: UIView {

    var circle = Circle()
    var line = Line()
    var filledCircle = FilledCircle()

    var circleColor: UIColor? {
        didSet {
            circle.color = circleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            line.color = color
            filledCircle.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        addSubview(filledCircle)
        addSubview(circle)
        let constraints = [NSLayoutConstraint(item: circle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: circle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: circle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: filledCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class FinalDottedLeg: UIView {

    var circle = Circle()
    var dottedLine = DottedLine()
    var filledCircle = FilledCircle()

    var circleColor: UIColor? {
        didSet {
            circle.color = circleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            filledCircle.color = color
            dottedLine.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dottedLine)
        addSubview(filledCircle)
        addSubview(circle)
        let constraints = [NSLayoutConstraint(item: circle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: circle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .top, relatedBy: .equal, toItem: circle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .bottom, relatedBy: .equal, toItem: filledCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: filledCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class IntermediateFilledLeg: UIView {

    var topCircle = Circle()
    var line = Line()
    var bottomCircle = Circle()

    var topCircleColor: UIColor? {
        didSet {
            topCircle.color = topCircleColor
            setNeedsLayout()
        }
    }

    var bottomCircleColor: UIColor? {
        didSet {
            bottomCircle.color = bottomCircleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            line.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(line)
        addSubview(bottomCircle)
        addSubview(topCircle)
        let constraints = [NSLayoutConstraint(item: topCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: topCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: line, attribute: .top, relatedBy: .equal, toItem: topCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: line, attribute: .bottom, relatedBy: .equal, toItem: bottomCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: bottomCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: bottomCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

class IntermediateDottedLeg: UIView {

    var topCircle = Circle()
    var dottedLine = DottedLine()
    var bottomCircle = Circle()

    var topCircleColor: UIColor? {
        didSet {
            topCircle.color = topCircleColor
            setNeedsLayout()
        }
    }

    var bottomCircleColor: UIColor? {
        didSet {
            bottomCircle.color = bottomCircleColor
            setNeedsLayout()
        }
    }

    var color: UIColor? {
        didSet {
            dottedLine.color = color
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dottedLine)
        addSubview(bottomCircle)
        addSubview(topCircle)
        let constraints = [NSLayoutConstraint(item: topCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: topCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .top, relatedBy: .equal, toItem: topCircle, attribute: .bottom, multiplier: 1.0, constant: -1.0),
                           NSLayoutConstraint(item: dottedLine, attribute: .bottom, relatedBy: .equal, toItem: bottomCircle, attribute: .top, multiplier: 1.0, constant: 1.0),
                           NSLayoutConstraint(item: bottomCircle, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0),
                           NSLayoutConstraint(item: bottomCircle, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
        addConstraints(constraints)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
