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
final class MapViewModel {
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
  var currentAddress: String?
  var authState: LocationAuthorizationState
  
  @ObservationIgnored
  private var locationService: LocationService

  @ObservationIgnored
  private var cameraPositionPrepared = false
  
  @ObservationIgnored
  private static let fallbackCoordinator = CLLocationCoordinate2D(
    latitude: 37.571648599,
    longitude: 126.976372775
  )
  
  private var locationUpdateTask: Task<Void, Never>?
  private var authStateUpdateTask: Task<Void, Never>?
  private var addressUpdateTask: Task<Void, Never>?

  init(locationService: LocationService = LocationService()) {
    self.locationService = locationService
    self.authState = locationService.locationAuthState
    
    locationUpdateTask = Task { @MainActor [weak self] in
      for await location in locationService.locationStream {
        self?.currentLocation = location
      }
    }
    
    authStateUpdateTask = Task { @MainActor [weak self] in
      for await authState in locationService.locationAuthStream {
        self?.authState = authState
      }
    }
    
    addressUpdateTask = Task { @MainActor [weak self] in
      for await currentAddress in locationService.addressStream {
        self?.currentAddress = currentAddress
      }
    }
  }
  
  deinit {
    locationUpdateTask?.cancel()
    authStateUpdateTask?.cancel()
    addressUpdateTask?.cancel()
  }
}

extension MapViewModel {
  
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
