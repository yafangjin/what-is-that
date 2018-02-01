//
//  LocationFinder.swift
//  whatisthat
//
//  Created by 靳亚芳 on 12/11/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double)
    func locationNotFound()
}

class LocationFinder: NSObject {
    let locationManager = CLLocationManager()
    
    var delegate: LocationFinderDelegate?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func findLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationNotFound()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .authorizedAlways:
            //do nothing - app can't get to this state
            break
        }
    }
}

extension LocationFinder: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        delegate?.locationFound(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        else {
            delegate?.locationNotFound()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        delegate?.locationNotFound()
    }
}

