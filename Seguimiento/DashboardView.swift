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
    @State private var rawSelectedDate : Date?
    var isSteps: Bool { selectedStat == .steps }
    
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty  else { return 0 }
        let totalSteps = hkManager.stepData.reduce(0) { $0 + $1.value }
        return totalSteps/Double(hkManager.stepData.count)
    }
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return hkManager.stepData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
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
                    
                    VStack {
                        NavigationLink(value: selectedStat){
                            HStack {
                                VStack(alignment: .leading) {
                                    Label("Pasos", systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.teal)
                                    
                                    Text("Promedio: \(Int(avgStepCount)) Pasos")
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
                                    .annotation(position: .top, spacing: 0, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                                        annotationView
                                    }
                            }
                            
                            
                            RuleMark(y: .value("Promedio", avgStepCount))
                                .foregroundStyle(Color.secondary.opacity(0.8))
                                .lineStyle(.init(lineWidth: 1, dash: [5]))
                            
                            ForEach(hkManager.stepData) { steps in
                                BarMark(x: .value("Fecha", steps.date, unit: .day),
                                        y: .value("Pasos", steps.value)
                                )
                                .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                                .foregroundStyle(Color.teal.gradient)
                            }
                        }
                        .frame(height: 150)
                        .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                        .chartXAxis{
                            AxisMarks {
                                AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.secondary.opacity(0.3))
                                
                                AxisValueLabel((value.as(Double.self) ?? 0 ).formatted(.number.notation(.compactName)))
                            }
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
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
                    HealthDataListView(metric: metric)
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
    
    var annotationView: some View {
        VStack(alignment: .leading) {
            Text(selectedHealthMetric?.date ?? .now, format:
                    .dateTime.weekday(.abbreviated).day().month(.abbreviated))
                    .font(.footnote.bold())
                    .foregroundStyle(.secondary)
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(2)))
                .fontWeight(.heavy)
                .foregroundStyle(.teal)
        }
        .padding(12)
        .background(
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.secondarySystemBackground))
            .shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2))
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
