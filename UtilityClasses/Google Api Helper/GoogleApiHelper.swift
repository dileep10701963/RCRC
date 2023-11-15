//
//  GoogleApiHelper.swift
//  RCRC
//
//  Created by Ganesh Shinde on 24/09/20.
//

import UIKit
import Alamofire
import GoogleMaps

class GoogleApiHelper: NSObject {

    static let SharedInstance = GoogleApiHelper()
    private override init() {}

    func fetchFormattedAddress(from location: String, completion : @escaping((_ location: GoogleGeocodeResponse?) -> Void)) {

        let endPoint = EndPoint(baseUrl: .googleMap, methodName: URLs.googleGeocode, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        var params = GoogleGeocodeRequest()
        params.latlng = location
        params.language = currentLanguage.rawValue
        
        if let networkReachabilityManager = NetworkReachabilityManager(), !networkReachabilityManager.isReachable {
            completion(nil)
        }
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: params, res: GoogleGeocodeResponse.self) { result in
            if case let .success(response) = result {
                completion(response)
            }
        }
    }

    func getDistance(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let endPoint = EndPoint(baseUrl: .googleMap, methodName: URLs.distanceMatrix, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DistanceMatrixRequest(origins: origin.latitude.string + "," + origin.longitude.string, destinations: destination.latitude.string + "," + destination.longitude.string)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: parameters, res: DistanceMatrix.self) { result in
            switch result {
            case let .success(distanceData):
                completion(distanceData.rows?.first?.elements?.first?.distance?.text ?? "0.0 KM")
            case .failure:
                completion("0.0 KM")
            }
        }
    }
}

extension GMSMapView {

    func drawPolygon(with path: GMSMutablePath) {

        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: path)
       // polygon.fillColor = .blue
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05)
        polygon.strokeColor = UIColor.init(hue: 210, saturation: 88, brightness: 84, alpha: 1)
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = self

    }

    func drawPolyLine(with path: GMSMutablePath) {

        // Create the polygon, and assign it to the map.
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05)
        polygon.strokeColor = UIColor.init(hue: 210, saturation: 88, brightness: 84, alpha: 1)
        // polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = self

    }

    func drawRoute(with address: [CLLocationCoordinate2D], color: UIColor, isFootPath: Bool) {

        let path = GMSMutablePath()
        for location in address {
            path.add(location)
        }
    }
    func drawRoute(with path: GMSMutablePath, color: UIColor, isFootPath: Bool) {

        let route = GMSPolyline(path: path)
        if isFootPath {
            let polyline = GMSPolyline(path: path)
            let strokeStyles = [GMSStrokeStyle.solidColor(Colors.mapWalkingGray), GMSStrokeStyle.solidColor(.clear)]
            let strokeLengths = [NSNumber(value: Constants.mapRouteStrokeLength), NSNumber(value: Constants.mapRouteStrokeLength)]
              polyline.spans = GMSStyleSpans(path, strokeStyles, strokeLengths, .rhumb)
            polyline.map = self
            polyline.strokeWidth = Constants.mapRouteStrokeWidth
        } else {
            route.strokeColor = color
            route.strokeWidth = Constants.mapRouteStrokeWidth
            route.map = self
        }
    }

    func addMarkerOn(location address: CLLocationCoordinate2D, markerImage: UIImage, imageOffset: CGPoint? = nil) {

        let sourceMarker = GMSMarker()
        sourceMarker.position = address
        sourceMarker.icon = markerImage
        if let imageOffset = imageOffset {
            sourceMarker.groundAnchor = imageOffset
        }
        sourceMarker.map = self
    }

    func isLocationOnPath(point: CLLocationCoordinate2D?, path: GMSPath?) -> Bool {
        if let point = point, let path = path {
            return GMSGeometryIsLocationOnPathTolerance(point, path, true, Constants.distanceTolerance)
        }
        return false
    }

    func addMarkerAt(location address: CLLocationCoordinate2D, markerImage: UIImage) -> GMSMarker {

        let sourceMarker = GMSMarker()
        sourceMarker.position = address
        sourceMarker.icon = markerImage
        sourceMarker.map = self
        return sourceMarker
    }
}
