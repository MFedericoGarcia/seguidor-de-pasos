//
//  SegError.swift
//  Seguimiento
//
//  Created by Fede Garcia on 09/09/2024.
//

import Foundation

enum SegError: LocalizedError {
    case authNotDetermined
    case sharedDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            "Se necesita acceso a datos de Salud"
        case .sharedDenied(_ ):
            "Sin permiso para escribir en memoria"
        case .noData:
            "Sin información"
        case .unableToCompleteRequest:
            "No se pudo completar la tarea"
        case .invalidValue:
            "Valor inválido"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "Sin permiso para acceder a Salud. Por favor ir a Configuración > Salud > Dispositivos y accesos a datos."
        case .sharedDenied(let quantityType):
            "La opción para escribir datos sobre \(quantityType) no está habilitada. \n\nPuedes cambiarla en Configuración > Salud > Dispositivos y accesos a datos."
        case .noData:
            "No hay datos en Salud."
        case .unableToCompleteRequest:
            "\nNo pudemos completar la tarea por el momento. \nPor favor intenta mas tarde o contactese con soporte."
        case .invalidValue:
            "Debe ser un valor numérico con un maximo de un decimal."
        }
    }
}
