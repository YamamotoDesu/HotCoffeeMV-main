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
