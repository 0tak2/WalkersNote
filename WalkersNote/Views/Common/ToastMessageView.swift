//
//  ToastMessageView.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

struct ToastMessageView: View {
    private let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .background(.red, in: .rect(cornerRadius: 4, style: .continuous))
            }
                
        }
    }
}

#Preview {
    ToastMessageView(message: "Toast Message")
}
