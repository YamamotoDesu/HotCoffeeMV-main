//
//  EmployeeManagementStore.swift
//  HotCoffee
//
//  Created by Yamamoto Kyo on 2024/06/08.
//

import Foundation
import Observation

@Observable
class EmployeeManagementStore {

    var employees: [Employee] = []

    func addEmployee(name: String, role: String, department: String) {
        let employee = Employee(name: name, role: role, department: department)
        employees.append(employee)
    }

    func getEmployeesByDepartment(department: String) -> [Employee] {
        return employees.filter { $0.department == department }
    }
}
