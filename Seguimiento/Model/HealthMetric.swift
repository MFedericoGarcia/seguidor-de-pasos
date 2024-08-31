//
//  HealthMetric.swift
//  Seguimiento
//
//  Created by Fede Garcia on 26/08/2024.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
