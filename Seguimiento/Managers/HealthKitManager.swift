//
//  HealthKitManager.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    /// Trae los ultimos 28 días de pasos contados de Health App
    /// - Returns: Array de  ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric] {
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw SegError.authNotDetermined
        }
        let interval = createDateInterval(from: .now, daysBack: 28)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                               options: .cumulativeSum,
                                                               anchorDate: interval.end,
                                                               intervalComponents: .init(day: 1))
        do {
            let stepCounts = try await stepsQuery.result(for: store)
            return stepCounts.statistics().map {
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        } catch HKError.errorNoData {
            throw SegError.noData
        } catch {
            throw SegError.unableToCompleteRequest
        }
    }
    
    /// Trae los (X) últimos días de pesos registrados en Health App
    /// - Parameter daysBack: X: INT  -  Días que queremos conseguir de informacion de hoy para atras
    /// - Returns: Array de ``HealthMetric``
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric] {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw SegError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate,
                                                                 options: .mostRecent,
                                                                anchorDate: interval.end,
                                                               intervalComponents: .init(day: 1))
        do {
            let weights = try await weightQuery.result(for: store)
            return weights.statistics().map {
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .gramUnit(with: .kilo)) ?? 0)
            }
        } catch HKError.errorNoData {
            throw SegError.noData
        } catch {
            throw SegError.unableToCompleteRequest
        }
    }
    
    /// Agrega y guarda Datos de pasos en la app Health ( si tenemos la autorización )
    /// - Parameters:
    ///   - date: Día del registro
    ///   - value: Cantidad de pasos a registrar
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        switch status {
        case .notDetermined:
            throw SegError.authNotDetermined
        case .sharingDenied:
            throw SegError.sharedDenied(quantityType: "stepCount")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date, end: date)
        
        do {
            try await store.save(stepSample)
        } catch {
            throw SegError.unableToCompleteRequest
        }
    }
    
    /// Agrega y guarda Datos de los pesos en la app Health ( si tenemos la autorización )
    /// - Parameters:
    ///   - date: Día del registro
    ///   - value: Cantidad de pasos a registrar
    func addWeightData(for date: Date, value: Double) async throws {
        
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
        case .notDetermined:
            throw SegError.authNotDetermined
        case .sharingDenied:
            throw SegError.sharedDenied(quantityType: "bodyMass")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
      
        let weightQuantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date, end: date)
        
        do {
            try await store.save(weightSample)
        } catch {
            throw SegError.unableToCompleteRequest 
        }
    }
    
    /// Crea el Intervalo de días en formato DateInterval
    /// - Parameters:
    ///   - date: Día de inicio
    ///   - daysBack: Día hasta el cual se quiere extender el intervalo
    /// - Returns: ``DateInterval``
    private func createDateInterval(from date: Date, daysBack: Int) -> DateInterval {
        let calendar = Calendar.current
        let startOfEndDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDay = calendar.date(byAdding: .day, value: -daysBack, to: endDate)!

        return DateInterval(start: startDay, end: endDate)
    }
    
    /// Funciín para agregar informaciín ( datos de pasos y pesos ) a la base de datos de Health, para testeo de la app
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//        
//        for i in 0..<29 {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuantity = HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: .random(in: (83 + Double(i/6)...85 + Double(i/6))))
//            
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate )
//            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//
//        }
//        
//        try! await store.save(mockSamples)
//        print("Dummy data set up")
//    }
}
