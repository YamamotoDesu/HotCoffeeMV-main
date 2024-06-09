## Migrating from MVVM to MV

###  Services in Views - Part 1(Remove the View Model)

CoffeeOrderListScreen.swift
```swift
import SwiftUI

struct CoffeeOrderListScreen: View {

    @Environment(\.httpClient) private var httpClient

    // 1. Remove the View Model
    // let coffeeOrderListVM: CoffeeOrderListViewModel
    @State private var isPresented: Bool = false

    // 2. Replace the view model with
    @State private var orders: [CoffeeOrder] = []

    // 1. Remove the View Model
    // init(coffeeOrderListVM: CoffeeOrderListViewModel) {
    //     self.coffeeOrderListVM = coffeeOrderListVM
    // }

    private func loadOrders() async {

        // 2. Replace the view model with
        do {
            let resource = Resource(url: APIs.orders.url, modelType: [CoffeeOrder].self)
            orders = try await httpClient.load(resource)
        } catch {
            print(error)
        }
    }

    var body: some View {
        // 1. Remove the View Model
        // List(coffeeOrderListVM.orders) { order in
        //    NavigationLink(value: order) {
        //        Text(order.name)
        //    }
        // }
        List(orders) { order in
            NavigationLink(value: order) {
                Text(order.name)
            }
        }
        .navigationDestination(for: CoffeeOrder.self, destination: { coffeeOrder in
            CoffeeDetailScreen(coffeeOrder: coffeeOrder)
        })
        .task {
            do {
                // 1. Remove the View Model
                // try await coffeeOrderListVM.loadOrders()

                // 2. Replace the view model with
                await loadOrders()

            } catch {
                print(error.localizedDescription)
            }
        }.navigationTitle("Orders")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Order") {
                        isPresented = true
                    }
                }
            })
            .sheet(isPresented: $isPresented, content: {

                // 1. Remove the View Model
                //   AddCoffeeOrderScreen(addOrderVM: AddOrderViewModel(httpClient: HTTPClient(), onSave: { coffeeOrder in
                //      coffeeOrderListVM.orders.append(coffeeOrder)
                //   }))
            })
    }
}

#Preview {
    NavigationStack {

        // 1. Remove the View Model
        // CoffeeOrderListScreen(coffeeOrderListVM: CoffeeOrderListViewModel(httpClient: HTTPClient()))
        
        // 2. Replace the view model with 
        CoffeeOrderListScreen()
            .environment(\.httpClient, HTTPClient())
    }
}
```

HTTPClientKey.swift
```swift
import Foundation
import SwiftUI

private struct HTTPClientKey: EnvironmentKey {
    static let defaultValue: HTTPClient = HTTPClient()
}

extension EnvironmentValues {
    var httpClient: HTTPClient {
        get { self[HTTPClientKey.self] }
        set { self[HTTPClientKey.self] = newValue }
    }
}
```

HotCoffeeApp.swift
```swift
import SwiftUI

@main
struct HotCoffeeApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // 1. Remove the View Model
                // CoffeeOrderListScreen(coffeeOrderListVM: CoffeeOrderListViewModel(httpClient: HTTPClient()))

                // 2. Replace the view model with 
                CoffeeOrderListScreen()
            }.environment(\.httpClient, HTTPClient())
        }
    }
}
```

Services in Views - Part 2(Closure and Binding patterns)

CoffeeOrderListScreen
```swift
//
//  CoffeeOrderListScreen.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 8/14/23.
//

import SwiftUI

struct CoffeeOrderListScreen: View {

    @Environment(\.httpClient) private var httpClient

    // 1. Remove the View Model
    // let coffeeOrderListVM: CoffeeOrderListViewModel
    @State private var isPresented: Bool = false

    // 2. Replace the view model with
    @State private var orders: [CoffeeOrder] = []

    // 1. Remove the View Model
    // init(coffeeOrderListVM: CoffeeOrderListViewModel) {
    //     self.coffeeOrderListVM = coffeeOrderListVM
    // }

    private func loadOrders() async {

        // 2. Replace the view model with
        do {
            let resource = Resource(url: APIs.orders.url, modelType: [CoffeeOrder].self)
            orders = try await httpClient.load(resource)
        } catch {
            print(error)
        }
    }

    var body: some View {
        // 1. Remove the View Model
        // List(coffeeOrderListVM.orders) { order in
        //    NavigationLink(value: order) {
        //        Text(order.name)
        //    }
        // }
        List(orders) { order in
            NavigationLink(value: order) {
                Text(order.name)
            }
        }
        .navigationDestination(for: CoffeeOrder.self, destination: { coffeeOrder in
            CoffeeDetailScreen(coffeeOrder: coffeeOrder)
        })
        .task {
            do {
                // 1. Remove the View Model
                // try await coffeeOrderListVM.loadOrders()

                // 2. Replace the view model with
                await loadOrders()

            } catch {
                print(error.localizedDescription)
            }
        }.navigationTitle("Orders")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Order") {
                        isPresented = true
                    }
                }
            })
            .sheet(isPresented: $isPresented, content: {

                // 1. Remove the View Model
                //   AddCoffeeOrderScreen(addOrderVM: AddOrderViewModel(httpClient: HTTPClient(), onSave: { coffeeOrder in
                //      coffeeOrderListVM.orders.append(coffeeOrder)
                //   }))

                // 3. Services in Views - Part 2(Closure pattern)
                // AddCoffeeOrderScreen { order in
                //   orders.append(order)
                // }

                // 3. Services in Views - Part 2(Binding pattern)]
                AddCoffeeOrderScreen(orders: $orders)
            })
    }
}

#Preview {
    NavigationStack {

        // 1. Remove the View Model
        // CoffeeOrderListScreen(coffeeOrderListVM: CoffeeOrderListViewModel(httpClient: HTTPClient()))
        
        // 2. Replace the view model with 
        CoffeeOrderListScreen()
            .environment(\.httpClient, HTTPClient())
    }
}
```

