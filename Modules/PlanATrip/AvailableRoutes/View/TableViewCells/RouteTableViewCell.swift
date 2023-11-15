//
//  RouteTableViewCell.swift
//  RCRC
//
//  Created by Errol on 08/01/21.
//

import UIKit

protocol RouteTableViewCellDelegate: AnyObject {
    func stopLabelClicked(cell: UITableViewCell, stopSequences: [StopSequenceModel]?)
}

class RouteTableViewCell: UITableViewCell {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var routeViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceRouteView: UIView!
    @IBOutlet weak var sourceIcon: UIImageView!
    @IBOutlet weak var originAddressLabel: UILabel!
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var stopAddressLabel: UILabel!
    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var destinationIcon: UIImageView!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var destinationIconWidth: NSLayoutConstraint!
    @IBOutlet weak var destinationViewCenterY: NSLayoutConstraint!
    @IBOutlet weak var lineViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var originAddressLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var destinationAddressLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var travelTimeBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stopSequenceView: UIView!
    @IBOutlet weak var stopSequenceHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stopStackView: UIStackView!
    //@IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet weak var sourceIconWidthConstraint: NSLayoutConstraint!
    //@IBOutlet weak var bottomClearView: UIView!
    //@IBOutlet weak var leftBorderView: UIView!
    //@IBOutlet weak var leftClearView: UIView!
   // @IBOutlet weak var rightBorderView: UIView!
   // @IBOutlet weak var rightClearView: UIView!
    var legType: LegPosition?
    weak var delegate: RouteTableViewCellDelegate?
    var stopSequenceModels: [StopSequenceModel]?
    var pathDescriptionModels: [PathDescription]?
    private var defaultHeightOfLabel: CGFloat = 21
    var isTowardsNameAvailable: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //self.bottomBorderView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
       // self.bottomBorderView.layer.cornerRadius = 20.0
       // bottomBorderView.isHidden = true
        setBorders()
//        self.bottomClearView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        self.bottomClearView.layer.cornerRadius = 20.0
//        bottomClearView.isHidden = true
        
        /*let addBorderLeft = CALayer()
        addBorderLeft.backgroundColor = Colors.rptGrey.cgColor
        addBorderLeft.borderWidth = 1.0
        addBorderLeft.borderColor = Colors.rptGrey.cgColor
        addBorderLeft.frame = CGRect(x: 0, y: 0, width: 1.0, height: frame.height - 100)
         //addBorderLeft.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
         //addBorderLeft.cornerRadius = 20.0
        layer.addSublayer(addBorderLeft)
        
        let addBorderRight = CALayer()
        addBorderRight.backgroundColor = Colors.rptGrey.cgColor
        addBorderRight.borderWidth = 1.0
        addBorderRight.borderColor = Colors.rptGrey.cgColor
        addBorderRight.frame = CGRect(x: UIScreen.main.bounds.size.width - 31, y: 0, width: 1.0, height: frame.height)
         //addBorderRight.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
         //addBorderLeft.cornerRadius = 20.0
        layer.addSublayer(addBorderRight)*/
        
        /*let bottomBorder = CALayer()
        bottomBorder.backgroundColor = Colors.rptGrey.cgColor
        bottomBorder.borderWidth = 1.0
        bottomBorder.borderColor = Colors.rptGrey.cgColor
        bottomBorder.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomBorder.cornerRadius = 20.0
        bottomBorder.frame = CGRect(x: 0, y: frame.height, width: frame.width - 49.0, height: 1.0)
        layer.addSublayer(bottomBorder)*/
        
