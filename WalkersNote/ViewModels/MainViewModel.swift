 //
//  MainViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import MapKit
import CoreLocation

final class MainViewModel: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private static let fallbackCoordinator = CLLocationCoordinate2D(latitude: 37.571648599, longitude: 126.976372775)
    private static let spanMeters = 200.0
    
    @Published var currentLocation: CLLocation? {
        didSet {
            if let currentLocation = currentLocation  {
                cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: MainViewModel.spanMeters, longitudinalMeters: MainViewModel.spanMeters))
            }
        }
    }
    
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: fallbackCoordinator, latitudinalMeters: spanMeters, longitudinalMeters: spanMeters))
    
    override init () {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
    }
    
    func viewAppeared() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            currentLocation = manager.location
        }
    }
}
