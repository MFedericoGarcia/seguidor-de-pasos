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
    
    var selectedStat: HealthMetricContent
    var chartData: [HealthMetric]
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first { item in
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: item.date)
        }
    }
    
    var minValue: Double  {
        chartData.map { $0.value }.min() ?? 0
    }

    var body: some View {
        VStack {
            NavigationLink(value: selectedStat){
                HStack {
                    VStack(alignment: .leading) {
                        Label("Peso", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Promedio: \(Int(85)) Kgs")
                            .font(.caption)
                    }
                            
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.secondary)
            .padding(.bottom, 12)
            
            Chart {
                if let selectedHealthMetric {
                    RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
                        .foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -5)
                        .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
                }
                
                RuleMark(y: .value("Meta", 160))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                    .annotation(alignment: .leading) {
                        Text("Meta")
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
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    //MARK: - Annotation View
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format:
                    .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(1)))
                .fontWeight(.heavy)
                .foregroundStyle(.indigo)
        }
        .padding(12)
        .background(
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
    }

}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
