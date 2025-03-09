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
    
    private let pedometer = CMPedometer()
    
    @Published var currentLocation: CLLocation? {
        didSet {
            if let currentLocation = currentLocation  {
                cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: MainViewModel.spanMeters, longitudinalMeters: MainViewModel.spanMeters))
            }
        }
    }
    
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: fallbackCoordinator, latitudinalMeters: spanMeters, longitudinalMeters: spanMeters))
    
    @Published var stepCount: Int = 0
    
    @Published var currentAddress: String = ""
    
    override init () {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        
        if CMPedometer.isStepCountingAvailable() {
            getTodayStepCount()
        }
        
        startIntervalJob()
    }
    
    private func getTodayStepCount() {
        pedometer.startUpdates(from: Calendar.current.startOfDay(for: Date()), withHandler: { [weak self] (data, error) in
            if let error = error {
                print("Error occured during getting step count: \(error.localizedDescription)")
            }
            
            if let stepData = data {
                let steps = stepData.numberOfSteps.stringValue
                DispatchQueue.main.async {
                    self?.stepCount = Int(steps) ?? 0
                }
            }
        })
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
            updateLocation(to: locationManager.location)
        }
    }
    
    func updateLocation(to location: CLLocation?) {
        guard let location = location else {
            return
        }
        
        currentLocation = location
        
        Task { @MainActor in
            let geocoder = CLGeocoder()
            let placemarks = try? await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks?.first {
                currentAddress = "\(placemark.locality ?? "") \(placemark.thoroughfare ?? "")"
            }
        }
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            updateLocation(to: manager.location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateLocation(to: location)
        }
    }
}
