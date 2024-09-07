//
//  StepBarChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 27/08/2024.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    
    //MARK: - Variables
    
    @State private var rawSelectedDate : Date?
    @State private var selectedDay: Date?
    
    var chartData: [HealthMetric]
    var selectedStat: HealthMetricContent
    
    var avgStepCount: Double {
        guard !chartData.isEmpty  else { return 0 }
        let totalSteps = chartData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(chartData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    //MARK: - Body
    
    var body: some View {
        
        //MARK: - Container and Title
        
        ChartContainer(title: "Pasos", symbol: "figure.walk", subtitle: "Promedio: \(Int(avgStepCount)) Pasos", context: .steps, isNav: true) {
            
            //MARK: - Empty View

            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "Sin Datos", description: "No hay datos sobre pasos en la APP Salud.")
                
            } else {
                
                // MARK: - Chart
                
                Chart {
                    if let selectedHealthMetric {
                        RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -5)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView
                            }
                    }
                    RuleMark(y: .value("Promedio", avgStepCount))
                        .foregroundStyle(Color.secondary.opacity(0.8))
                        .lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { steps in
                        BarMark(x: .value("Fecha", steps.date, unit: .day),
                                y: .value("Pasos", steps.value)
                        )
                        .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                        .foregroundStyle(Color.teal.gradient)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0 ).formatted(.number.notation(.compactName)))
                    }
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
    
    //MARK: - Annotation View
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format:
                    .dateTime.weekday(.abbreviated).day().month(.abbreviated))
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle(.teal)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
    }
}

    //MARK: -

#Preview {
    StepBarChart(chartData: MockData.steps , selectedStat: .steps)
}
