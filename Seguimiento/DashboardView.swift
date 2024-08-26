//
//  DashboardView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 14/08/2024.
//

import SwiftUI

enum HealthMetricContent: CaseIterable, Identifiable {
    case steps, weight
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Pasos"
        case .weight:
            return "Peso"
        }
    }
}

struct DashboardView: View {
    
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    
    
    @State private var selectedStat: HealthMetricContent = .steps
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
       NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Estadística", selection: $selectedStat) {
                        ForEach(HealthMetricContent.allCases) { metric in
                            Text(metric.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack {
                        NavigationLink(value: selectedStat){
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Pasos", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.teal)
                                    
                                    Text("Promedio: 10k Pasos")
                                        .font(.caption)
                                }
                                        
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 12)
                        
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
                                    .foregroundStyle(.teal)
                                
                                Text("Últimos 28 Días")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 12)
                          
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
                .padding()
                .onAppear {
                    isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
                }
                .navigationTitle("Dashboard")
                .navigationDestination(for: HealthMetricContent.self) { metric in
                    HealthDataListView(metric: metric)
                }
                .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                    
                }, content: {
                    HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming)
                })
            }
        }
       .tint(isSteps ? .teal : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
