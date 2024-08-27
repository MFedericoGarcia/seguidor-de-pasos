//
//  Date+Ext.swift
//  Seguimiento
//
//  Created by Fede Garcia on 27/08/2024.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
