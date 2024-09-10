//
//  ChartAnnotationView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 07/09/2024.
//

import SwiftUI
import Charts

struct ChartAnnotationView: ChartContent {
    
    let data: DateValueChartData
    let context: HealthMetricContent
    
    var body: some ChartContent {
        RuleMark(x: .value("Selected Metric", data.date, unit: .day))
            .foregroundStyle(Color.secondary.opacity(0.3))
            .offset(y: -5)
            .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) { annotationView }
    }
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(data.date, format:
                    .dateTime.weekday(.abbreviated).day().month(.abbreviated))
            .font(.footnote.bold())
            .foregroundStyle(.secondary)
            Text(data.value, format: .number.precision(.fractionLength(context == .steps ? 0 : 2)))
                .fontWeight(.heavy)
                .foregroundStyle( context == .steps ? .teal : .indigo)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
        .frame(width: 100)
    }
    
}
