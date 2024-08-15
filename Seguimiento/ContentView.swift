//
//  ContentView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 14/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Label("Pasos", systemImage: "figure.walk")
                                    .font(.title3.bold())
                                    .foregroundStyle(.pink)
                                
                                Text("Promedio: 10k Pasos")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Label("Promedio", systemImage: "calendar")
                                    .font(.title3.bold())
                                    .foregroundStyle(.pink)
                                
                                Text("Últimos 28 Días")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                          
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
                .padding()
                .navigationTitle("Dashboard")
                
                
            }
           
           
        }
            
    }
}

#Preview {
    ContentView()
}
