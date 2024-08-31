//
//  WeightLineChart.swift
//  Seguimiento
//
//  Created by Fede Garcia on 31/08/2024.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    
    var selectedStat: HealthMetricContent
    var chartData: [HealthMetric]
    

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
                ForEach(chartData) { weights in
                   
                    AreaMark(x: .value("Día", weights.date, unit: .day),
                             y: .value("Valor", weights.value))
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    
                    LineMark(x: .value("Día", weights.date, unit: .day),
                             y: .value("Valor", weights.value))
                    .foregroundStyle(.indigo)
                }
            }
            .frame(height: 150)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightLineChart(selectedStat: .weight, chartData: MockData.weights)
}
