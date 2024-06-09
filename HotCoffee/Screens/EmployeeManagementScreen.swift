//
//  EmployeeManagementScreen.swift
//  HotCoffee
//
//  Created by Yamamoto Kyo on 2024/06/08.
//

import SwiftUI

struct EmployeeManagementScreen: View {

    @Environment(OrderingStore.self) private var orderingStore
    @Environment(EmployeeManagementStore.self) private var employeeManagementStore

    var body: some View {
        List {
            Section("Orders") {
                // Better to use OrderListView(orderingStore.stores)
                ForEach(orderingStore.orders) { order in
                    Text(order.name)
                }
            }

            Section("Employees") {
                // Better to use EmployeeListView(employeeManagementStore.employees)
                ForEach(employeeManagementStore.employees) { employee in
                    Text(employee.name)
                }
            }
        }
    }
}

#Preview {
    EmployeeManagementScreen()
        .environment(EmployeeManagementStore())
        .environment(OrderingStore(httpClient: HTTPClient()))
}
