//
//  RouteCellViewModel.swift
//  RCRC
//
//  Created by Errol on 28/05/21.
//

import UIKit

struct StopRouteExpandModel {
    var selectedRow: Int = -1
    var isExpanded: Bool = false
}

struct StopSequenceModel {
    var time: String
    var name: String
    var timeName: NSMutableAttributedString
}

enum TimeDifference{
    case delay
    case early
    case same
    case noTime
}

enum FootpathType {
    case origin
    case destination
    case middle
    case single
    case none
}

struct RouteCellViewModel {

    // Line
    let origin: (color: UIColor, image: UIImage)
    let destination: (color: UIColor, image: UIImage)
    let line: (color: UIColor, lineType: LineType)

    // Route
    let image: UIImage?
    var originAddress: NSMutableAttributedString?
    var stopName: String?
    var stopNameTowards: String? = nil
    var stopAddress: String?
    var stopTime: String?
    var destinationAddress: NSMutableAttributedString?
    var destinationTime: String?
    let duration: String?
    var stopSequenceModels: [StopSequenceModel]?
    var pathDescriptionModels: [PathDescription]?
    var stopAddressWithStopTime: NSMutableAttributedString?

    let position: LegPosition

    /// Configuration For First Leg
    /// - Parameter leg: journey.legs[index]
    init(originLeg leg: Leg, isActive: Bool = true) {
        let transportMode = leg.transportation.product.name
        let travelTime = leg.duration?.minutes.string ?? zero
        let walkingDistance = leg.distance?.walkingDistance ?? emptyString
        origin = (isActive ? Colors.green : .lightGray, Images.originStop!)
        destination = (isActive ? Colors.green : .clear, Images.tripStop!)
        switch transportMode {
        case .footpath, .FootPath, .arabFootpath:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .dotted)
            image = Images.walkingIcon!
            
            let originTimeWithName = RouteCellViewModel.getOriginTimeWithName(leg: leg, footPathType: .origin)
            originAddress = originTimeWithName.0
            
            /*
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName, originTimeWithName.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, originTimeWithName.1)
             */
             
            if currentLanguage == .arabic {
                duration = "\(walkingDistance) \(String(format: "عدد (%@) دقيقة سيراً على الأقدام", travelTime))"
            } else {
                duration = "\(walkingDistance)\(travelTime)\(Constants.walkTitle.localized)"
            }
            pathDescriptionModels = RouteCellViewModel.getPathDescriptions(originLeg: leg)

        case .bus, .BUS, .community, .arabBus:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .solid)
            image = Images.routeBusTransportMode!
            stopName = leg.transportation.name
            if let destination = leg.transportation.destination, let towardName = destination.name {
                stopNameTowards = "\(Constants.towards.localized) \(towardName)"
            }
            stopAddress = leg.origin?.name
            
            let stopSequenceModel = RouteCellViewModel.getStopSequence(originLeg: leg)
            let stopSequenceCount = stopSequenceModel?.count ?? 0 < 1 ? "": "\(Constants.comma) \(stopSequenceModel?.count.string ?? "0") \(Constants.stopRoute.localized)"
            duration = "\(travelTime.minLocalisation)\(stopSequenceCount)"
            stopTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""
            
            stopAddressWithStopTime = RouteCellViewModel.getStopAddressWithStopTime(leg: leg)
            stopSequenceModels = stopSequenceModel
            destinationTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""
            
        case .cycling:
            line = (isActive ? Colors.orange : .lightGray, .solid)
            image = Images.transportModeCareem!
            if let disassemblename = leg.origin?.disassembledName {
                originAddress = Utilities.shared.getAttributedText(disassemblename, leg.origin?.parent?.name)
            } else {
                originAddress = Utilities.shared.getAttributedText(leg.origin?.parent?.name, leg.origin?.parent?.name)
            }
            duration = "\(travelTime) Min Cycling"

