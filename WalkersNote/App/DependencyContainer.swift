//
//  DependencyContainer.swift
//  WalkersNote
//
//  Created by 임영택 on 1/1/26.
//

import Foundation

final class DependencyContainer {
  static let shared: DependencyContainer = .init()
  
  let locationService: LocationService = .init()
}
