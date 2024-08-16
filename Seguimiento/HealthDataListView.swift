//
//  HealthDataListView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import SwiftUI

struct HealthDataListView: View {
    var metric: HealthMetricContent
    @State var isShowingAddData: Bool = false
    @State var addDataDate: Date = .now
    @State var addValue: String = ""
    
    var body: some View {
        List(0..<28) { i in
            HStack {
                Text(Date(), format: .dateTime.day().month().year())
                Spacer()
                Text(10000, format: .number.precision(.fractionLength(metric == .steps ? 0 : 2)))
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
    }
}
