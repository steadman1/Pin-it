//
//  LocationManager.swift
//  locationCounter
//
//  Created by Spencer Steadman on 12/25/22.
//

import Foundation
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var location: CLLocation?
    @Published var locations: [CLLocation]

    override init() {
        
        self.locations = []
        
        super.init()
        
        manager.delegate = self
        
        let authInt = manager.authorizationStatus.rawValue
        
        print(authInt)
        
        if authInt >= 3 {
            manager.desiredAccuracy = kCLLocationAccuracyBest
//            manager.distanceFilter = kCLDistanceFilterNone
            manager.distanceFilter = CLLocationDistance(SettingsValues.shared.distanceFilter)
            manager.allowsBackgroundLocationUpdates = authInt == 4
            manager.requestLocation()
        }
        
        manager.distanceFilter = 20
    }

    func requestLocation() {
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status.rawValue >= 3 {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations _locations: [CLLocation]) {
        coordinate = _locations.first?.coordinate
        location = _locations.first
        
        if _locations.count > 0 {
            let radius = 50.0
            let pinLocations = Location.getLocations(array: Location.sharedIDArray.idArray)
            for i in pinLocations {
                if LocationManager.isLocationWithinRadiusOfOther(location1: i.cooridnate,
                                                             location2: coordinate!,
                                                             radius: radius) {
                    
                    if locations.count > 1 &&
                        !(LocationManager.isLocationWithinRadiusOfOther(location1: i.cooridnate,
                                                                        location2: locations[locations.count - 1].coordinate,
                                                                        radius: radius)) {
                        let _ = i.addToCount()
                    } else if locations.count == 0 && i.count == 0 {
                        let _ = i.addToCount()
                    }
                }
            }
            locations.append(location!)
            print("new location update \(locations.count)")
        }
    }
}

extension LocationManager {
    static private func haversine(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        
        let R = 6371e3; // metres
        let φ1 = location1.latitude * .pi / 180; // φ, λ in radians
        let φ2 = location2.latitude * .pi / 180;
        let Δφ = (location2.latitude - location1.latitude) * .pi / 180;
        let Δλ = (location2.longitude - location1.longitude) * .pi / 180;

        let a = sin(Δφ / 2) * sin(Δφ / 2) +
                  cos(φ1) * cos(φ2) *
                  sin(Δλ / 2) * sin(Δλ / 2);
        let c = 2 * atan2(sqrt(a), sqrt(1 - a));

        return R * c; // in metres
    }
    
    static func getTilt(location: CLLocationCoordinate2D, region: MKCoordinateRegion) -> Double {
        let R = 6371e3; // metres
        let φ = R * ((location.longitude - region.center.longitude) * .pi / 180) // φ, λ in radians
        
        let x1 = region.center.latitude - region.span.latitudeDelta / 2
        let x2 = region.center.latitude + region.span.latitudeDelta / 2
        let slope = 1 / (x2 - x1)
        
        return slope * φ / 2600
        
    }
    
    static func isLocationWithinRadiusOfOther(
        location1: CLLocationCoordinate2D,
        location2: CLLocationCoordinate2D,
        radius: Double) -> Bool {
            
            let meters = haversine(location1: location1, location2: location2)
            
            return meters <= radius
    }
    
    static func distanceBetweenLocations(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        
        let meterToMileConstant = 1609.344
        let meters = haversine(location1: location1, location2: location2)
        
        return meters / meterToMileConstant
    }
    
    static func getAddressFromCoordinate(coordinate: CLLocationCoordinate2D,
                                         completion: @escaping (CLPlacemark?) -> Void) {
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: coordinate.latitude,
                                                       longitude: coordinate.longitude)) { (places, error) in
            
            if (error != nil) {
                print("Reverse geocoder failed with an error" + error!.localizedDescription)
               completion(nil)
            } else if places!.count > 0 {
               let place = places![0] as CLPlacemark
               completion(place)
           } else {
               print("Problems with the data received from geocoder.")
               completion(nil)
           }
        }
    }
}

extension CLPlacemark {
    var fullAddress: String? {
        guard let placemark = self as? CLPlacemark else {
            return nil
        }
        return "\(String(describing: placemark.name!)), \(String(describing: placemark.locality!)), \(String(describing: placemark.administrativeArea!)) \(String(describing: placemark.postalCode!))"
    }
}
