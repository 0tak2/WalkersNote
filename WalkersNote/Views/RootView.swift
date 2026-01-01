//
//  RootView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct RootView: View {
  var body: some View {
    MainView(
      motionViewModel: MotionViewModel(),
      mapViewModel: MapViewModel(
        locationService: DependencyContainer.shared.locationService
      ),
      weatherViewModel: WeatherViewModel(
        locationService: DependencyContainer.shared.locationService
      )
    )
  }
}

#Preview {
  RootView()
}