        case .taxi:
            line = (isActive ? Colors.lightYellow : .lightGray, .solid)
            image = Images.transportModeUber!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName, leg.origin?.parent?.name)
            duration = "\(travelTime) \(Constants.minDrive.localized)"
        }
        position = .origin
    }

    /// Configuration For Middle Leg
    /// - Parameter leg: journey.legs[index]
    init(middleLeg leg: Leg, isActive: Bool = true) {
        let transportMode = leg.transportation.product.name
        let travelTime = leg.duration?.minutes.string ?? zero
        let walkingDistance = leg.distance?.walkingDistance ?? emptyString
        origin = (isActive ? Colors.green : .lightGray, Images.tripStop!)
        destination = (isActive ? Colors.green : .clear, Images.tripStop!)
        switch transportMode {
        case .footpath, .FootPath, .arabFootpath:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .dotted)
            image = Images.walkingIcon!
            
            let originTimeWithName = RouteCellViewModel.getOriginTimeWithName(leg: leg, footPathType: .middle)
            originAddress = originTimeWithName.0
            /*
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, originTimeWithName.0,
                                                               Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, originTimeWithName.1)
             */
            if currentLanguage == .arabic {
                duration = "\(walkingDistance) \(String(format: "عدد (%@) دقيقة سيراً على الأقدام", travelTime))"
            } else {
                duration = "\(walkingDistance)\(travelTime)\(Constants.walkTitle.localized)"
            }
            pathDescriptionModels = RouteCellViewModel.getPathDescriptions(originLeg: leg)

        case .bus, .BUS, .community, .arabBus:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .solid)
            image = Images.routeBusTransportMode!
            stopName = leg.transportation.name
            if let destination = leg.transportation.destination, let towardName = destination.name {
                stopNameTowards = "\(Constants.towards.localized) \(towardName)"
            }
            stopAddress = leg.origin?.name
            
            let stopSequenceModel = RouteCellViewModel.getStopSequence(originLeg: leg)
            let stopSequenceCount = stopSequenceModel?.count ?? 0 < 1 ? "": "\(Constants.comma) \(stopSequenceModel?.count.string ?? "0") \(Constants.stopRoute.localized)"
            duration = "\(travelTime.minLocalisation)\(stopSequenceCount)"
            stopSequenceModels = stopSequenceModel
            
            stopTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""
            stopAddressWithStopTime = RouteCellViewModel.getStopAddressWithStopTime(leg: leg)
            destinationTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""

        case .cycling:
            line = (isActive ? Colors.orange : .lightGray, .solid)
            image = Images.transportModeCareem!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name,
                                                                                                              Fonts.RptaSignage.fourteen!, Fonts.RptaSignage.twelve!)
            duration = "\(travelTime) Min Cycling"

        case .taxi:
            line = (isActive ? Colors.lightYellow : .lightGray, .solid)
            image = Images.transportModeUber!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name,
                                                                                                              Fonts.RptaSignage.fourteen!, Fonts.RptaSignage.twelve!)
            duration = "\(travelTime) \(Constants.minDrive.localized)"
        }
        position = .intermediate
    }

    /// Configuration For Last Leg
    /// - Parameter leg: journey.legs[index]
    init(destinationLeg leg: Leg, isActive: Bool = true) {
        let transportMode = leg.transportation.product.name
        let travelTime = leg.duration?.minutes.string ?? zero
        let walkingDistance = leg.distance?.walkingDistance ?? emptyString
        origin = (isActive ? Colors.green : .lightGray, Images.tripStop!)
        destination = (isActive ? Colors.green : .lightGray, Images.destinationStop!)
        
        let destinationAddressWithTime = RouteCellViewModel.getDestinationWithName(leg: leg, productName: transportMode)
        
        switch transportMode {
        case .footpath, .FootPath, .arabFootpath:
//            line = (isActive ? Colors.tripBusLineColor : .lightGray, .dotted)
            line = (isActive ? Colors.rptGreen : .lightGray, .dotted)
            image = Images.walkingIcon!
            
            let originTimeWithName = RouteCellViewModel.getOriginTimeWithName(leg: leg, footPathType: .destination)
            originAddress = originTimeWithName.0
            destinationAddress = destinationAddressWithTime.0
            
            /*
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, originTimeWithName.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, originTimeWithName.1)
             
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName, destinationAddressWithTime.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, destinationAddressWithTime.1)
             */
            
            if currentLanguage == .arabic {
                duration = "\(walkingDistance) \(String(format: "عدد (%@) دقيقة سيراً على الأقدام", travelTime))"
            } else {
                duration = "\(walkingDistance)\(travelTime)\(Constants.walkTitle.localized)"
            }
            pathDescriptionModels = RouteCellViewModel.getPathDescriptions(originLeg: leg)

        case .bus, .BUS, .community, .arabBus:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .solid)
            image = Images.routeBusTransportMode!
            stopName = leg.transportation.name
            if let destination = leg.transportation.destination, let towardName = destination.name {
                stopNameTowards = "\(Constants.towards.localized) \(towardName)"
            }
            stopAddress = leg.origin?.name
            
            destinationAddress = destinationAddressWithTime.0
            /*
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName ?? leg.destination?.name ?? leg.destination?.parent?.name, destinationAddressWithTime.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, destinationAddressWithTime.1)
             */
            
            let stopSequenceModel = RouteCellViewModel.getStopSequence(originLeg: leg)
            let stopSequenceCount = stopSequenceModel?.count ?? 0 < 1 ? "": "\(Constants.comma) \(stopSequenceModel?.count.string ?? "0") \(Constants.stopRoute.localized)"
            duration = "\(travelTime.minLocalisation)\(stopSequenceCount)"
            stopSequenceModels = stopSequenceModel
            
            stopTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""
            stopAddressWithStopTime = RouteCellViewModel.getStopAddressWithStopTime(leg: leg)
            destinationTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""

        case .cycling:
            line = (isActive ? Colors.orange : .lightGray, .solid)
            image = Images.transportModeCareem!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name, Fonts.RptaSignage.fourteen!, Fonts.RptaSignage.twelve!)
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.name, leg.destination?.parent?.name)
            duration = "\(travelTime) Min Cycling"

        case .taxi:
            line = (isActive ? Colors.lightYellow : .lightGray, .solid)
            image = Images.transportModeUber!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName ?? leg.origin?.name, leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name, Fonts.RptaSignage.fourteen!, Fonts.RptaSignage.twelve!)
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName, leg.destination?.parent?.name)
            duration = "\(travelTime) \(Constants.minDrive.localized)"
        }
        position = .destination
    }

    /// Configuration For Single Leg
    /// - Parameter leg: journey.legs[index]
    init(singleLeg leg: Leg, isActive: Bool = true) {
        let transportMode = leg.transportation.product.name
        let travelTime = leg.duration?.minutes.string ?? zero
        let walkingDistance = leg.distance?.walkingDistance ?? emptyString
        origin = (isActive ? Colors.green : .lightGray, Images.originStop!)
        destination = (isActive ? Colors.green : .lightGray, Images.destinationStop!)
        
        let destinationAddressWithTime = RouteCellViewModel.getDestinationWithName(leg: leg, productName: transportMode)
        
        switch transportMode {
        case .footpath, .FootPath, .arabFootpath:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .dotted)
            image = Images.walkingIcon!
            
            let originTimeWithName = RouteCellViewModel.getOriginTimeWithName(leg: leg)
            originAddress = originTimeWithName.0
            destinationAddress = destinationAddressWithTime.0
            
            /*
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName, originTimeWithName.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, originTimeWithName.1)
             
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName ?? leg.destination?.parent?.name, destinationAddressWithTime.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, destinationAddressWithTime.1)
             */
            
            if currentLanguage == .arabic {
                duration = "\(walkingDistance) \(String(format: "عدد (%@) دقيقة سيراً على الأقدام", travelTime))"
            } else {
                duration = "\(walkingDistance)\(travelTime)\(Constants.walkTitle.localized)"
            }
            pathDescriptionModels = RouteCellViewModel.getPathDescriptions(originLeg: leg)

        case .bus, .BUS, .community, .arabBus:
            line = (isActive ? Colors.tripBusLineColor : .lightGray, .solid)
            image = Images.routeBusTransportMode!
            stopName = leg.transportation.name
            if let destination = leg.transportation.destination, let towardName = destination.name {
                stopNameTowards = "\(Constants.towards.localized) \(towardName)"
            }
            stopAddress = leg.origin?.name
            
            destinationAddress = destinationAddressWithTime.0
            /*
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName ?? leg.destination?.name ?? leg.destination?.parent?.name, destinationAddressWithTime.0, Fonts.CodecBold.sixteen!, Fonts.CodecNews.fourteen!, isActive ? Colors.textColor: Colors.darkGray, destinationAddressWithTime.1)
             */
            
            let stopSequenceModel = RouteCellViewModel.getStopSequence(originLeg: leg)
            let stopSequenceCount = stopSequenceModel?.count ?? 0 < 1 ? "": "\(Constants.comma) \(stopSequenceModel?.count.string ?? "0") \(Constants.stopRoute.localized)"
            duration = "\(travelTime.minLocalisation)\(stopSequenceCount)"
            stopSequenceModels = stopSequenceModel
            
            stopTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""
            stopAddressWithStopTime = RouteCellViewModel.getStopAddressWithStopTime(leg: leg)
            destinationTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? ""

        case .cycling:
            line = (isActive ? Colors.orange : .lightGray, .solid)
            image = Images.transportModeCareem!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName, leg.origin?.parent?.name)
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.name ?? leg.destination?.parent?.name, leg.destination?.parent?.name)
            duration = "\(travelTime) Min Cycling"

        case .taxi:
            line = (isActive ? Colors.lightYellow : .lightGray, .solid)
            image = Images.transportModeUber!
            originAddress = Utilities.shared.getAttributedText(leg.origin?.disassembledName, leg.origin?.parent?.name)
            destinationAddress = Utilities.shared.getAttributedText(leg.destination?.disassembledName ?? leg.destination?.parent?.name, leg.destination?.parent?.name)
            duration = "\(travelTime) \(Constants.minDrive.localized)"
        }
        position = .single
    }
    
    private static func getStopSequence(originLeg leg: Leg) -> [StopSequenceModel]? {
        if let stopSequence = leg.stopSequence, stopSequence.count >= 1 {
            var stopSequences: [StopSequence?] = stopSequence
            if let originIndex = stopSequences.firstIndex(where: {$0?.name == leg.origin?.name}) {
                stopSequences.remove(at: originIndex)
            }
            
            if let destinationIndex = stopSequences.firstIndex(where: {$0?.name == leg.destination?.name}) {
                stopSequences.remove(at: destinationIndex)
            }
            
            var sequenceModels: [StopSequenceModel] = []
            let isWalking = leg.transportation.product.name == .footpath || leg.transportation.product.name == .FootPath || leg.transportation.product.name == .arabFootpath ? true : false
            for stopSequence in stopSequences {
                if let stopSequence = stopSequence {
                    let attributedString = getAttributedTextForStopSequence(stopSequence: stopSequence, isTrasportModeWalking: isWalking)
                    let modal = StopSequenceModel(time: stopSequence.departureTimePlanned ?? "", name: stopSequence.disassembledName ?? stopSequence.name ?? "", timeName: attributedString)
                    sequenceModels.append(modal)
                }
            }
            return sequenceModels
        } else {
            return []
        }
    }
    
    private static func getPathDescriptions(originLeg leg: Leg) -> [PathDescription]? {
        
        var pathDes: [PathDescription] = []
        if let paths = leg.pathDescriptions, paths.count > 0 {
            pathDes = paths
            if let index = pathDes.firstIndex(where: {$0.manoeuvre == .origin && $0.turnDirection == .unknown}) {
                pathDes.remove(at: index)
            }
        }
        return pathDes
    }
    
    func setAttributedStringToDurationLabel(isExpanded: Bool = false, duration: String) -> NSMutableAttributedString {
        switch isExpanded {
        case true:
            return RouteCellViewModel.getAttributedString(image: Images.upArrow ?? UIImage(), text: duration)
        case false:
            return RouteCellViewModel.getAttributedString(image: Images.downArrow ?? UIImage(), text: duration)
        }
    }
    
    private static func getAttributedString(image: UIImage, text: String) -> NSMutableAttributedString {
        let attachment = NSTextAttachment()
        attachment.image = image
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: "\(text)  ", attributes: [:])
        string.append(attachmentString)
        return string
    }
    
    private static func getAttributedTextForStopSequence(stopSequence: StopSequence, isTrasportModeWalking: Bool) -> NSMutableAttributedString {
        
        let departurePlannedTime = stopSequence.departureTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let departureEstimatedTime = stopSequence.departureTimeEstimated?.toDate(timeZone: .AST)
        
        var originDepartureTime = stopSequence.departureTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString

        let parentName = stopSequence.disassembledName ?? stopSequence.name ?? emptyString
        
        if let departureEstimatedTime = departureEstimatedTime {
            let departureTimeDifference = self.getDateDiff(start: departurePlannedTime, end: departureEstimatedTime)
            var timeDifferene: TimeDifference = .noTime
            if originDepartureTime == emptyString {
                timeDifferene = .noTime
            } else {
                if departureTimeDifference > 0 {
                    timeDifferene = .delay
                    originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
                } else if departureTimeDifference < 0 {
                    originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
                    timeDifferene = .early
                } else {
                    timeDifferene = .same
                }
            }
            
            let stopSequenceAttributedString = getAttributedStringForTime(time: originDepartureTime, parentName: parentName, timeDifference: timeDifferene, isTrasportModeWalking: isTrasportModeWalking)
            return stopSequenceAttributedString
        } else {
            let stopSequenceAttributedString = getAttributedStringForTime(time: originDepartureTime, parentName: parentName, timeDifference: .same, isTrasportModeWalking: isTrasportModeWalking)
            return stopSequenceAttributedString
        }
            
    }
    
    private static func getStopAddressWithStopTime(leg: Leg) -> NSMutableAttributedString {
        
        let isWalking = leg.transportation.product.name == .footpath || leg.transportation.product.name == .FootPath || leg.transportation.product.name == .arabFootpath ? true : false
        let departurePlannedTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let departureEstimatedTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST) ?? Date()
        var originDepartureTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString

        let departureTimeDifference = self.getDateDiff(start: departurePlannedTime, end: departureEstimatedTime)
        let parentName = leg.origin?.disassembledName ?? emptyString
        
        var timeDifferene: TimeDifference = .noTime
        if originDepartureTime == emptyString {
            timeDifferene = .noTime
        } else {
            if departureTimeDifference > 0 {
                timeDifferene = .delay
                originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
            } else if departureTimeDifference < 0 {
                originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
                timeDifferene = .early
            } else {
                timeDifferene = .same
            }
        }
        
        /*
        if isWalking {
            originDepartureTime = departurePlannedTime.toString(withFormat: Constants.timeFormat, timeZone: .AST)
            print("********** New ---- \(originDepartureTime) *******")
        }
        */
        
        let secondString = getAttributedStringForTime(time: originDepartureTime, parentName: parentName, timeDifference: timeDifferene, isTrasportModeWalking: isWalking)
        return secondString
        
    }
    
    private static func getOriginTimeWithName(leg: Leg, footPathType: FootpathType = .none) -> (NSMutableAttributedString?, Bool) {
        
        let isWalking = leg.transportation.product.name == .footpath || leg.transportation.product.name == .FootPath || leg.transportation.product.name == .arabFootpath ? true : false
        let departurePlannedTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let departureEstimatedTime = leg.origin?.departureTimeEstimated?.toDate(timeZone: .AST) ?? Date()
        var originDepartureTime = leg.origin?.departureTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString

        let departureTimeDifference = self.getDateDiff(start: departurePlannedTime, end: departureEstimatedTime)
        var parentName: String = leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name ?? emptyString
        switch footPathType {
        case .origin, .destination:
            if isWalking {
                parentName = leg.origin?.disassembledName ?? leg.origin?.name ?? ""
            }
        case .middle:
            parentName = emptyString
        default:
            break
        }
        
        let riyadhName = leg.origin?.parent?.parent?.name ?? leg.origin?.parent?.name ?? emptyString
        parentName = parentName.replacingOccurrences(of: riyadhName, with: "")
        
        var timeDifferene: TimeDifference = .noTime
        if originDepartureTime == emptyString {
            timeDifferene = .noTime
        } else {
            if departureTimeDifference > 0 {
                timeDifferene = .delay
                originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
            } else if departureTimeDifference < 0 {
                originDepartureTime = departureEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
                timeDifferene = .early
            } else {
                timeDifferene = .same
            }
        }
        
        
        if isWalking && footPathType == .origin && timeDifferene == .delay{
            originDepartureTime = departurePlannedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
        }
        
        
        let isRequiredNewLine = originDepartureTime == emptyString ? false: true
        let secondString = getAttributedStringForTime(time: originDepartureTime, parentName: parentName, timeDifference: timeDifferene, isTrasportModeWalking: isWalking)
        
        let disassembledName = leg.origin?.disassembledName ?? ""
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecBold.sixteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        let disassembleAttr = NSMutableAttributedString(string: disassembledName, attributes: attributes)
        
        if disassembledName != "" {
            if isRequiredNewLine {
                disassembleAttr.append(NSMutableAttributedString(string: " \n"))
                disassembleAttr.append(secondString)
                return (disassembleAttr, isRequiredNewLine)
            } else {
                disassembleAttr.append(NSMutableAttributedString(string: ", "))
                disassembleAttr.append(secondString)
                return (disassembleAttr, isRequiredNewLine)
            }
        } else {
            return (secondString, isRequiredNewLine)
        }
    }
    
    private static func getDestinationWithName(leg: Leg, productName: ProductName) -> (NSMutableAttributedString?, Bool) {
        
        let arrivalPlannedTime = leg.destination?.arrivalTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let arrivalEstimatedTime = leg.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST) ?? Date()
        var departureTime = leg.destination?.arrivalTimePlanned?.toDate(timeZone: .AST)?.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST) ?? emptyString

        let arrivalTimeDifference = self.getDateDiff(start: arrivalPlannedTime, end: arrivalEstimatedTime)
        
        let ddisassembledName = leg.destination?.disassembledName ?? emptyString
        let parentParentName = leg.destination?.parent?.parent?.name ?? emptyString
        let parentName = leg.destination?.parent?.name ?? emptyString
        
        var displayText = leg.destination?.parent?.parent?.name ?? leg.destination?.parent?.name ?? emptyString
        
        if let range = displayText.range(of: parentParentName) {
            displayText.removeSubrange(range)
        }
        
        if let range = displayText.range(of: ddisassembledName) {
            displayText.removeSubrange(range)
        }
        
        if leg.transportation.product.name == .footpath || leg.transportation.product.name == .FootPath || leg.transportation.product.name == .arabFootpath {
            displayText = leg.destination?.disassembledName ?? leg.destination?.name ?? emptyString
        }

        
        var timeDifferene: TimeDifference = .noTime
        if departureTime == emptyString {
            timeDifferene = .noTime
        } else {
            if arrivalTimeDifference > 0 {
                timeDifferene = .delay
                departureTime = arrivalEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
            } else if arrivalTimeDifference < 0 {
                departureTime = arrivalEstimatedTime.toString(withFormat: Constants.timeFormatForTwentyFour, timeZone: .AST)
                timeDifferene = .early
            } else {
                timeDifferene = .same
            }
        }
        
        let isRequiredNewLine = departureTime == emptyString ? false: true
        let isWalking = leg.transportation.product.name == .footpath || leg.transportation.product.name == .FootPath || leg.transportation.product.name == .arabFootpath ? true : false
        let secondString = getAttributedStringForTime(time: departureTime, parentName: displayText, timeDifference: timeDifferene, isTrasportModeWalking: isWalking)
        
        var disassembledName = leg.destination?.disassembledName ?? ""
        
        if productName == .BUS || productName == .bus || productName == .community || productName == .arabBus {
            disassembledName = leg.destination?.disassembledName ?? leg.destination?.name ?? leg.destination?.parent?.name ?? emptyString
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecBold.sixteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        let disassembleAttr = NSMutableAttributedString(string: disassembledName, attributes: attributes)
        
        if disassembledName != "" {
            if isRequiredNewLine {
                disassembleAttr.append(NSMutableAttributedString(string: " \n"))
                disassembleAttr.append(secondString)
                return (disassembleAttr, isRequiredNewLine)
            } else {
                disassembleAttr.append(NSMutableAttributedString(string: ", "))
                disassembleAttr.append(secondString)
                return (disassembleAttr, isRequiredNewLine)
            }
        } else {
            return (secondString, isRequiredNewLine)
        }
    }
    
    private static func getDateDiff(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.minute, Calendar.Component.second], from: start, to: end)
        return dateComponents.minute ?? 0
    }
    
    private static func getAttributedStringForTime(time: String, parentName: String, timeDifference: TimeDifference, isTrasportModeWalking: Bool) -> NSMutableAttributedString {
        
        let parentAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecNews.fourteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecNews.fourteen,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        
        let earlyAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.fourteen,
            NSAttributedString.Key.foregroundColor: isTrasportModeWalking ? Colors.textColor: Colors.textColor
          ]
        //            NSAttributedString.Key.foregroundColor: isTrasportModeWalking ? Colors.textColor: Colors.newGreen

        
        let delayAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.fourteen,
            NSAttributedString.Key.foregroundColor: isTrasportModeWalking ? Colors.textColor: Colors.textColor
          ]
        //            NSAttributedString.Key.foregroundColor: isTrasportModeWalking ? Colors.textColor: Colors.textErrorColor

        var timeAttr = NSMutableAttributedString(string: time, attributes: attributes)
        let parentAttr = NSMutableAttributedString(string: parentName, attributes: parentAttributes)
        if timeDifference != .noTime {
            if timeDifference == .delay {
                timeAttr = NSMutableAttributedString(string: time, attributes: delayAttributes)
            } else if timeDifference == .early {
                timeAttr = NSMutableAttributedString(string: time, attributes: earlyAttributes)
            }
        }
        
        let emptySpace = NSMutableAttributedString(string: " ")
        if timeDifference == .noTime {
            return parentAttr
        } else {
            timeAttr.append(emptySpace)
            timeAttr.append(parentAttr)
            return timeAttr
        }
    }
}
