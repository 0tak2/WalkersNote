//
//  ControlView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct ControlView: View {
  let locationButtonDidTap: () -> Void

  var body: some View {
    HStack {
      Button(action: locationButtonDidTap) {
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
  ControlView {
    print("location button tapped")
  }
  .padding(16)
}
