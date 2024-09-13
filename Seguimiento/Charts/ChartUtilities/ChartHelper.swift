//
//  ChartHelper.swift
//  Seguimiento
//
//  Created by Fede Garcia on 07/09/2024.
//

import Foundation

struct ChartHelper {
    
    /// Convierte los datos obtenidos de la App Health en datos listos para utilizar en los graficos
    /// - Parameter data: Array de ``HealthMetric``
    /// - Returns: Array de ``DateValueChartData``
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value)}
    }
    
    /// Calcula el promedio de los datos (Valores) listos para el grafico
    /// - Parameter data: Array de ``DateValueChartData``
    /// - Returns: Double
    static func averageValue( for data: [DateValueChartData] ) -> Double {
        guard !data.isEmpty  else { return 0 }
        let totalSteps = data.reduce(0) { $0 + $1.value }
        return totalSteps/Double(data.count)
    }
    
    /// Busca en el Array los datos con fecha coincidente con la fecha seleccionada, y devuelve ese dato en especifico
    /// - Parameters:
    ///   - data: Array de ``DateValueChartData``
    ///   - selectedDate: Fate proporcionada
    /// - Returns: Dato especifico con fecha coincidente ``DateValueChartData``
    static func parseSelectedData( for data: [DateValueChartData],in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
}
