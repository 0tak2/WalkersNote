//
//  Font+Styles.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import SwiftUI

extension Font {
    public static var body: Font {
        .system(size: 14, weight: .medium, design: .default)
    }
    
    public static var big: Font {
        .system(size: 64, weight: .bold, design: .default)
    }
}
