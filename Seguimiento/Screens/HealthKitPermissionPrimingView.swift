//
//  HealthKitPermissionPrimingView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView: View {
    
    //MARK: - Variables
    
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermissions = false
    
    var description = """
    Esta applicación exhibe información de Health en gráficos interactivos.
    
    Tú puedes también agregar información a Apple Health desde esta app. Tu información permanecerá privada y segura
    """
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 12){
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.4), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Integración - Apple Health")
                    .font(.title2).bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health") {
                isShowingHealthKitPermissions = true
                
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .bold()
        }
        .padding(30)
        .healthDataAccessRequest(store: hkManager.store,
                                 shareTypes: hkManager.types,
                                 readTypes: hkManager.types,
                                 trigger: isShowingHealthKitPermissions) { result in
            switch result {
            case .success(_):
                dismiss()
            case .failure(_):
                // Handle the error later
                dismiss()
            }
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
        .environment(HealthKitManager())
}
