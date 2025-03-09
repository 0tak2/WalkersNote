//
//  MainViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import MapKit
import CoreLocation
import HealthKit

final class MainViewModel: NSObject, ObservableObject {
    private let locationManager: CLLocationManager
    private static let fallbackCoordinator = CLLocationCoordinate2D(latitude: 37.571648599, longitude: 126.976372775)
    private static let spanMeters = 200.0
    
    private var healthStore: HKHealthStore?
    
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
        
        Task { @MainActor in
            await initHealthStore()
            await readStepCount()
        }
    }
    
    func initHealthStore() async {
        let allTypes: Set = [
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.stepCount)
        ]
        
        do {
            if HKHealthStore.isHealthDataAvailable() {
                healthStore = HKHealthStore()
                try await healthStore?.requestAuthorization(toShare: allTypes, read: allTypes)
            }
        } catch {
            fatalError("An unexpected error occurred while requesting authorization: \(error.localizedDescription)")
        }
    }
    
    func viewAppeared() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getStepCountQuery() -> NSPredicate {
        let filterManualDataPredicate = NSPredicate(format: "metadata.%K != YES", HKMetadataKeyWasUserEntered) // ref: https://stackoverflow.com/a/52157559
        
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: Date())
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        let todayPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [filterManualDataPredicate, todayPredicate])
        return compoundPredicate
    }
    @MainActor func readStepCount() async {
        // Type
        let stepType = HKQuantityType(.stepCount)
        
        // Query
        let sumOfStepsQuery = HKStatisticsQueryDescriptor(predicate: .quantitySample(type: stepType, predicate: getStepCountQuery()),
                                                          options: .cumulativeSum)
        
        // Execute
        var result: HKStatistics?
        do {
            result = try await sumOfStepsQuery.result(for: healthStore!)
        } catch {
            print("An error occured: \(error.localizedDescription)")
        }
        
        // Update
        if let result = result,
           let stepCountAsDouble = result.sumQuantity()?.doubleValue(for: .count()) {
            stepCount = Int(stepCountAsDouble)
        }
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
