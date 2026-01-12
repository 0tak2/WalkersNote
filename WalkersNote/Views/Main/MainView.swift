//
//  MainView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import ComposableArchitecture
import CoreLocation
import MapKit
import SwiftUI

struct MainView: View {
  @State var motionViewModel: MotionViewModel
  @State var mapViewModel: MapViewModel
  @State var presentBottomSheet: Bool = false
  let bottomSheetHeightRatio = 0.4
  
  @Bindable var weatherStore: StoreOf<WeatherFeature>
  
  var temperatureLabelText: String {
    guard let currentWeather = weatherStore.lastWeather?.currentWeather else {
      return ""
    }
    
    let temp = currentWeather.temperature
    let roundedTemp = Int(round(temp.value * 10) / 10)
    return "\(roundedTemp)\(temp.unit.symbol)"
  }

  var body: some View {
    ZStack {
      Map(position: $mapViewModel.cameraPosition) {
        if let currentLocation = mapViewModel.currentLocation {
          Marker(
            "현재 위치",
            systemImage: "circle.circle",
            coordinate: currentLocation.coordinate
          )
        }
      }
      .onMapCameraChange {
        mapViewModel.currentCameraSpan = $0.region.span
      }

      VStack {
        HeaderView(
          parameters: .init(
            stepCounts: motionViewModel.stepCount,
            currentAddress: mapViewModel.currentAddress,
            currentWeather: weatherStore.lastWeather?.currentWeather,
            temperatureLabelText: temperatureLabelText,
            weatherKitLightImageUrl: weatherStore.weatherKitLegalInformation?.lightImageUrl,
            weatherKitDarkImageUrl: weatherStore.weatherKitLegalInformation?.darkImageUrl
          ),
          weatherKitIconDidTap: {
            weatherStore.send(.weatherKitLogoTapped)
          }
        )
        .frame(height: 180)
        .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))

        Spacer()

        ControlView {
          mapViewModel.locationButtonTapped()
        }
          .padding(16)
          .padding(
            .bottom,
            presentBottomSheet
              ? UIScreen.main.bounds.height * bottomSheetHeightRatio
              : 0
          )
          .animation(.bouncy, value: presentBottomSheet)

        if !presentBottomSheet {
          bottomSheetHandleView
        }
      }

      if mapViewModel.currentLocation == nil
        && mapViewModel.authState == .notAuthorized
      {
        ToastMessageView(
          message: "위치를 알 수 없습니다.\n설정 - 앱 - 산책자노트에서 위치 권한을 확인해주세요."
        )
      }
    }
    .ignoresSafeArea(.all, edges: .bottom)
    .onAppear {
      weatherStore.send(.onAppear)
    }
    .sheet(
      item: $weatherStore.scope(state: \.legalSheetState, action: \.legalSheetState)
    ) { _ in
      SafariView(
        url: weatherStore.weatherKitLegalInformation?.legalPageURL ?? URL(string: "https://www.apple.com")!
      )
    }
    .sheet(isPresented: $presentBottomSheet) {
      Text("Bottom Sheet")
        .presentationDetents([.fraction(bottomSheetHeightRatio), .large])
        .presentationBackgroundInteraction(.enabled)
    }
  }

  var bottomSheetHandleView: some View {
    ZStack {
      Rectangle()
        .foregroundStyle(Color.white)

      VStack {
        RoundedRectangle(cornerSize: .init(width: 2, height: 2))
          .frame(width: 36, height: 4.5)
          .foregroundStyle(Color.customLightGray)
          .padding(.top, 8)

        Spacer()
      }
    }
    .frame(maxWidth: .infinity, maxHeight: 64)
    .gesture(
      DragGesture()
        .onEnded({ gesture in
          if gesture.translation.height < 0 {
            presentBottomSheet = true
          }
        })
    )
  }
}

#Preview {
  @Previewable @State var locationService = LocationService(locationManager: CLLocationManager())
  
  MainView(
    motionViewModel: MotionViewModel(),
    mapViewModel: MapViewModel(locationService: locationService),
    weatherStore: Store(initialState: WeatherFeature.State()) {
      WeatherFeature()
    }
  )
}
