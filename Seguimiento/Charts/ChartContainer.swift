//
//  ChartContainer.swift
//  Seguimiento
//
//  Created by Fede Garcia on 07/09/2024.
//

import SwiftUI

struct ChartContainerConfiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContent
    let isNav: Bool
}


struct ChartContainer<Content: View>: View {
    
    let config: ChartContainerConfiguration
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if config.isNav {
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
        NavigationLink(value: config.context){
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
        
    // MARK: - Title
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .teal : .indigo)
            
            Text(config.subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(config: ChartContainerConfiguration(title: "title", symbol: "person", subtitle: "hello", context: .steps, isNav: true)) {
            Text("pepe")
                .frame(height: 150)
    }
}
