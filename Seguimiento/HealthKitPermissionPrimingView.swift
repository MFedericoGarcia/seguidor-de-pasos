//
//  HealthKitPermissionPrimingView.swift
//  Seguimiento
//
//  Created by Fede Garcia on 16/08/2024.
//

import SwiftUI

struct HealthKitPermissionPrimingView: View {
    
    var description = """
    Esta applicación exhibe información de Health en gráficos interactivos.
    
    Tú puedes también agregar información a Apple Health desde esta app. Tu información permanecerá privada y segura
    """
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 12){
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.4), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Apple Health Integration")
                    .font(.title2).bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health") {
                // code comes here
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .bold()
        }
        .padding(30)
    }
}

#Preview {
    HealthKitPermissionPrimingView()
}
