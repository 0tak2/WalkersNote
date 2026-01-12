//
//  RootView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
  @Dependency(\.locationService) var locationService // TODO: 이후 MainFeature 작성 완료 후 MapViewModel과 함께 주입 로직 삭제
  
  var body: some View {
    MainView(
      motionViewModel: MotionViewModel(),
      mapViewModel: MapViewModel(locationService: locationService),
      weatherStore: Store(initialState: WeatherFeature.State()) {
        WeatherFeature()
          ._printChanges()
      }
    )
  }
}

#Preview {
  RootView()
}
