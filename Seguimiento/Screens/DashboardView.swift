//
//  DashboardView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 14/08/2024.
//

import SwiftUI
import Charts
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
    
    //MARK: - Variables
    
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContent = .steps
    var isSteps: Bool { selectedStat == .steps }
    
    //MARK: - Body
    
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
                   
                    //MARK: - Steps / Weight  Chart
                    
                    StepBarChart(chartData: hkManager.stepData, selectedStat: selectedStat)
                    
                    //MARK: - Average Chart
                    
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
                .navigationTitle("Dashboard")
                .navigationDestination(for: HealthMetricContent.self) { metric in
                    HealthDataListView(metric: metric, number: hkManager.stepData)
                }
                
                //MARK: - Charts end
                
                .task {
                    await hkManager.fetchStepCount()
                    isShowingPermissionPrimingSheet = !hasSeenPermissionPriming
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
