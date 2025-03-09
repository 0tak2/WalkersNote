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
            Map(position: $viewModel.cameraPosition)
            VStack {
                HeaderView(viewModel: viewModel)
                    .frame(height: 136)
                    .padding(.init(top: 16, leading: 16, bottom: 0, trailing: 16))
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.viewAppeared()
        }
    }
}

#Preview {
    MainView()
}
