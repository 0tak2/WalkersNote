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
            Rectangle()
                .fill(Color.primary.opacity(0.7))
            
            VStack {
                HStack {
                    Text(viewModel.currentAddress)
                        .font(.body)
                    
                    Spacer()
                    
                    let currentWeather = viewModel.lastWeather?.currentWeather
                    Image(systemName: currentWeather?.condition.imageName ?? "questionmark")
                        .foregroundStyle(currentWeather?.condition.imageColor ?? .white)
                    
                    Text(viewModel.temperatureLabelText)
                        .font(.body)
                }
                
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
                
                
                Spacer()
                
                Text("\(viewModel.stepCount)")
                    .font(.big)
                
                Spacer()
                
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
}

#Preview {
    HeaderView(viewModel: MainViewModel())
        .frame(height: 136)
        .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
}
