//
//  CounterView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct HeaderView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.primary.opacity(0.7))
            
            VStack {
                HStack {
                    Text(viewModel.currentAddress)
                        .font(.body)
                    Spacer()
                    Image(systemName: "sun.min")
                        .foregroundStyle(.yellow)
                    Text("13°C")
                        .font(.body)
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
                    }

                    Spacer()
                    
                    Button {
                        print("setting button tapped")
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .padding(8)
        }
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    HeaderView(viewModel: MainViewModel())
}