AddCoffeeOrderScreen
```dart
//
//  AddCoffeeOrderScreen.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 8/14/23.
//

import SwiftUI

struct AddCoffeeOrderScreen: View {

    // 3. Services in Views - Part 2(Binding pattern)
    @Binding var orders: [CoffeeOrder]

    // 3. Services in Views - Part 2
    @Environment(\.httpClient) private var httpClient
    // 3. Services in Views - Part 2(Closure pattern)
    // var onSave: (CoffeeOrder) -> Void

    // 3. Remove the View model
    // let addOrderVM: AddOrderViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var coffeeName: String = ""
    @State private var total: Double = 0.0
    @State private var size: CoffeeSize = .medium
    @State private var saving: Bool = false
    
    private var isFormValid: Bool {
        return true 
    }

    // 3. Services in Views - Part 2
    private func placeOrder() async {

        do {
            let order = CoffeeOrder(name: name, coffeeName: coffeeName, total: total, size: size)
            let data = try JSONEncoder().encode(order)

            let resource = Resource(url: APIs.addOrder.url, method: .post(data), modelType: CoffeeOrder.self )

            let newOrder = try await httpClient.load(resource)
            orders.append(newOrder)
           // onSave(newOrder)
        } catch {
            print(error)
        }

    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Coffee Name", text: $coffeeName)
            TextField("Total", value: $total, format: .number)
            
            Picker("Coffee Size", selection: $size) {
                ForEach(CoffeeSize.allCases) { size in
                    Text(size.rawValue)
                }
            }.pickerStyle(.segmented)
            
            HStack {
                Spacer()
                Button("Place Order") {
                    saving = true
                }.buttonStyle(.borderedProminent)
                    .task(id: saving) {
                        if saving {
                            // 3. Remove the View model
                            // do {

                            // try await addOrderVM.placeOrder(name: name, coffeeName: coffeeName, total: total, size: size)

                            // saving = false
                            // dismiss()
                            // } catch {
                            // print(error.localizedDescription)
                            // }

                            // 3. Services in Views - Part 2
                            await placeOrder()

                            saving = false
                            dismiss()
                        }
                    }
                
                Spacer()
            }
        }
    }
}

#Preview {
    // 3. Remove the View model
    // AddCoffeeOrderScreen(addOrderVM: AddOrderViewModel(httpClient: HTTPClient(), onSave: { _ in }))

    // 3. Services in Views - Part 2(Closure Pattern)
    // AddCoffeeOrderScreen { _ in }

    // 3. Services in Views - Part 2(Binding Pattern)
    AddCoffeeOrderScreen(orders: .constant([]))
}
```

## Aggregate Model/DataStore in Views

CoffeeStore.swift

```swift
import Foundation

@Observable
class CoffeeStore {
    
    let httpClient: HTTPClient

    var orders: [CoffeeOrder] = []

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func loadOrders() async throws {
        let resource = Resource(url: APIs.orders.url, modelType: [CoffeeOrder].self)
        orders = try await httpClient.load(resource)
    }

    func placeOrder(coffeeOrder: CoffeeOrder) async throws {

        let coffeeOrderData = try JSONEncoder().encode(coffeeOrder)

        let resource = Resource(url: APIs.addOrder.url, method: .post(coffeeOrderData), modelType: CoffeeOrder.self)
        let savedCoffeeOrder = try await httpClient.load(resource)
        orders.append(savedCoffeeOrder)
    }
}
```

HotCoffeeApp.swift

```swift
import SwiftUI

@main
struct HotCoffeeApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CoffeeOrderListScreen()
            }.environment(CoffeeStore(httpClient: HTTPClient()))
        }
    }
}
```

CoffeeOrderListScreen.swift

```swift
import SwiftUI

struct CoffeeOrderListScreen: View {

    @Environment(CoffeeStore.self) private var coffeeStore
    @State private var isPresented: Bool = false

    var body: some View {
        List(coffeeStore.orders) { order in
            NavigationLink(value: order) {
                Text(order.name)
            }
        }
        .navigationDestination(for: CoffeeOrder.self, destination: { coffeeOrder in
            CoffeeDetailScreen(coffeeOrder: coffeeOrder)
        })
        .task {
            do {
                try await coffeeStore.loadOrders()
            } catch {
                print(error.localizedDescription)
            }
        }.navigationTitle("Orders")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Order") {
                        isPresented = true
                    }
                }
            })
            .sheet(isPresented: $isPresented, content: {

                //AddCoffeeOrderScreen(orders: $orders)
            })
    }
}

#Preview {
    NavigationStack {
        CoffeeOrderListScreen()
            .environment(CoffeeStore(httpClient: HTTPClient()))

    }
}

```

## Bounded Context
<img width="782" alt="image" src="https://github.com/YamamotoDesu/HotCoffeeMV-main/assets/47273077/3aee9693-bd19-40da-a4c1-699058d31a7b">

```swift
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
```

## Screen vs View

<img width="751" alt="image" src="https://github.com/YamamotoDesu/HotCoffeeMV-main/assets/47273077/ff15b413-73e0-4fe8-a592-5d0a383d8f00">

