//
//  SeguimientoApp.swift
//  Seguimiento
//
//  Created by Fede Garcia on 14/08/2024.
//

import SwiftUI

@main
struct SeguimientoApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkManager)
        }
    }
}
