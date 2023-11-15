//
//  TripCellViewModel.swift
//  RCRC
//
//  Created by Errol on 28/05/21.
//

import UIKit

struct TravelIconModel {
    var index: Int
    var count: Int
}


/// Trip Cell View Model Configuration
/// - Parameter journey: trip.journeys[index]
class TripCellViewModel {
    var travelTime: String?
    var originAddress: NSMutableAttributedString?
    var destinationAddress: NSMutableAttributedString?
    var travelCost: String?
    var transportModes: [UIView]?
    var mapCellViewModel: MapCellViewModel?
    var routeCellViewModels: [RouteCellViewModel] = []
    var originDestinalTime: NSMutableAttributedString?

    init(journey: Journey?) {
        self.configureViewModel(journey)
    }

    private func configureViewModel(_ journey: Journey?) {
        guard let journey = journey else { return }
        let firstLeg = journey.legs?.first
        let lastLeg = journey.legs?.last
        let isBusOrigin = firstLeg??.transportation.product.name == .bus || firstLeg??.transportation.product.name == .BUS || firstLeg??.transportation.product.name == .community || firstLeg??.transportation.product.name == .arabBus
        let isBusDestination = lastLeg??.transportation.product.name == .bus || lastLeg??.transportation.product.name == .BUS || lastLeg??.transportation.product.name == .community || lastLeg??.transportation.product.name == .arabBus
        
        var originAddress = isBusOrigin ? firstLeg??.origin?.name : firstLeg??.origin?.name
        originAddress = originAddress?.replacingOccurrences(of: "Riyadh,", with: "")
        
        let originSubAddress = isBusOrigin ? firstLeg??.origin?.parent?.parent?.name : firstLeg??.origin?.parent?.name

        var destinationAddress = isBusDestination ? lastLeg??.destination?.name ?? lastLeg??.destination?.name ?? lastLeg??.destination?.parent?.name : lastLeg??.destination?.parent?.parent?.name ?? lastLeg??.destination?.name
        destinationAddress = destinationAddress?.replacingOccurrences(of: "Riyadh,", with: "")
        
        let destinationSubaddress = isBusDestination ? lastLeg??.destination?.parent?.parent?.name : lastLeg??.destination?.parent?.name

        let travelCost = "\(journey.fare?.tickets?.first??.properties?.priceTotalFare ?? "0")\(Constants.currencyTitle.localized)"

        let timeTaken = journey.legs?.compactMap({$0}).reduce(0, { $0 + ($1.duration?.minutes ?? 0) })
        var travelTime: String = ""
        if currentLanguage == .arabic {
            travelTime = String(format: "عدد (%@) دقيقة", arguments: ["\(timeTaken ?? 0)"])
        } else {
            travelTime = "\(timeTaken ?? 0) \(Constants.minutesRoute.localized)"
        }
        
        let transportModeImages = journey.legs?.map({ leg -> UIImageView in
            let productName = leg?.transportation.product.name
            switch productName {
            case .bus, .BUS, .community, .arabBus: return createUIImageView(image: Images.routeBusTransportMode!, productName: productName ?? .bus)
            case .footpath, .FootPath, .arabFootpath: return createUIImageView(image: Images.walkingIcon!, changeColor: true, productName: productName ?? .footpath)
                
            case .cycling: return createUIImageView(image: Images.transportModeCareem!, productName: productName ?? .cycling)
            case .taxi: return createUIImageView(image: Images.transportModeUber!, productName: productName ?? .taxi)
            default: return UIImageView(image: UIImage())
            }
        })
        
        self.originDestinalTime = self.getOriginDestinalTime(journey)
        
        if currentLanguage == .arabic {
            self.travelTime = travelTime == "عدد (0) دقيقة" ? nil: travelTime
        } else {
            self.travelTime = travelTime == "0 \(Constants.minutesRoute.localized)" ? nil : travelTime
        }
        
        self.originAddress = Utilities.shared.getAttributedText(originAddress ?? "", "", Fonts.CodecBold.thirteen, Fonts.CodecRegular.twelve, Colors.textColor, false, Colors.textColor)
        self.destinationAddress = Utilities.shared.getAttributedText(destinationAddress ?? "", "", Fonts.CodecBold.thirteen, Fonts.CodecRegular.twelve, Colors.textColor, false, Colors.textColor)
        self.travelCost = travelCost == "0\(Constants.currencyTitle.localized)" ? nil : travelCost
        
        var viewsArray: [UIView] = []
        if let transportModeImages = transportModeImages {
            
            var travelIconModels: [TravelIconModel] = []
            for i in 0..<transportModeImages.count {
                var travelIconModel = TravelIconModel(index: i, count: 1)
                for j in (i+1)..<transportModeImages.count {
                    if (transportModeImages[i].image! == transportModeImages[j].image) {
                        travelIconModel.count += 1
                    } else {
                        break
                    }
                }
                travelIconModels.append(travelIconModel)
            }
            
            if travelIconModels.contains(where: {$0.count > 1}) {
                
                var result = ""
                var counter = 1
                
                for index in 0 ..< transportModeImages.count {
                    if index == transportModeImages.count - 1 {
                        if transportModeImages[index].image! == Images.routeBusTransportMode! {
                            result += "Bus" + "\(counter),"
                        } else {
                            result += "Walk" + "\(counter),"
                        }
                    }else if transportModeImages[index].image! == transportModeImages[index + 1].image! {
                        counter += 1
                    } else {
                        if transportModeImages[index].image! == Images.routeBusTransportMode! {
                            result += "Bus" + "\(counter),"
                        } else {
                            result += "Walk" + "\(counter),"
                        }
                        counter = 1
                    }
                }
                
                let values = result.components(separatedBy: ",")
                var imagesArray: [UIImageView] = []
                
                for value in values where value != "" {
                    if value.contains("Bus") && Int(String(value.last ?? "1")) ?? 1 > 1 {
                        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)))
                        label.text = "x\(value.last ?? "1" )"
                        label.textColor = .black
                        label.textAlignment = .left
                        label.font = Fonts.CodecBold.twentyOne
                        if currentLanguage == .arabic {
                            let imageViewBus = createUIImageView(image: Images.routeBusTransportMode!, productName: .arabBus)
                            imagesArray.append(imageViewBus)
                        } else {
                            let imageViewBus = createUIImageView(image: Images.routeBusTransportMode!, productName: .bus)
                            imagesArray.append(imageViewBus)
                        }
                        let imageViewCount = createUIImageView(image: labelToImage(label)!, productName: .taxi)
                        imagesArray.append(imageViewCount)
                    } else {
                        let imageView = currentLanguage == .english ? createUIImageView(image: Images.walkingIcon!, changeColor: true, productName: .footpath) : createUIImageView(image: Images.walkingIcon!, changeColor: true, productName: .arabFootpath)
                        imagesArray.append(imageView)
                    }
                }
                viewsArray = imagesArray
            } else {
                viewsArray = transportModeImages
            }
        }
        
        self.transportModes = viewsArray
        self.mapCellViewModel = MapCellViewModel(journey: journey)
        if let legs = journey.legs, legs.isNotEmpty {
            self.configureRouteViewModels(legs)
        }
    }
    
    func getResultBus(results: String) {
        
        let values = results.components(separatedBy: ",")
        
    }
    
    func labelToImage(_ label: UILabel) -> UIImage? {
        let size = label.frame.size.applying(.init(scaleX: 20, y: 20))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        label.frame.size = size
        label.font = label.font.withSize(label.font.pointSize * 16)
        defer { UIGraphicsEndImageContext() }
        label.draw(.init(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func getOriginDestinalTime(_ journey: Journey) -> NSMutableAttributedString {
        
        let firstLeg = journey.legs?.first
        let lastLeg = journey.legs?.last
        
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.twelve,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        
        let earlyAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.ten,
            NSAttributedString.Key.foregroundColor: Colors.textColor
          ]
        //            NSAttributedString.Key.foregroundColor: Colors.newGreen

        
        let delayAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.CodecRegular.ten,
            NSAttributedString.Key.foregroundColor: Colors.textErrorColor
          ]
        
        let departurePlannedTime = firstLeg??.origin?.departureTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let departureEstimatedTime = firstLeg??.origin?.departureTimeEstimated?.toDate(timeZone: .AST) ?? Date()
        
        let departureTimeDifference = self.getDateDiff(start: departurePlannedTime, end: departureEstimatedTime)
        let departureTime = departurePlannedTime.toStringCurrentTimeZone(withFormat: Constants.timeFormat) ?? emptyString
        let departureTimeAttributedString = NSMutableAttributedString(string: departureTime, attributes: attributes)
      
        if departureTimeDifference != 0 {
            if departureTimeDifference >= 4 {
                let delayTime = NSMutableAttributedString(string: " + \(abs(departureTimeDifference)) \(Constants.smallMin.localized)", attributes: delayAttributes)
                departureTimeAttributedString.append(delayTime)
            } else {
                let earlyTime = NSMutableAttributedString(string: " - \(abs(departureTimeDifference)) \(Constants.smallMin.localized)", attributes: earlyAttributes)
                departureTimeAttributedString.append(earlyTime)
            }
        }
        
        let arrivalPlannedTime = lastLeg??.destination?.arrivalTimePlanned?.toDate(timeZone: .AST) ?? Date()
        let arrivalEstimatedTime = lastLeg??.destination?.arrivalTimeEstimated?.toDate(timeZone: .AST) ?? Date()
        let arrivalTime = lastLeg??.destination?.arrivalTimePlanned?.toDate(timeZone: .AST)?.toStringCurrentTimeZone(withFormat: Constants.timeFormat) ?? emptyString
        
        let arrivalTimeAttributedString = NSMutableAttributedString(string: arrivalTime, attributes: attributes)
        let arrivalTimeDifference = self.getDateDiff(start: arrivalPlannedTime, end: arrivalEstimatedTime)
        if arrivalTimeDifference != 0 {
            if arrivalTimeDifference >= 4 {
                let delayTime = NSMutableAttributedString(string: " + \(abs(arrivalTimeDifference)) \(Constants.smallMin.localized)", attributes: delayAttributes)
                arrivalTimeAttributedString.append(delayTime)
            } else {
                let earlyTime = NSMutableAttributedString(string: " - \(abs(arrivalTimeDifference)) \(Constants.smallMin.localized)", attributes: earlyAttributes)
                arrivalTimeAttributedString.append(earlyTime)
            }
        }
                
        let arrivalAttributed = NSMutableAttributedString(string: " - \(Constants.arrivalTime.localized) ", attributes: attributes)
        departureTimeAttributedString.append(arrivalAttributed)
        departureTimeAttributedString.append(arrivalTimeAttributedString)
    
        return departureTimeAttributedString
        
    }
    
    private func createUIImageView(image: UIImage, changeColor: Bool = false, productName: ProductName) -> UIImageView {
        
        let imageView = UIImageView(image: image)
        if changeColor {
            imageView.tintColor = Colors.ptIconTintColor
        }
        
        var widthOfImageView: CGFloat!
        var heightOfImageView: CGFloat!
        
        switch productName {
        case .bus, .BUS, .community, .arabBus:
            widthOfImageView = 19
            heightOfImageView = 19
        case .footpath, .FootPath, .arabFootpath:
            widthOfImageView = 11
            heightOfImageView = 19
        default:
            widthOfImageView = 18.0
            heightOfImageView = 18.0
        }
        
        imageView.widthAnchor.constraint(equalToConstant: widthOfImageView).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: heightOfImageView).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    private func createUIView(imageView: UIImageView) -> UIView {
        
        let view = UIView()
        let imageView = UIImageView(image: imageView.image!)
        
        var widthOfUIView: CGFloat!
        var heightOfUIView: CGFloat!
        
        if imageView.image! == Images.routeBusTransportMode! {
            widthOfUIView = 19
            heightOfUIView = 19
        } else {
            widthOfUIView = 11
            heightOfUIView = 19
        }
        
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: widthOfUIView).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: heightOfUIView).isActive = true
        imageView.contentMode = .scaleAspectFit
        view.widthAnchor.constraint(equalToConstant: widthOfUIView).isActive = true
        view.heightAnchor.constraint(equalToConstant: heightOfUIView).isActive = true
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }

    private func configureRouteViewModels(_ legs: [Leg?]) {
        if legs.count > 1 {
            let routeCellViewModels = legs
                .compactMap({$0})
                .enumerated()
                .map({ index, leg -> RouteCellViewModel in
                    switch index {
                    case legs.startIndex:
                        return RouteCellViewModel(originLeg: leg)
                    case legs.endIndex - 1:
                        return RouteCellViewModel(destinationLeg: leg)
                    default:
                        return RouteCellViewModel(middleLeg: leg)
                    }
                })
            self.routeCellViewModels = routeCellViewModels
        } else {
            guard let leg = legs[0] else { return }
            self.routeCellViewModels = [RouteCellViewModel(singleLeg: leg)]
        }
    }
    
    func getDateDiff(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([Calendar.Component.minute, Calendar.Component.second], from: start, to: end)
        return dateComponents.minute ?? 0
    }
}
