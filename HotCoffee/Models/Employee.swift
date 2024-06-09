//
//  Employee.swift
//  HotCoffee
//
//  Created by Yamamoto Kyo on 2024/06/08.
//

import Foundation

struct Employee: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var role: String
    var department: String
}