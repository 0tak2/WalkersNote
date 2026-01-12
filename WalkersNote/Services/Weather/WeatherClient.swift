//
//  WeatherClient.swift
//  WalkersNote
//
//  Created by 임영택 on 1/12/26.
//

import Foundation
import ComposableArchitecture
import WeatherKit
import CoreLocation

final class WeatherClient {
  var attribution: WeatherAttribution {
    get async throws {
      try await repository.attribution
    }
  }
  
  private let repository: WeatherRepositoryProtocol
  
  init(repository: WeatherRepositoryProtocol) {
    self.repository = repository
  }
  
  func fetchWeather(for location: CLLocation) async throws -> Weather {
    try await repository.weather(for: location)
  }
}

protocol WeatherRepositoryProtocol {
  var attribution: WeatherAttribution { get async throws }
  func weather(for location: CLLocation) async throws -> Weather
}

extension WeatherClient: DependencyKey {
  static var liveValue: WeatherClient {
    return WeatherClient(repository: WeatherService.shared)
  }
}

extension DependencyValues {
  var weatherClient: WeatherClient {
    get { self[WeatherClient.self] }
    set { self[WeatherClient.self] = newValue }
  }
}
