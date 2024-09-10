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
                        StepBarChart(chartData: ChartHelper.convert(data: hkManager.stepData))
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                        
                    case .weight:
                        WeightLineChart( chartData: ChartHelper.convert(data: hkManager.weightData))
                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                     
//                    switch selectedStat {
//                    case .steps:
//                        StepBarChart(chartData: ChartHelper.convert(data: MockData.steps))
//                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
//                        
//                    case .weight:
//                        WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
//                        WeightBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: MockData.weights))
//                    }
                    
                //MARK: - Charts end
                    
                }
                .padding()
                .task { fetchHealthData() }
                .navigationTitle("Dashboard")
                .navigationDestination(for: HealthMetricContent.self) { metric in
                    HealthDataListView(metric: metric)
                }
                .sheet(isPresented: $isShowingPermissionPrimingSheet, onDismiss: {
                    fetchHealthData()
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
       .tint(selectedStat == .steps ? .teal : .indigo)
    }
    
    private func fetchHealthData() {
        
        Task {
            do {
                
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                
                hkManager.stepData = try await steps
                hkManager.weightData = try await weightsForLineChart
                hkManager.weightDiffData = try await weightsForDiffBarChart
                
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
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
