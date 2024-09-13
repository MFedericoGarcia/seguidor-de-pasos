//
//  ChartDataTypes.swift
//  Seguimiento
//
//  Created by Fede Garcia on 27/08/2024.
//

import Foundation

// Equatable to compare one another

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
