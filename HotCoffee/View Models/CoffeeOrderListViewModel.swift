//
//  CoffeeOrderListViewModel.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 3/30/24.
//

import Foundation
import Observation

@Observable
class CoffeeOrderListViewModel {
    
    var orders: [CoffeeOrder] = []
    var httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func loadOrders() async throws {
        let resource = Resource(url: APIs.orders.url, modelType: [CoffeeOrder].self)
        orders = try await httpClient.load(resource)
    }
    
}
