//
//  WeightBarChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 03/09/2024.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    
    @State private var rawSelectedDate : Date?
    @State private var selectedDay: Date?

    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(for: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        
        //MARK: - Container Configuration
        
        let config = ChartContainerConfiguration(title: "Promedios de cambio de peso", symbol: "figure", subtitle: "Por día (Últimos 28 Días)", context: .weight, isNav: false)
        
        //MARK: - Container start

        ChartContainer(config: config) {
                    
            //MARK: - Empty View
              
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "Sin Datos", description: "No hay datos sobre peso en la APP Salud.")
            } else {
                
                //MARK: - Chart
                
                Chart {
                    
                    if rawSelectedDate != nil {
                        RuleMark(x: .value("Selected Metric", rawSelectedDate!, unit: .weekday))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -5)
                            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                annotationView.frame(width: 100)
                            }
                    }
                    
                    ForEach(chartData){ weekday in
                        BarMark(x: .value("Day", weekday.date, unit: .weekday),
                                y: .value("dif", weekday.value),
                                width: .fixed(30))
                        .opacity(selectedData?.date == nil || weekday.date == selectedData?.date ? 1.0 : 0.3)

                        .foregroundStyle(weekday.value > 0 ? Color.indigo.gradient : Color.mint.gradient)
                    }
                    
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
                    }
                }
            }
        }
        .sensoryFeedback(.impact, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
        
    }
    
    //MARK: - Annotation View
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(rawSelectedDate ?? .now, format:
                    .dateTime.weekday(.wide))
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            Text("\(selectedData?.value ?? 1 > 0 ? "+" : "") \(selectedData?.value ?? 0, format: .number.precision(.fractionLength(2)))")
                .fontWeight(.heavy)
                .foregroundStyle(selectedData?.value ?? 1 > 0 ? Color.indigo.gradient : Color.mint.gradient)
        }
        .padding(12)
        .background(
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
    }
}

#Preview {
    WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
}
