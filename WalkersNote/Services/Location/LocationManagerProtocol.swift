//
//  LocationManagerProtocol.swift
//  WalkersNote
//
//  Created by 임영택 on 1/12/26.
//

import Foundation
import CoreLocation

protocol LocationManagerProtocol: AnyObject {
  var location: CLLocation? { get }
  var delegate: CLLocationManagerDelegate? { get set }
  func requestWhenInUseAuthorization()
}
