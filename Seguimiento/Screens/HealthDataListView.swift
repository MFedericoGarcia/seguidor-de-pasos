//
//  HealthDataListView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import SwiftUI

struct HealthDataListView: View {
    
    @Environment(HealthKitManager.self) private var hkManager

    
    var metric: HealthMetricContent

    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepData : hkManager.weightData
    }
    
    @State private var isShowingAddData: Bool = false
    @State private var addDataDate: Date = .now
    @State private var addValue: String = ""
    @State private var isShowingAlert: Bool = false
    @State private var writeError: SegError = .noData
        
    var body: some View {
        List(listData.reversed()) { data in
            
            LabeledContent {                
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
            } label: {
                Text(data.date, format: .dateTime.day().month().year())
            }

        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData){
            addDataView
        }
        .toolbar{
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form{
                DatePicker("Fecha", selection: $addDataDate, displayedComponents: .date)
                LabeledContent(metric.title) {
                    TextField("Valor", text: $addValue)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }

            }
            .navigationTitle(metric.title)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharedDenied(_ ):
                    Button("Configuración") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancelar", role: .cancel) {
                        
                    }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Agregar") {
                        addDataToHealthKit()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Descartar") {
                        isShowingAddData = false
                    }
                }
            }
        }
    }
    
    private func addDataToHealthKit() {
        guard let value = Double(addValue) else {
            writeError = .invalidValue
            isShowingAlert = true
            addValue = ""
            return
        }
        Task {
            
            do {
                if metric == .steps {
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    hkManager.stepData = try await hkManager.fetchStepCount()
                } else {
                    try await hkManager.addWeightData(for: addDataDate, value: value )
                    
                    async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                    async let weightsForDiffBarChart = hkManager.fetchWeights(daysBack: 29)
                    
                    hkManager.weightData = try await weightsForLineChart
                    hkManager.weightDiffData = try await weightsForDiffBarChart
                }
                
                isShowingAddData = false
            } catch SegError.sharedDenied(let quantityType) {
                writeError = .sharedDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
    
}
 
#Preview {
    NavigationStack {
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
    }
}
