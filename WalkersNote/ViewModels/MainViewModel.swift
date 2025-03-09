//
//  MainViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreMotion

final class MainViewModel: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private static let fallbackCoordinator = CLLocationCoordinate2D(latitude: 37.571648599, longitude: 126.976372775)
    private static let spanMeters = 200.0
    
    private var motionManager = CMMotionManager()
    
    @Published var currentLocation: CLLocation? {
        didSet {
            if let currentLocation = currentLocation  {
                cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: MainViewModel.spanMeters, longitudinalMeters: MainViewModel.spanMeters))
            }
        }
    }
    
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: fallbackCoordinator, latitudinalMeters: spanMeters, longitudinalMeters: spanMeters))
    
    @Published var stepCount: Int = 0
    
    override init () {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
    }
    
    func viewAppeared() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startIntervalJob() {
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
    }
    
    @objc func timerHandler() {
        Task { @MainActor in
            print("timer invoked...")
            updateLocation()
        }
    }
    
    @MainActor func updateLocation() {
        currentLocation = locationManager.location
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            currentLocation = manager.location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
        }
    }
}
