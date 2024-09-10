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
    @State private var lastSelectedValue: Double = 0
    
    var selectedWeekday: DateValueChartData? {
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return lastSelectedValue <= total
        }
    }
    
    var chartData: [DateValueChartData]
    
    var body: some View {
        
        //MARK: - Container Configuration

        let config = ChartContainerConfiguration(title: "Promedio", symbol: "calendar", subtitle: "Últimos 28 Días", context: .steps, isNav: false)
        
        //MARK: - Container start

        ChartContainer(config: config) {
                    
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
                    }
                }
                .chartAngleSelection(value: $rawSelectionChartValue.animation(.easeInOut))
                .onChange(of: rawSelectionChartValue) { oldValue, newValue in
                    withAnimation(.easeInOut){
                        guard let newValue else {
                            lastSelectedValue = oldValue ?? 0
                            return
                        }
                        lastSelectedValue = newValue
                    }
                }
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.weekdayTitle)
                                        .font(.title3.bold())
                                        .animation(.none)
                                    
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
                .overlay {
                    //MARK: - Empty View
                    
                    if chartData.isEmpty {
                        ChartEmptyView(systemImageName: "chart.pie", title: "Sin Datos", description: "No hay datos sobre pasos en la APP Salud.")
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
