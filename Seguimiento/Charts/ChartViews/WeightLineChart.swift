//
//  WeightLineChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 31/08/2024.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedHealthMetric: DateValueChartData? {
        ChartHelper.parseSelectedData(for: chartData, in: rawSelectedDate)
    }
    
    var minValue: Double  {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var averageWeight: Double {
        chartData.map { $0.value }.average
    }
    
    var body: some View {
        //MARK: - Container start
        
        ChartContainer(chartType: .weightLine(average: averageWeight)) {
            
            //MARK: - Chart
            
            Chart {
                if let selectedHealthMetric {
                    ChartAnnotationView(data: selectedHealthMetric, context: .weight)
                }
                
                RuleMark(y: .value("Prom", averageWeight))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading) {
                        Text("Prom")
                            .foregroundStyle(.mint)
                            .font(.caption)
                    }
                
                ForEach(chartData) { weights in
                    
                    AreaMark(x: .value("Día", weights.date, unit: .day),
                             yStart: .value("Valor", weights.value),
                             yEnd: .value("Min Valor", minValue))
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.catmullRom)
                    
                    LineMark(x: .value("Día", weights.date, unit: .day),
                             y: .value("Valor", weights.value))
                    .foregroundStyle(.indigo)
                    .interpolationMethod(.catmullRom)
                    .symbol(.diamond)
                }
                
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis{
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            .overlay {
                //MARK: - Empty View
                
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.xyaxis.line", title: "Sin Datos", description: "No hay datos sobre peso en la APP Salud.")
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}
