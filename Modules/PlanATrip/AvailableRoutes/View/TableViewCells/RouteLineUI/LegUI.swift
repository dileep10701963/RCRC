//
//  LegUI.swift
//  RCRC
//
//  Created by Errol on 08/03/21.
//

import UIKit

enum RouteType: String {
    case footpath = "footpath", bus = "Bus", cycling = "Fahrrad", taxi = "Taxi"

    init(rawValue: String) {
        switch rawValue {
        case "footpath": self = .footpath
        case "Bus": self = .bus
        case "Fahrrad": self = .cycling
        case "Taxi": self = .taxi
        default:
            self = .bus
        }
    }
}

enum LegPosition {
    case origin
    case intermediate
    case destination
    case single
}

struct StopData {

    var originName: String?
    var originAddress: String?
    var destinationName: String?
    var destinationAddress: String?
    var time: String?
    var mode: RouteType
}

class LegUI: UIView {

    var lineColor: UIColor?
    var originColor: UIColor?
    var destinationColor: UIColor?
    var lineType: RouteType?
    var legPosition: LegPosition?

    init(frame: CGRect = .zero, dottedLine color: UIColor, origin: (UIColor, UIImage), destination: (UIColor, UIImage)) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        let originCircle = UIImageView(image: origin.1)
        let destinationCircle = UIImageView(image: destination.1)
        let line = DottedLine()
        originCircle.translatesAutoresizingMaskIntoConstraints = false
        destinationCircle.translatesAutoresizingMaskIntoConstraints = false
        originCircle.tintColor = origin.0
        line.color = Colors.rptGreen//color
        destinationCircle.tintColor = destination.0
        self.addSubviews([line, originCircle, destinationCircle])
        self.configureConstraints(originCircle, line, destinationCircle)
    }

    init(frame: CGRect = .zero, solidLine color: UIColor, origin: (UIColor, UIImage), destination: (UIColor, UIImage), stopsSequenceCount: Int = 0, isExpanded: Bool = false, viewPosition: [CGFloat]) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        let originCircle = UIImageView(image: origin.1)
        let destinationCircle = UIImageView(image: destination.1)
        let line = Line()

        originCircle.translatesAutoresizingMaskIntoConstraints = false
        destinationCircle.translatesAutoresizingMaskIntoConstraints = false
        originCircle.tintColor = origin.0
        line.color = Colors.rptGreen//color
        destinationCircle.tintColor = destination.0
        
        let tempView = UIImageView()
        var arrayOfViews: [UIView] = []
        var stopViews: [UIView] = []
        arrayOfViews = [line, originCircle, destinationCircle, tempView]
        
        if isExpanded && stopsSequenceCount > 0 {
            for _ in 0 ..< stopsSequenceCount {
                let tempView = UIImageView(image: Images.destinationStop)
                tempView.tintColor = Colors.green
                tempView.translatesAutoresizingMaskIntoConstraints = false
                arrayOfViews.append(tempView)
                stopViews.append(tempView)
            }
        }
        
        self.addSubviews(arrayOfViews)
        self.configureConstraints(originCircle, line, destinationCircle, stopViews, viewPosition)
    }

    init(frame: CGRect = .zero, lineColor: UIColor = Colors.green, originColor: UIColor = Colors.green, destinationColor: UIColor = Colors.green, transportMode: RouteType, _ legPosition: LegPosition) {
        self.lineColor = Colors.rptGreen//lineColor
        self.originColor = originColor
        self.destinationColor = destinationColor
        self.lineType = transportMode
        self.legPosition = legPosition
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        switch legPosition {
        case .origin:
            switch lineType {
            case .footpath:
                let originCircle = UIImageView(image: Images.originStop)
                let destinationCircle = UIImageView(image: Images.tripStop)
                let line = DottedLine()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            default:
                let originCircle = UIImageView(image: Images.originStop)
                let destinationCircle = UIImageView(image: Images.tripStop)
                let line = Line()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            }
        case .intermediate:
            switch lineType {
            case .footpath:
                let originCircle = UIImageView(image: Images.tripStop)
                let destinationCircle = UIImageView(image: Images.tripStop)
                let line = DottedLine()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            default:
                let originCircle = UIImageView(image: Images.tripStop)
                let destinationCircle = UIImageView(image: Images.tripStop)
                let line = Line()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            }
        case .destination:
            switch lineType {
            case .footpath:
                let originCircle = UIImageView(image: Images.tripStop)
                let destinationCircle = UIImageView(image: Images.destinationStop)
                let line = DottedLine()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            default:
                let originCircle = UIImageView(image: Images.tripStop)
                let destinationCircle = UIImageView(image: Images.destinationStop)
                let line = Line()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            }
        default:
            switch lineType {
            case .footpath:
                let originCircle = UIImageView(image: Images.originStop)
                let destinationCircle = UIImageView(image: Images.destinationStop)
                let line = DottedLine()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            default:
                let originCircle = UIImageView(image: Images.originStop)
                let destinationCircle = UIImageView(image: Images.destinationStop)
                let line = Line()
                originCircle.translatesAutoresizingMaskIntoConstraints = false
                destinationCircle.translatesAutoresizingMaskIntoConstraints = false
                originCircle.tintColor = originColor
                line.color = lineColor
                destinationCircle.tintColor = destinationColor
                self.addSubviews([line, originCircle, destinationCircle])
                self.configureConstraints(originCircle, line, destinationCircle)
            }
        }
    }

    func addSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            self.addSubview(subview)
        }
    }

    func configureConstraints(_ origin: UIView, _ line: UIView, _ destination: UIView, _ tempView: [UIView]? = nil, _ viewsPosition: [CGFloat] = []) {
        
        var destinationWidthConstraint: CGFloat = 14
        var destinationHeightConstraint: CGFloat = 14
        
        if let destinationView = destination as? UIImageView, destinationView.image == Images.destinationStop! {
            destinationWidthConstraint = 12
            destinationHeightConstraint = 12
        }
        
        origin.widthAnchor.constraint(equalToConstant: 14).isActive = true
        origin.heightAnchor.constraint(equalToConstant: 14).isActive = true
        line.widthAnchor.constraint(equalToConstant: 3).isActive = true
        destination.widthAnchor.constraint(equalToConstant: destinationWidthConstraint).isActive = true
        destination.heightAnchor.constraint(equalToConstant: destinationHeightConstraint).isActive = true
        origin.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        origin.bottomAnchor.constraint(equalTo: line.topAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: destination.topAnchor).isActive = true
        line.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        origin.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        line.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        destination.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
        if let tempView = tempView, tempView.count == viewsPosition.count, tempView.count > 0, viewsPosition.count > 0 {
            for (index, circleView) in tempView.enumerated() {
                circleView.widthAnchor.constraint(equalToConstant: 9).isActive = true
                circleView.heightAnchor.constraint(equalToConstant: 9).isActive = true
                circleView.topAnchor.constraint(equalTo: origin.bottomAnchor, constant: viewsPosition[index]).isActive = true
                circleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            }
        }

    }
}
