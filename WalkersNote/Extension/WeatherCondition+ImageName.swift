//
//  WeatherCondition+ImageName.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import WeatherKit
import SwiftUI

extension WeatherCondition {
    var imageName: String {
        switch self {
        case .clear:
            fallthrough
        case .mostlyClear:
            return "sun.max"
        case .cloudy:
            fallthrough
        case .mostlyCloudy:
            fallthrough
        case .partlyCloudy:
            return "cloud.fill"
        case .rain:
            return "cloud.rain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .blizzard:
            return "wind.snow"
        case .blowingDust:
            return "cloud.fill"
        case .blowingSnow:
            return "wind.snow"
        case .breezy:
            return "wind"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .flurries:
            return "snowflake"
        case .foggy:
            fallthrough
        case .smoky:
            return "cloud.fog.fill"
        case .freezingDrizzle:
            return "cloud.snow.fill"
        case .freezingRain:
            return "cloud.rain.fill"
        case .frigid:
            return "thermometer.snowflake"
        case .hail:
            return "cloud.hail.fill"
        case .haze:
            return "sun.haze.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .heavySnow:
            return "wind.snow"
        case .hot:
            return "thermometer.sun.fill"
        case .hurricane:
            return "hurricane"
        case .isolatedThunderstorms:
            fallthrough
        case .scatteredThunderstorms:
            fallthrough
        case .thunderstorms:
            fallthrough
        case .strongStorms:
            fallthrough
        case .tropicalStorm:
            return "tropicalstorm"
        case .sleet:
            return "cloud.sleet.fill"
        case .sunFlurries:
            return "sun.snow.fill"
        case .sunShowers:
            return "sun.rain.fill"
        case .windy:
            return "wind"
        case .wintryMix:
            return "wind.snow"
        @unknown default:
            return "questionmark"
        }
    }
    
    var imageColor: Color {
        switch self {
        case .clear:
            fallthrough
        case .mostlyClear:
            fallthrough
        case .sunFlurries:
            fallthrough
        case .sunShowers:
            return .yellow
        case .cloudy:
            fallthrough
        case .mostlyCloudy:
            fallthrough
        case .partlyCloudy:
            fallthrough
        case .rain:
            fallthrough
        case .snow:
            fallthrough
        case .blizzard:
            fallthrough
        case .blowingDust:
            fallthrough
        case .blowingSnow:
            fallthrough
        case .breezy:
            fallthrough
        case .drizzle:
            fallthrough
        case .freezingDrizzle:
            fallthrough
        case .freezingRain:
            fallthrough
        case .hail:
            fallthrough
        case .haze:
            fallthrough
        case .heavyRain:
            fallthrough
        case .heavySnow:
            fallthrough
        case .hurricane:
            fallthrough
        case .isolatedThunderstorms:
            fallthrough
        case .scatteredThunderstorms:
            fallthrough
        case .thunderstorms:
            fallthrough
        case .strongStorms:
            fallthrough
        case .tropicalStorm:
            fallthrough
        case .sleet:
            fallthrough
        case .windy:
            fallthrough
        case .wintryMix:
            fallthrough
        case .flurries:
            return .white
        case .foggy:
            fallthrough
        case .smoky:
            return .gray
        case .hot:
            return .red
        case .frigid:
            return .blue
        @unknown default:
            return .white
        }
    }
}
