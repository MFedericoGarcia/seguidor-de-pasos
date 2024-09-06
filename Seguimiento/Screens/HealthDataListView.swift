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
        List(listData.reversed()) { i in
            HStack {
                Text(i.date, format: .dateTime.day().month().year())
                Spacer()
                Text(i.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData){
            addDataView
        }
        .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
            switch writeError {
            case .authNotDetermined, .noData, .unableToCompleteRequest:
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
        .toolbar{
            Button("Add Data", systemImage: "plus") {
                Task {
                    if metric == .steps {
                        do {
                            try await hkManager.addStepData(for: addDataDate, value: Double(addValue)!)
                            try await hkManager.fetchStepCount()
                            isShowingAddData = false
                        } catch SegError.sharedDenied(let quantityType) {
                            writeError = .sharedDenied(QuantityType: quantityType)
                            isShowingAlert = true
                        } catch {
                            writeError = .unableToCompleteRequest
                            isShowingAlert = true
                        }
                    } else {
                        do {
                            try await hkManager.addWeightData(for: addDataDate, value: Double(addValue)!)
                            try await hkManager.fetchWeights()
                            try await hkManager.fetchWeightsForDifferentials()
                            isShowingAddData = false
                        } catch SegError.sharedDenied(let quantityType) {
                            writeError = .sharedDenied(QuantityType: quantityType)
                            isShowingAlert = true
                        } catch {
                            writeError = .unableToCompleteRequest
                            isShowingAlert = true
                        }
                    }
                }
            }
        }
    }
    
    var addDataView: some View {
        NavigationStack {
            Form{
                DatePicker("Fecha", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Valor", text: $addValue)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Agregar") {
                        // code later
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
}
 
#Preview {
    NavigationStack {
        HealthDataListView(metric: .weight)
            .environment(HealthKitManager())
    }
}