        translatesAutoresizingMaskIntoConstraints = true
        self.lineView.backgroundColor = .clear
        clipsToBounds = false
        contentView.clipsToBounds = false
        layer.backgroundColor = UIColor.clear.cgColor
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        originAddressLabel.setAlignment()
        stopAddressLabel.setAlignment()
        stopNameLabel.setAlignment()
        travelTimeLabel.setAlignment()
        destinationLabel.setAlignment()
        self.stopAddressLabel.textColor = Colors.textColor
        self.destinationIcon.image = nil
        self.destinationIconWidth.constant = 0
        stopSequenceView.translatesAutoresizingMaskIntoConstraints = false
        
//        stopSequenceView.backgroundColor = .magenta
//        stopStackView.backgroundColor = .green
//        sourceRouteView.backgroundColor = .orange
//        travelTimeLabel.backgroundColor = .cyan
        
    }

    func setBorders()  {
        
        //self.contentView.layer.addBorder(edge: .left, color: Colors.rptGreen, thickness: 0.5)
        //self.contentView.layer.addBorder(edge: .right, color: Colors.rptGreen, thickness: 0.5)
    
        
    }
    func configure(with viewModel: RouteCellViewModel, selectedRow: Int? = nil, currentRow: Int? = nil, isExpanded: Bool = false, showBottom: Bool = false) {
       // viewModel.origin.color
        //self.contentView.layer.addBorder(edge: .left, color: Colors.rptGreen, thickness: 1)
        //self.contentView.layer.addBorder(edge: .right, color: Colors.rptGreen, thickness: 1)
        if showBottom {
            /*let bottomBorder = CALayer()
             bottomBorder.name = "Card Border"
             bottomBorder.backgroundColor = Colors.rptGrey.cgColor
             bottomBorder.borderWidth = 1.0
             bottomBorder.borderColor = Colors.rptGrey.cgColor
             //bottomBorder.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
             //bottomBorder.cornerRadius = 20.0
             bottomBorder.frame = CGRect(x: 0, y: frame.height + 100, width: frame.width, height: 1.0)
             layer.addSublayer(bottomBorder)*/
            
//            self.rightBorderView.layer.maskedCorners = [.layerMaxXMaxYCorner]
//            self.rightBorderView.layer.cornerRadius = 20.0
//            self.rightClearView.layer.maskedCorners = [.layerMaxXMaxYCorner]
//            self.rightClearView.layer.cornerRadius = 20.0
//
//            self.leftBorderView.layer.maskedCorners = [.layerMinXMaxYCorner]
//            self.leftBorderView.layer.cornerRadius = 20.0
//            self.leftClearView.layer.maskedCorners = [.layerMinXMaxYCorner]
//            self.leftClearView.layer.cornerRadius = 20.0
            
            //self.bottomBorderView.isHidden = false
           // self.bottomClearView.isHidden = false
        } else {
//            self.rightBorderView.layer.cornerRadius = 0
//            self.rightClearView.layer.cornerRadius = 0
//            self.leftBorderView.layer.cornerRadius = 0
//            self.leftClearView.layer.cornerRadius = 0
            
//            self.bottomBorderView.isHidden = true
//            self.bottomClearView.isHidden = true
        }
        self.lineView.subviews.forEach({ $0.removeFromSuperview() })
        
        self.stopSequenceModels = viewModel.stopSequenceModels
        self.pathDescriptionModels = viewModel.pathDescriptionModels
        stopSequenceHeightConstraint.constant = 0.0
        var viewPosition: [CGFloat] = []
        
        if selectedRow != nil && selectedRow == currentRow {
            switch viewModel.line.lineType {
            case.dotted:
                self.setupPathDescription()
            case .solid:
                viewPosition = setupStopSequence()
            }
        } else {
            stopStackView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            for addedSubView in stopStackView.arrangedSubviews where stopStackView.arrangedSubviews.count > 0 {
                self.stopStackView.removeArrangedSubview(addedSubView)
            }
        }
        
        
        switch viewModel.line.1 {
        case .solid:
            let leg = LegUI(solidLine: viewModel.line.0, origin: viewModel.origin, destination: viewModel.destination, stopsSequenceCount: stopSequenceModels?.count ?? 0, isExpanded: isExpanded, viewPosition: viewPosition)
            self.lineView.addSubview(leg)
            self.configureConstraints(for: leg)

        case .dotted:
           // let leg = LegUI(dottedLine: viewModel.line.0, origin: viewModel.origin, destination: viewModel.destination)
            let leg = LegUI(solidLine: viewModel.line.0, origin: viewModel.origin, destination: viewModel.destination, stopsSequenceCount: stopSequenceModels?.count ?? 0, isExpanded: isExpanded, viewPosition: viewPosition)
            self.lineView.addSubview(leg)
            self.configureConstraints(for: leg)
        }
        self.sourceIcon.image = viewModel.image
        
        self.travelTimeLabel.text = viewModel.duration
        self.travelTimeLabel.isUserInteractionEnabled = false
        
        if (viewModel.line.lineType == .solid || viewModel.line.lineType == .dotted) && (self.stopSequenceModels?.count ?? 0 > 0 || self.pathDescriptionModels?.count ?? 0 > 0) {
            self.addingActionToTravelTimeLabel()
            self.travelTimeLabel.attributedText = viewModel.setAttributedStringToDurationLabel(isExpanded: isExpanded, duration: viewModel.duration ?? emptyString)
        }

        isTowardsNameAvailable = false
        
        var strstopName = ""
        
        if let towardsName = viewModel.stopNameTowards, towardsName != "", let stopName = viewModel.stopName, stopName != "" {
            isTowardsNameAvailable = true
            //self.stopNameLabel.attributedText = setTowardBusWithAddressLabel(stopName: stopName, towardName: towardsName)
            self.stopNameLabel.font = Fonts.CodecBold.fourteen
            strstopName = "\(stopName) \(towardsName)"
        } else {
            self.stopNameLabel.text = viewModel.stopName
            self.stopNameLabel.font = Fonts.CodecRegular.fourteen
        }
        self.stopNameLabel.numberOfLines = 0
        self.stopNameLabel.isHidden = strstopName.count == 0
        self.stopNameLabel.text = strstopName
        stopNameLabel.setAlignment()
        
        let stopAddressWithTime = viewModel.stopAddressWithStopTime
        //viewModel.stopTime ?? emptyString == emptyString ? viewModel.stopTime ?? emptyString : "\(viewModel.stopTime ?? emptyString)   \(viewModel.stopAddress ?? emptyString)"
        self.stopAddressLabel.attributedText = stopAddressWithTime

        self.originAddressLabel.attributedText = viewModel.originAddress
        self.destinationLabel.attributedText = viewModel.destinationAddress
        travelTimeLabel.isHidden = travelTimeLabel.text?.count == 0
        travelTimeLabel.font = Fonts.CodecRegular.twelve
        travelTimeLabel.textColor = Colors.textGray
        configureConstraints(for: viewModel.position, travelTimeLabelBottomValue: (selectedRow != nil && selectedRow == currentRow) ? 16: 10)
    }
    
    private func setupStopSequence() -> [CGFloat] {
        
        let travelTimeLabelFrameYConstant: CGFloat = 33
        var viewPositions: [CGFloat] = []
        if let stopSequenceModel = stopSequenceModels, stopSequenceModel.count > 0 {
            stopStackView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            for addedSubView in stopStackView.arrangedSubviews where stopStackView.arrangedSubviews.count > 0 {
                self.stopStackView.removeArrangedSubview(addedSubView)
            }
            var viewHeight: CGFloat = 0.0
            var travelTimeLabelFrameY = ceil(travelTimeLabel.frame.origin.y)
            if travelTimeLabelFrameY != travelTimeLabelFrameYConstant {
                travelTimeLabelFrameY = travelTimeLabelFrameYConstant
            }
            
            var framePosition: CGFloat = travelTimeLabelFrameY + travelTimeLabel.frame.height + 2 - 9
            for index in 0 ..< stopSequenceModel.count {
                let sequenceViewLabel = self.configureStopSequenceContent(stop: stopSequenceModel[index])
                
                viewHeight += sequenceViewLabel.height
                if index == 0 {
                    viewPositions.append(framePosition)
                } else {
                    framePosition += sequenceViewLabel.height
                    viewPositions.append(framePosition)
                }
            }
            stopSequenceHeightConstraint.constant = viewHeight
        }
        return viewPositions
    }
    
    private func setupPathDescription() {
        
        if let pathDescriptionModel = pathDescriptionModels, pathDescriptionModel.count > 0 {
            stopStackView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            for addedSubView in stopStackView.arrangedSubviews where stopStackView.arrangedSubviews.count > 0 {
                self.stopStackView.removeArrangedSubview(addedSubView)
            }
            var viewHeight: CGFloat = 0.0
            var travelTimeLabelFrameY = travelTimeLabel.frame.origin.y
            if travelTimeLabelFrameY != 28 {
                travelTimeLabelFrameY = travelTimeLabelFrameY - travelTimeLabel.frame.height
            }
    
            for index in 0 ..< pathDescriptionModel.count {
                let pathViewLabel = self.configurePathDescriptionContent(path: pathDescriptionModel[index])
                
                viewHeight += pathViewLabel.height
            }
            let stackViewSpacing = (8 * (pathDescriptionModel.count - 1)) + 4
            let finalHeight = CGFloat(stackViewSpacing) + viewHeight
            stopSequenceHeightConstraint.constant = finalHeight
            
            /*let addBorderLeft = CALayer()
            addBorderLeft.backgroundColor = Colors.rptGrey.cgColor
            addBorderLeft.borderWidth = 1.0
            addBorderLeft.borderColor = Colors.rptGrey.cgColor
            addBorderLeft.frame = CGRect(x: 0, y: frame.height + 100, width: 1.0, height: 100)
            //addBorderLeft.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            //addBorderLeft.cornerRadius = 20.0
            layer.addSublayer(addBorderLeft)
            
            let addBorderRight = CALayer()
            //addBorderRight.name = "Card Border"
            addBorderRight.backgroundColor = Colors.rptGrey.cgColor
            addBorderRight.borderWidth = 1.0
            addBorderRight.borderColor = Colors.rptGrey.cgColor
            addBorderRight.frame = CGRect(x: UIScreen.main.bounds.size.width - 31, y: frame.height + 100, width: 1.0, height: 100)
            //topBorder.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            //addBorderLeft.cornerRadius = 20.0
            layer.addSublayer(addBorderRight)*/
        }
    }
    
    
    private func configureStopSequenceContent(stop: StopSequenceModel) -> (height: CGFloat, view: UIView) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: stopSequenceView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = Fonts.CodecNews.thirteen
        label.textColor = Colors.textColor
        label.lineBreakMode = .byWordWrapping
        label.attributedText = stop.timeName
        label.setAlignment()
        self.stopStackView.addArrangedSubview(label)
        label.sizeToFit()
        return (defaultHeightOfLabel, label)
    }
    
    private func configurePathDescriptionContent(path: PathDescription) -> (height: CGFloat, view: UIView) {
        
        let attributedContent = setAttributedStringOnLabel(path: path)
        
        let view = UIView()
        
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = attributedContent.pathDesc
        label.setAlignment()
        
        let distanceLabel = UILabel()
        distanceLabel.numberOfLines = 0
        distanceLabel.attributedText = attributedContent.distance
        distanceLabel.setAlignment()
        
        let imageView = UIImageView()
        imageView.image = attributedContent.image
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(distanceLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        
        distanceLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 0).isActive = true
        distanceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        distanceLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5).isActive = true
        distanceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        distanceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        self.stopStackView.distribution = .fillProportionally
        self.stopStackView.addArrangedSubview(view)
        label.sizeToFit()
        
        let labelHeight = attributedContent.pathDesc.height(containerWidth: self.stopStackView.frame.width)
        let labelDistance = attributedContent.distance.height(containerWidth: self.stopStackView.frame.width)
        let finalHeight = labelHeight + labelDistance
        return (finalHeight, label)
    }
    
    func setAttributedStringOnLabel(path: PathDescription) -> (pathDesc: NSAttributedString, distance: NSAttributedString, image: UIImage) {
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecNews.thirteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        
        let pathDescriptionContent = setPathDescriptionContent(path: path)
        let descSting = NSMutableAttributedString(
            string: pathDescriptionContent.0,
            attributes: attributes
        )
        
        let distanceString = NSMutableAttributedString(
            string: pathDescriptionContent.2,
            attributes: attributes
        )
        
        return (descSting, distanceString, pathDescriptionContent.1)
    }
    
    
    private func setPathDescriptionContent(path: PathDescription) -> (String, UIImage, String) {
        
        var pathFullDescription: String = emptyString
        
        var pathName: String = emptyString
        if let name = path.name, name != emptyString {
            pathName = "to \(name)"
        }
        
        let turnDirection = path.turnDirection.rawValue.replacingOccurrences(of: "_", with: " ").capitalized.replacingOccurrences(of: " _", with: "")
        var manouver = path.manoeuvre.rawValue.replacingOccurrences(of: "_", with: " ").capitalized.replacingOccurrences(of: " _", with: "")
        let distance = path.distance?.walkingDistanceForLabel ?? emptyString
        
        if path.manoeuvre == .uTurn {
            manouver = "Take"
        }
        
        if path.manoeuvre == .leave || (path.manoeuvre == .enter && path.turnDirection == .unknown) || (path.manoeuvre == .leave && path.turnDirection == .unknown) {
            pathFullDescription = path.name ?? emptyString
        } else {
            if pathName.isEmpty || pathName == emptyString {
                pathFullDescription = manouver + " " + turnDirection
            } else {
                pathFullDescription = manouver + " " + turnDirection + " " + pathName
            }
        }
        
        var image: UIImage = UIImage()
        if path.manoeuvre == .enter && path.turnDirection == .unknown {
            image = Images.dirEnterBus!
        } else if path.manoeuvre == .leave && path.turnDirection == .unknown {
            image = Images.dirleaveBus!
        } else {
            image = path.turnDirection.image 
        }
        return (pathFullDescription, image, distance)
    }
    
    private func addingActionToTravelTimeLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RouteTableViewCell.tapFunction))
        travelTimeLabel.isUserInteractionEnabled = true
        travelTimeLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        delegate?.stopLabelClicked(cell: self, stopSequences: stopSequenceModels)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    // MARK: - Helper
    private func configureConstraints(for view: UIView) {
        view.topAnchor.constraint(equalTo: self.lineView.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.lineView.bottomAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: self.lineView.centerXAnchor).isActive = true
    }

    private func configureConstraints(for leg: LegPosition, travelTimeLabelBottomValue: CGFloat = 10) {
        
        var routeIntermediateConstraint: CGFloat = 0
        if isTowardsNameAvailable {
            routeIntermediateConstraint = 10
        }
        
        
        switch leg {
        case .origin:
            self.routeViewTopConstraint.constant = 30
            self.lineViewTopConstraint.constant = 30
            self.destinationViewCenterY.constant = 0
            self.lineViewBottomConstraint.constant = 0
            self.travelTimeBottomConstraint.constant = travelTimeLabelBottomValue
            self.sourceIconWidthConstraint.constant = 0
           
        case .intermediate:
            self.sourceIconWidthConstraint.constant = 20
            self.routeViewTopConstraint.constant = routeIntermediateConstraint
            self.lineViewTopConstraint.constant = 0
            self.destinationViewCenterY.constant = 0
            self.lineViewBottomConstraint.constant = 0
            self.travelTimeBottomConstraint.constant = travelTimeLabelBottomValue
        case .destination:
            self.routeViewTopConstraint.constant = 0
            self.lineViewTopConstraint.constant = 0
            self.destinationViewCenterY.constant = -50
            self.lineViewBottomConstraint.constant = 50
        case .single:
            self.routeViewTopConstraint.constant = 30
            self.lineViewTopConstraint.constant = 30
            self.destinationViewCenterY.constant = -50
            self.lineViewBottomConstraint.constant = 50
        }
    }
    
    func setTowardBusWithAddressLabel(stopName: String, towardName: String) -> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecBold.sixteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor,
            NSMutableAttributedString.Key.paragraphStyle: paragraphStyle
          ]
        
        let towardsAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecNews.fourteen,
            NSAttributedString.Key.foregroundColor: Colors.darkGray,
            NSMutableAttributedString.Key.paragraphStyle: paragraphStyle
          ]
        
        let stopName = NSMutableAttributedString(string: stopName, attributes: attributes)
        
        let towardStopName = NSMutableAttributedString(string: towardName, attributes: towardsAttributes)
        
        stopName.append(NSMutableAttributedString(string: " "))
        stopName.append(towardStopName)
        return stopName
    }
    
    
}

extension NSAttributedString {
    func height(containerWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude),
                                     options: [.usesLineFragmentOrigin, .usesFontLeading],
                                     context: nil)
        return ceil(rect.size.height)
    }
}
