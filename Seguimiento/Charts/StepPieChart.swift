//
//  StepPieChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 30/08/2024.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    var chartData: [WeekdayChartData]
    
    var body: some View {
        
        VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Label("Promedio", systemImage: "calendar")
                        .font(.title3.bold())
                        .foregroundStyle(.teal)
                    
                    Text("Últimos 28 Días")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)
              
            Chart {
                ForEach(chartData){ weekday in
                    SectorMark(angle: .value("Pasos Promedio", weekday.value),
                               innerRadius: .ratio(0.7),
                               outerRadius: .ratio(1),
                               angularInset: 1)
                    .foregroundStyle(.teal)
                    .cornerRadius(6)
                    
                    
//                  ----  To show the values inside the chart
//                    
//                    .annotation(position: .overlay) {
//                        Text(weekday.value, format: .number.precision(.fractionLength(0)))
//                            .foregroundStyle(.white)
//                        .fontWeight(.bold)
//                    }
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))  
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
