//
//  CounterView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: MainViewModel
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
                    Text(String(viewModel.stepCount))
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
            .padding(8)
        }
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
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
            Text(viewModel.currentAddress)
            
            Spacer()
            
            let currentWeather = viewModel.lastWeather?.currentWeather
            Image(systemName: currentWeather?.condition.imageName ?? "questionmark")
                .foregroundStyle(currentWeather?.condition.imageColor ?? .white)
            
            Text(viewModel.temperatureLabelText)
        }
        .font(.system(size: 16, weight: .bold))
    }
    
    @ViewBuilder
    func weatherKitAttributesview() -> some View {
        if let weatherKitLightImageUrl = viewModel.weatherKitLightImageUrl,
           let weatherKitDarkImageUrl = viewModel.weatherKitDarkImageUrl {
            let imageUrl = colorScheme == .light ? weatherKitLightImageUrl : weatherKitDarkImageUrl
            
            HStack {
                Spacer()
                fetchImage(url: imageUrl.absoluteString)
                    .onTapGesture {
                        viewModel.weatherImageTapped()
                    }
            }
        }
    }
}

#Preview {
    HeaderView(viewModel: MainViewModel())
        .frame(height: 136)
        .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
}
