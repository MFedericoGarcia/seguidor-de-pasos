//
//  String+Ext.swift
//  Seguimiento
//
//  Created by Fede Garcia on 12/09/2024.
//

import Foundation

extension String {
    func capitalizedFirstLetter() -> String {
        guard let firstLetter = self.first else { return self }
        return firstLetter.uppercased() + self.dropFirst()
    }
}
