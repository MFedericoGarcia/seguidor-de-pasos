//
//  ChartContainer.swift
//  Seguimiento
//
//  Created by Fede Garcia on 07/09/2024.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainer<Content: View>: View {
    
    let chartType: ChartType
    @ViewBuilder var content: () -> Content
    
    var isNav: Bool {
        switch chartType {
        case .stepBar(_), .weightLine(_):
            return true
        case .stepWeekdayPie, .weightDiffBar:
            return false
        }
    }
    
    var context: HealthMetricContent {
        switch chartType {
        case .stepBar(_), .stepWeekdayPie:
                .steps
        case .weightLine(_), .weightDiffBar:
                .weight
        }
    }
    
    var title: String {
        switch chartType {
        case .stepBar(_):
            "Pasos"
        case .stepWeekdayPie:
            "Promedio"
        case .weightLine(_):
            "Peso"
        case .weightDiffBar:
            "Promedios de cambio de peso"
        }
    }
    
    var symbol: String {
        switch chartType {
        case .stepBar(_):
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine(_):
            "figure"
        case .weightDiffBar:
            "figure"
        }
    }
    
    var subtitle: String {
        switch chartType {
        case .stepBar(let average):
            "Promedio: \(average.formatted()) Pasos"
        case .stepWeekdayPie:
            "Últimos 28 Días"
        case .weightLine(let average):
            "Promedio: \(average.formatted(.number.precision(.fractionLength(1))))"
        case .weightDiffBar:
            "Por día (Últimos 28 Días)"
        }
    }
    
    var accessibilityLabel: String {
        switch chartType {
        case .stepBar(let average):
            "Gráfico de barras, contador de pasos, últimos 28 Días , Promedio por día : \(average.formatted()) ?? 0) Pasos"
        case .stepWeekdayPie:
            "Gráfico de torta, promedio de pasos por día de la semana"
        case .weightLine(let average):
            "Gráfico de lineas, peso, Promedio de peso : \(average.formatted(.number.precision(.fractionLength(1))))"
        case .weightDiffBar:
            "Gráfico de barras, diferencia de peso promedio Por día de la semana"
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
            }
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        
    }
    
    //MARK: - NavigationLink
    
    var navigationLinkView: some View {
        NavigationLink(value: context){
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("toca dos veces para ir a la lista de datos")
        .accessibilityRemoveTraits(.isButton)
    }
        
    // MARK: - Title
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .steps ? .teal : .indigo)
                
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie){
           Text("pepe")
                .frame(height: 150)
    }
}
