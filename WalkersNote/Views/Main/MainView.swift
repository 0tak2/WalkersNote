//
//  MainView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        ZStack {
            Map(position: $viewModel.cameraPosition) {
                if let currentLocation = viewModel.currentLocation {
                    Marker("현재 위치", systemImage: "circle.circle", coordinate: currentLocation.coordinate)
                }
            }
            
            VStack {
                HeaderView(viewModel: viewModel)
                    .frame(height: 136)
                    .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                
                Spacer()
                
                ControlView(viewModel: viewModel)
                    .padding(16)
            }
            
            if viewModel.currentLocation == nil {
                ToastMessageView(message: "위치를 알 수 없습니다.\n설정 - 앱 - 산책자노트에서 위치 권한을 확인해주세요.")
            }
        }
        .onAppear {
            viewModel.viewAppeared()
        }
        .sheet(isPresented: $viewModel.showWeatherKitLegalPage) {
            SafariView(url: viewModel.weatherKitLegalUrl!)
        }
    }
}

#Preview {
    MainView()
}
