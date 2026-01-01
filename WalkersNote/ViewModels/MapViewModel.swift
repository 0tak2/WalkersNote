//
//  MapViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 1/1/26.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

@Observable
final class MapViewModel: NSObject {
  var temperatureLabelText: String = ""
  var weatherKitLegalUrl: URL?
  var weatherKitLightImageUrl: URL?
  var weatherKitDarkImageUrl: URL?
  var showWeatherKitLegalPage: Bool = false

  var currentLocation: CLLocation? {
    didSet {
      if !cameraPositionPrepared,
        let currentLocation = currentLocation
      {
        cameraPosition = MapCameraPosition.region(
          MKCoordinateRegion(
            center: currentLocation.coordinate,
            span: currentCameraSpan
          )
        )
        cameraPositionPrepared.toggle()
      }
    }
  }
  var cameraPosition: MapCameraPosition = MapCameraPosition.region(
    MKCoordinateRegion(
      center: fallbackCoordinator,
      latitudinalMeters: 200,
      longitudinalMeters: 200
    )
  )
  var currentCameraSpan = MKCoordinateSpan(
    latitudeDelta: 0.002,
    longitudeDelta: 0.002
  )
  var currentAddress: String = ""
  var coreLocationUnauthorized: Bool = false

  @ObservationIgnored
  private let locationManager: CLLocationManager

  @ObservationIgnored
  private static let fallbackCoordinator = CLLocationCoordinate2D(
    latitude: 37.571648599,
    longitude: 126.976372775
  )

  @ObservationIgnored
  private var cameraPositionPrepared = false

  @ObservationIgnored
  private var updateLocationTimer: Timer?

  init(locationManager: CLLocationManager = CLLocationManager()) {
    self.locationManager = locationManager
    super.init()

    locationManager.delegate = self

    startIntervalJob()
  }
}

extension MapViewModel {
  // MARK: - Life Cycles
  
  func viewAppeared() {
    locationManager.requestWhenInUseAuthorization()
  }
  
  // MARK: - User Intents

  func locationButtonTapped() {
    if let currentLocation = currentLocation {
      cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
          center: currentLocation.coordinate,
          span: currentCameraSpan
        )
      )
    }
  }
}

extension MapViewModel {
  // MARK: - Internal Methods

  private func startIntervalJob() {
    Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) {
      [weak self] timer in
      self?.currentLocation = self?.locationManager.location
    }
  }
}

extension MapViewModel: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse {
      currentLocation = manager.location
    } else if manager.authorizationStatus == .denied {
      coreLocationUnauthorized = true
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    if let location = locations.last {
      currentLocation = location
    }
  }
}
