//
//  Color+Styles.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

extension Color {
    public static var primary: Color = .init(red2: 212, green2: 229, blue2: 186)
    public static var customLightGray: Color = .init(red2: 195, green2: 195, blue2: 198)
    
    init (red2: Int, green2: Int, blue2: Int) {
        self.init(red: Double(red2) / 255.0, green: Double(green2) / 255.0, blue: Double(blue2) / 255.0)
    }
}
