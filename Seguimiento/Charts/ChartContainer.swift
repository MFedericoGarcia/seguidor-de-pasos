//
//  ChartContainer.swift
//  Seguimiento
//
//  Created by Fede Garcia on 07/09/2024.
//

import SwiftUI

struct ChartContainer<Content: View>: View {
    
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContent
    let isNav: Bool
    
    @ViewBuilder var content: () -> Content
    
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
    }
        
    // MARK: - Title
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .steps ? .teal : .indigo)
            
            Text(subtitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(title: "title", symbol: "person", subtitle: "hello", context: .steps, isNav: true) {
        Text("pepe")
            .frame(height: 150)
    }
}
