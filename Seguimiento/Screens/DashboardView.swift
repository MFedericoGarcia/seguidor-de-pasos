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
    
//      First Form for testing
//    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    
    @State private var isShowingPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContent = .steps
    @State private var isShowingAlert: Bool = false
    @State private var fetchError: SegError = .noData
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
                   
                    //MARK: - Steps / Weight  Charts
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: hkManager.stepData, selectedStat: selectedStat)
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                        
                    case .weight:
                        WeightLineChart(selectedStat: selectedStat, chartData: hkManager.weightData)
                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                    
//                    switch selectedStat {
//                    case .steps:
//                        StepBarChart(chartData: MockData.steps, selectedStat: selectedStat)
//                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
//                        
//                    case .weight:
//                        WeightLineChart(selectedStat: selectedStat, chartData: MockData.weights)
//                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
//                    }
                    
                //MARK: - Charts end
                    
                }
                .padding()
                .navigationTitle("Dashboard")
                .navigationDestination(for: HealthMetricContent.self) { metric in
                    HealthDataListView(metric: metric)
                }
                
                .task {
                    do {
                       try await hkManager.fetchStepCount()
                       try await hkManager.fetchWeights()
                       try await hkManager.fetchWeightsForDifferentials()
                    } catch SegError.authNotDetermined {
                        isShowingPermissionPrimingSheet = true
                    } catch SegError.noData {
                        fetchError = .noData
                        isShowingAlert = true
                    } catch {
                        fetchError = .unableToCompleteRequest
                        isShowingAlert = true
                    }
                }
                .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                    
                }, content: {
                    HealthKitPermissionPrimingView()
                })
                .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                    //
                } message: { fetchError in
                    Text(fetchError.failureReason)
                }

            }
        }
       .tint(isSteps ? .teal : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
