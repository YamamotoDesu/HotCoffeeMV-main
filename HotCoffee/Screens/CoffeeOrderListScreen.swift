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
