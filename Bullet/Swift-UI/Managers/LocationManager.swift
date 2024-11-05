//
//  LocationManager.swift
//  DiscoverPage
//
//  Created by Yeshua Lagac on 6/7/22.
//

import UIKit

import MapKit
import CoreLocation

class LocationManager: NSObject,CLLocationManagerDelegate, ObservableObject {
    
    @Published var userCoordinate : CLLocationCoordinate2D = CLLocationCoordinate2D()
    private let manager = CLLocationManager()
    
    override init() {
        super.init()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        manager.requestWhenInUseAuthorization()
//        manager.startUpdatingLocation()
        userCoordinate = CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        locations.last.map {
//            userCoordinate = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
//        }
    }
}
