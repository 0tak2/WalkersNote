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
import WeatherKit

final class MainViewModel: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private static let fallbackCoordinator = CLLocationCoordinate2D(latitude: 37.571648599, longitude: 126.976372775)
    private var cameraPositionPreapred = false
    
    private let pedometer = CMPedometer()
    
    private let weatherService = WeatherService.shared
    private var lastWeatherFor: CLLocation?
    @Published var lastWeather: Weather? {
        didSet {
            guard let currentWeather = lastWeather?.currentWeather else { return }
            
            let roundedTemp = Int(round(currentWeather.temperature.value * 10) / 10)
            
            temperatureLabelText = "\(roundedTemp)\(currentWeather.temperature.unit.symbol)"
        }
    }
    @Published var temperatureLabelText: String = ""
    @Published var weatherKitLegalUrl: URL?
    @Published var weatherKitLightImageUrl: URL?
    @Published var weatherKitDarkImageUrl: URL?
    @Published var showWeatherKitLegalPage: Bool = false
    
    @Published var currentLocation: CLLocation? {
        didSet {
            if !cameraPositionPreapred,
               let currentLocation = currentLocation {
                cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
                cameraPositionPreapred.toggle()
            }
        }
    }
    @Published var cameraPosition: MapCameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: fallbackCoordinator, latitudinalMeters: 200, longitudinalMeters: 200))
    @Published var stepCount: Int = 0
    @Published var currentAddress: String = ""
    @Published var coreLocationUnauthorized: Bool = false
    
    @Published var presentBottomSheet: Bool = false
    
    override init () {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        
        if CMPedometer.isStepCountingAvailable() {
            getTodayStepCount()
        }
        
        startIntervalJob()
        
        Task { @MainActor in
            let weatherKitAttribution = try? await weatherService.attribution
            weatherKitLightImageUrl = weatherKitAttribution?.combinedMarkLightURL
            weatherKitDarkImageUrl = weatherKitAttribution?.combinedMarkDarkURL
            weatherKitLegalUrl = weatherKitAttribution?.legalPageURL
        }
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
        currentLocation = location
        
        guard let location = location else { return }
        
        Task {
            await updateAddress(location)
            await updateWeather(location)
        }
    }
    
    private func updateAddress(_ location: CLLocation) async {
        let geocoder = CLGeocoder()
        let placemarks = try? await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks?.first {
            await MainActor.run {
                currentAddress = "\(placemark.locality ?? "") \(placemark.thoroughfare ?? "")"
            }
        }
    }
    
    private func updateWeather(_ location: CLLocation) async {
        var needToUpdateWeather: Bool = false
        if let lastWeatherFor = lastWeatherFor,
           let lastWeather = lastWeather { // 이전에 업데이트 됨
            if location.distance(from: lastWeatherFor) > 1000
                || lastWeather.currentWeather.metadata.expirationDate < Date() { // 1km 이상 떨어진 지역이거나 만료된 날씨
//                    print("distance: \(location.distance(from: lastWeatherFor))")
//                    print("expiration: \(lastWeather.currentWeather.metadata.expirationDate), now: \(Date())")
                needToUpdateWeather = true
            }
        } else { // 최초 업데이트
            needToUpdateWeather = true
        }
        
        guard needToUpdateWeather else {
            print("skip update weather.")
            return
        }
        
        do {
            let weather = try await weatherService.weather(for: location)
            await MainActor.run {
                lastWeather = weather
            }
            lastWeatherFor = currentLocation
        } catch {
            print("An error occured during fetch weather... \(error.localizedDescription)")
        }
    }
    
    func locationButtonTapped() {
        if let currentLocation = currentLocation {
            cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: currentLocation.coordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        }
    }
    
    func weatherImageTapped() {
        showWeatherKitLegalPage = true
    }
}

extension MainViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            updateLocation(to: manager.location)
        } else if manager.authorizationStatus == .denied {
            coreLocationUnauthorized = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            updateLocation(to: location)
        }
    }
}
