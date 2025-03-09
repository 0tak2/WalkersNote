//
//  CounterView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct CounterView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.primary.opacity(0.7))
            
            VStack {
                HStack {
                    Text("포항시 지곡동")
                        .font(.body)
                    Spacer()
                    Image(systemName: "sun.min")
                    Text("13°C")
                        .font(.body)
                }
                
                Spacer()
                
                Text("1234")
                    .font(.big)
                
                Spacer()
                
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Spacer()
                    Image(systemName: "gearshape.fill")
                }
            }
            .padding(8)
        }
        .clipShape(.rect(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    CounterView()
}
