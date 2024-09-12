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
    
    var chartData: [DateValueChartData]
    
    var selectedHealthMetric: DateValueChartData? {
        ChartHelper.parseSelectedData(for: chartData, in: rawSelectedDate)
    }
    
    var averageSteps: Int {
        Int(chartData.map { $0.value }.average)
    }
    
    //MARK: - Body
    
    var body: some View {
        //MARK: - Container start

        ChartContainer(chartType: .stepBar(average: averageSteps)) {
            
                // MARK: - Chart
                
                Chart {
                    if let selectedHealthMetric {
                        ChartAnnotationView(data: selectedHealthMetric, context: .steps)
                    }
                    if !chartData.isEmpty {
                        RuleMark(y: .value("Promedio", averageSteps ))
                            .foregroundStyle(Color.secondary.opacity(0.8))
                            .lineStyle(.init(lineWidth: 1, dash: [5]))
                            .accessibilityHidden(true)
                    }
                    
                    ForEach(chartData) { steps in
                        Plot {
                            BarMark(x: .value("Fecha", steps.date, unit: .day),
                                    y: .value("Pasos", steps.value)
                            )
                            .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                            .foregroundStyle(Color.teal.gradient)
                        }
                        .accessibilityLabel(steps.date.accesibilityDate)
                        .accessibilityValue("\(Int(steps.value)) Pasos")
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks(values: .automatic) {
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0 ).formatted(.number.notation(.compactName)))
                    }
                }
            
                .overlay {
                    //MARK: - Empty View
                        
                    if chartData.isEmpty {
                        ChartEmptyView(systemImageName: "chart.bar", title: "Sin Datos", description: "No hay datos sobre pasos en la APP Salud.")
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

    //MARK: -

#Preview {
    StepBarChart(chartData: ChartHelper.convert(data: MockData.steps))
}
