//
//  MockData.swift
//  Seguimiento
//
//  Created by Fede Garcia on 31/08/2024.
//

import Foundation

struct MockData {
    
    static var steps: [HealthMetric] {
        var array: [HealthMetric] =  []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: 4_000...15_000))
            array.append(metric)
        }
        return array
    }
    
    static var weights: [HealthMetric] {
        var array: [HealthMetric] =  []
        
        for i in 0..<28 {
            let metric = HealthMetric(date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
                                      value: .random(in: (83 + Double(i/6)...85 + Double(i/6))))
            array.append(metric)
        }
        return array
    }
    
}
