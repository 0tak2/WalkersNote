//
//  LocationService.swift
//  WalkersNote
//
//  Created by 임영택 on 1/1/26.
//

import CoreLocation
import Foundation

final class LocationService: NSObject {
  private let locationManager: CLLocationManager

  // MARK: 현재 위치
  private(set) var currentLocation: CLLocation? {
    didSet {
      guard let currentLocation else { return }
      locationContinuation.yield(currentLocation)
    }
  }
  let locationStream: AsyncStream<CLLocation>
  private let locationContinuation: AsyncStream<CLLocation>.Continuation

  // MARK: 현재 주소
  private(set) var currentAddress: String? {
    didSet {
      addressContinuation.yield(currentAddress)
    }
  }
  let addressStream: AsyncStream<String?>
  private let addressContinuation: AsyncStream<String?>.Continuation

  // MARK: 위치 권한
  private(set) var locationAuthState: LocationAuthorizationState = .unknown {
    didSet {
      locationAuthContinuation.yield(locationAuthState)
    }
  }
  let locationAuthStream: AsyncStream<LocationAuthorizationState>
  private let locationAuthContinuation:
    AsyncStream<LocationAuthorizationState>.Continuation

  // MARK: 타이머
  private var updateLocationTimer: Timer?

  init(locationManager: CLLocationManager = CLLocationManager()) {
    self.locationManager = locationManager

    let (locationStream, locationContinuation) = AsyncStream.makeStream(
      of: CLLocation.self
    )
    self.locationStream = locationStream
    self.locationContinuation = locationContinuation

    let (addressStream, addressContinuation) = AsyncStream.makeStream(
      of: String?.self
    )
    self.addressStream = addressStream
    self.addressContinuation = addressContinuation

    let (authStream, authContinuation) = AsyncStream.makeStream(
      of: LocationAuthorizationState.self
    )
    self.locationAuthStream = authStream
    self.locationAuthContinuation = authContinuation

    super.init()

    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()

    startTimer()
  }

  deinit {
    updateLocationTimer?.invalidate()
  }
}

extension LocationService {
  private func startTimer() {
    updateLocationTimer = Timer.scheduledTimer(
      withTimeInterval: 10.0,
      repeats: true
    ) { [weak self] timer in
      guard let self,
        let location = self.locationManager.location
      else { return }

      self.currentLocation = location
    }
  }
  
  private func updateLocation(for location: CLLocation) {
    currentLocation = location
    Task {
      await updateAddress(for: location)
    }
  }
  
  private func updateAddress(for location: CLLocation) async {
    let geocoder = CLGeocoder()
    let placemarks = try? await geocoder.reverseGeocodeLocation(location)
    if let placemark = placemarks?.first {
      await MainActor.run {
        currentAddress =
          "\(placemark.locality ?? "") \(placemark.thoroughfare ?? "")"
      }
    }
  }
}

extension LocationService: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedWhenInUse
      || manager.authorizationStatus == .authorizedAlways
    {
      locationAuthState = .authrorized
      currentLocation = manager.location
    } else {
      locationAuthState = .notAuthorized
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
