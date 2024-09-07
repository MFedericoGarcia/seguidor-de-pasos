//
//  StepPieChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 30/08/2024.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    @State private var rawSelectionChartValue: Double? = 0
    @State private var selectedDay: Date?
    
    var selectedWeekday: WeekdayChartData? {
        guard let rawSelectionChartValue else { return nil }
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return rawSelectionChartValue <= total
        }
    }
    
    var chartData: [WeekdayChartData]
    
    var body: some View {
        
        //MARK: - Container and Title

        ChartContainer(title: "Promedio", symbol: "calendar", subtitle: "Últimos 28 Días", context: .steps, isNav: false) {
            
            //MARK: - Empty View

            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.pie", title: "Sin Datos", description: "No hay datos sobre pasos en la APP Salud.")
            } else {

                //MARK: - Chart

                Chart {
                    ForEach(chartData){ weekday in
                        SectorMark(angle: .value("Pasos Promedio", weekday.value),
                                   innerRadius: .ratio(0.62),
                                   outerRadius: .ratio(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1 : 0.9),
                                   angularInset: 1)
                        .foregroundStyle(.teal)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1 : 0.3)
                        
    //                  ----  To show the values inside the chart
    //
    //                    .annotation(position: .overlay) {
    //                        Text(weekday.value, format: .number.precision(.fractionLength(0)))
    //                            .foregroundStyle(.white)
    //                        .fontWeight(.bold)
    //                    }
                        
                    }
                }
                .chartAngleSelection(value: $rawSelectionChartValue.animation(.easeInOut))
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .contentTransition(.identity)
                                    
                                    Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                    
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.impact, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekdayInt != newValue.date.weekdayInt {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
}
