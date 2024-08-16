//
//  HealthKitManager.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
