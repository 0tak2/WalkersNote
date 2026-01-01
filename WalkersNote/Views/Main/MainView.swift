//
//  MainView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import CoreLocation
import MapKit
import SwiftUI

struct MainView: View {
  @StateObject var viewModel = MainViewModel()
  @State var mapViewModel = MapViewModel()
  let bottomSheetHeightRatio = 0.4

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
            stepCounts: viewModel.stepCount,
            currentAddress: mapViewModel.currentAddress,
            currentWeather: viewModel.lastWeather?.currentWeather,
            temperatureLabelText: viewModel.temperatureLabelText,
            weatherKitLightImageUrl: viewModel.weatherKitLightImageUrl,
            weatherKitDarkImageUrl: viewModel.weatherKitDarkImageUrl
          ),
          weatherKitIconDidTap: viewModel.weatherImageTapped
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
            viewModel.presentBottomSheet
              ? UIScreen.main.bounds.height * bottomSheetHeightRatio
              : 0
          )
          .animation(.bouncy, value: viewModel.presentBottomSheet)

        if !viewModel.presentBottomSheet {
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
      viewModel.viewAppeared()
    }
    .sheet(isPresented: $viewModel.showWeatherKitLegalPage) {
      SafariView(url: viewModel.weatherKitLegalUrl!)
    }
    .sheet(isPresented: $viewModel.presentBottomSheet) {
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
            viewModel.presentBottomSheet = true
          }
        })
    )
  }
}

#Preview {
  MainView()
}
