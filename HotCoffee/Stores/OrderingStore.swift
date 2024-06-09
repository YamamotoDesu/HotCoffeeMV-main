//
//  OrderingStore.swift
//  HotCoffee
//
//  Created by Yamamoto Kyo on 2024/05/29.
//

import Foundation

@Observable
class OrderingStore {
    
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
