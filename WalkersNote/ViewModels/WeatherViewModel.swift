//
//  WeatherViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 1/1/26.
//

import CoreLocation
import Foundation
import WeatherKit

@Observable
final class WeatherViewModel {
  var lastWeather: Weather? {
    didSet {
      guard let currentWeather = lastWeather?.currentWeather else { return }

      let roundedTemp = Int(round(currentWeather.temperature.value * 10) / 10)

      temperatureLabelText =
        "\(roundedTemp)\(currentWeather.temperature.unit.symbol)"
    }
  }
  var temperatureLabelText: String = ""
  var weatherKitLegalUrl: URL?
  var weatherKitLightImageUrl: URL?
  var weatherKitDarkImageUrl: URL?
  var showWeatherKitLegalPage: Bool = false
  
  @ObservationIgnored
  private let locationService: LocationService
  
  @ObservationIgnored
  private let weatherService: WeatherService
  
  @ObservationIgnored
  private var lastWeatherFor: CLLocation?
  
  @ObservationIgnored
  private var locationUpdateTask: Task<Void, Never>?

  init(
    locationService: LocationService,
    weatherService: WeatherService = WeatherService.shared
  ) {
    self.locationService = locationService
    self.weatherService = weatherService
    
    locationUpdateTask = Task { @MainActor [weak self] in
      for await location in locationService.locationStream {
        await self?.updateWeather(for: location)
      }
    }
  }
  
  deinit {
    locationUpdateTask?.cancel()
  }
}

extension WeatherViewModel {
  // MARK: - Internal Logics
  
  func updateWeather(for location: CLLocation) async {
    var needToUpdateWeather: Bool = false
    if let lastWeatherFor = lastWeatherFor,
      let lastWeather = lastWeather
    {  // 이전에 업데이트 됨
      if location.distance(from: lastWeatherFor) > 1000
        || lastWeather.currentWeather.metadata.expirationDate < Date()
      {  // 1km 이상 떨어진 지역이거나 만료된 날씨
        //                    print("distance: \(location.distance(from: lastWeatherFor))")
        //                    print("expiration: \(lastWeather.currentWeather.metadata.expirationDate), now: \(Date())")
        needToUpdateWeather = true
      }
    } else {  // 최초 업데이트
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
      lastWeatherFor = location
    } catch {
      print(
        "An error occured during fetch weather... \(error.localizedDescription)"
      )
    }
  }
}

extension WeatherViewModel {
  // MARK: - User Intents
  
  func weatherImageTapped() {
      showWeatherKitLegalPage = true
  }
}
