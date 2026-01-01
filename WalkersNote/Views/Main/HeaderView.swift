//
//  CounterView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import WeatherKit

struct HeaderView: View {
  let parameters: HeaderViewParameters
  let weatherKitIconDidTap: () -> Void
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack {
      backgroundView()

      VStack {
        headlineHStack()

        weatherKitAttributesview()

        Spacer()
          .frame(height: 16)

        withAnimation {
          Text(String(parameters.stepCounts))
            .font(.big)
            .monospaced()
        }

        Spacer()
          .frame(height: 24)

        HStack {
          Button {
            print("chart button tapped")
          } label: {
            Image(systemName: "chart.bar.fill")
              .foregroundStyle(.black)
          }

          Spacer()

          Button {
            print("setting button tapped")
          } label: {
            Image(systemName: "gearshape.fill")
              .foregroundStyle(.black)
          }
        }
      }
      .padding(16)
    }
  }

  func fetchImage(url: String) -> some View {
    AsyncImage(url: URL(string: url)) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(height: 12)
    } placeholder: {
      ProgressView()
    }
  }

  func backgroundView() -> some View {
    RoundedRectangle(cornerSize: .init(width: 8, height: 8), style: .continuous)
      .fill(Color.primary)
      .opacity(0.8)
      .shadow(radius: 16)
  }

  func headlineHStack() -> some View {
    HStack {
      Text(parameters.currentAddress ?? "알 수 없음")

      Spacer()

      let currentWeather = parameters.currentWeather
      Image(systemName: currentWeather?.condition.imageName ?? "questionmark")
        .foregroundStyle(currentWeather?.condition.imageColor ?? .white)

      Text(parameters.temperatureLabelText)
    }
    .font(.system(size: 16, weight: .bold))
  }

  @ViewBuilder
  func weatherKitAttributesview() -> some View {
    if let weatherKitLightImageUrl = parameters.weatherKitLightImageUrl,
      let weatherKitDarkImageUrl = parameters.weatherKitDarkImageUrl
    {
      let imageUrl =
        colorScheme == .light ? weatherKitLightImageUrl : weatherKitDarkImageUrl

      HStack {
        Spacer()
        fetchImage(url: imageUrl.absoluteString)
          .onTapGesture(perform: weatherKitIconDidTap)
      }
    }
  }

  struct HeaderViewParameters {
    let stepCounts: Int
    let currentAddress: String?
    let currentWeather: CurrentWeather?
    let temperatureLabelText: String
    let weatherKitLightImageUrl: URL?
    let weatherKitDarkImageUrl: URL?
  }
}

#Preview {
  HeaderView(
    parameters: .init(
      stepCounts: 4321,
      currentAddress: "어딘가",
      currentWeather: nil,
      temperatureLabelText: "도",
      weatherKitLightImageUrl: nil,
      weatherKitDarkImageUrl: nil
    ),
    weatherKitIconDidTap: {
      //
    }
  )
    .frame(height: 136)
    .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
}
