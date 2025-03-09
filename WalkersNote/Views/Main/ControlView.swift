//
//  ControlView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct ControlView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.locationButtonTapped()
            } label: {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.orange)
                    .background(.white)
            }
            .clipShape(.circle)
        }
    }
}

#Preview {
    ControlView(viewModel: MainViewModel())
        .padding(16)
}
