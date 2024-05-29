//
//  CoffeeOrderListScreen.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 8/14/23.
//

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
