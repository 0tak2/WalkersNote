//
//  MotionViewModel.swift
//  WalkersNote
//
//  Created by 임영택 on 3/9/25.
//

import CoreMotion
import Foundation

@Observable
final class MotionViewModel {
  var stepCount: Int = 0

  @ObservationIgnored
  private let pedometer = CMPedometer()

  init() {
    if CMPedometer.isStepCountingAvailable() {
      getTodayStepCount()
    } else {
      // TODO: 처리 필요?
    }
  }

  private func getTodayStepCount() {
    pedometer.startUpdates(
      from: Calendar.current.startOfDay(for: Date()),
      withHandler: { [weak self] (data, error) in
        if let error = error {
          print(
            "Error occured during getting step count: \(error.localizedDescription)"
          )
        }

        if let stepData = data {
          let steps = stepData.numberOfSteps.stringValue
          DispatchQueue.main.async {
            self?.stepCount = Int(steps) ?? 0
          }
        }
      }
    )
  }
}
