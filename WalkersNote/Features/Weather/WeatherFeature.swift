//
//  WeatherFeature.swift
//  WalkersNote
//
//  Created by 임영택 on 1/12/26.
//

import ComposableArchitecture
import CoreLocation
import WeatherKit

@Reducer
struct WeatherFeature {
  @ObservableState
  struct State {
    var lastWeather: Weather?
    var lastLocation: CLLocation?
    var weatherKitLegalInformation: WeatherKitLegalInformation?
    var errorMessage: String?
    @Presents var legalSheetState: WeatherKitLegalPageFeature.State?
  }

  enum Action {
    case onAppear
    case locationUpdated(CLLocation)
    case weatherKitAttributionUpdated(Result<WeatherKitLegalInformation, Error>)
    case weatherUpdated(Result<Weather, Error>)
    case weatherKitLogoTapped
    case legalSheetState(PresentationAction<WeatherKitLegalPageFeature.Action>)
  }

  @Dependency(\.locationService) var locationService
  @Dependency(\.weatherClient) var weatherClient
  @Dependency(\.date.now) var now

  private let locationUpdateThreshold: CLLocationDistance = 1000

  var body: some ReducerOf<Self> {
    Reduce {
      state,
      action in
      switch action {
      case .onAppear:
        return .merge(
          .run { send in
            for await location in self.locationService.locationStream {
              await send(.locationUpdated(location))
            }
          },
          .run { send in
            do {
              let attribution = try await weatherClient.attribution
              await send(
                .weatherKitAttributionUpdated(
                  .success(
                    WeatherKitLegalInformation(
                      legalPageURL: attribution.legalPageURL,
                      lightImageUrl: attribution.combinedMarkLightURL,
                      darkImageUrl: attribution.combinedMarkDarkURL
                    )
                  )
                )
              )
            } catch {
              await send(
                .weatherKitAttributionUpdated(.failure(error))
              )
            }
          }
        )
        
      case let .locationUpdated(newLocation):
        var needToUpdateWeather = false

        if let lastWeather = state.lastWeather,
          let lastLocation = state.lastLocation
        {
          if lastLocation.distance(from: newLocation) > locationUpdateThreshold
            || lastWeather.currentWeather.metadata.expirationDate < now
          {
            // 이전에 불러온 날씨가 일정 거리 이상 떨어진 곳의 것이었거나, 만료되었다면 업데이트한다
            needToUpdateWeather.toggle()
          }
        } else {
          // 이전에 날씨를 불러온 적 없다면 업데이트한다
          needToUpdateWeather.toggle()
        }

        // 다음에는 새 위치로 비교한다
        state.lastLocation = newLocation

        guard needToUpdateWeather else {
          return .none
        }

        return .run { [location = newLocation] send in
          do {
            let newWeather = try await self.weatherClient.fetchWeather(
              for: location
            )
            await send(.weatherUpdated(.success(newWeather)))
          } catch {
            await send(.weatherUpdated(.failure(error)))
          }
        }
        
      case let .weatherKitAttributionUpdated(.success(information)):
        state.weatherKitLegalInformation = information
        return .none
        
      case .weatherKitAttributionUpdated(.failure):
        state.errorMessage = "날씨 법적 정보를 불러오는데 문제가 발생했습니다"
        return .none
        
      case let .weatherUpdated(.success(weather)):
        state.lastWeather = weather
        return .none
        
      case .weatherUpdated(.failure):
        state.errorMessage = "날씨 정보를 불러오는데 문제가 발생했습니다"
        return .none
        
      case .weatherKitLogoTapped:
        state.legalSheetState = WeatherKitLegalPageFeature.State()
        return .none
        
      case .legalSheetState:
        return .none
      }
    }
    .ifLet(\.$legalSheetState, action: \.legalSheetState) {
      WeatherKitLegalPageFeature()
    }
  }
}
