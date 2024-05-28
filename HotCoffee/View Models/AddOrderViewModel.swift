//
//  AddOrderViewModel.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 3/30/24.
//

import Foundation
import Observation

@Observable
class AddOrderViewModel {
    
    var httpClient: HTTPClient
    var onSave: (CoffeeOrder) -> Void
    
    init(httpClient: HTTPClient, onSave: @escaping (CoffeeOrder) -> Void) {
        self.httpClient = httpClient
        self.onSave = onSave
    }
    
    func placeOrder(name: String, coffeeName: String, total: Double, size: CoffeeSize) async throws {
        
        let coffeeOrder = CoffeeOrder(name: name, coffeeName: coffeeName, total: total, size: size)
        let coffeeOrderData = try JSONEncoder().encode(coffeeOrder)
        
        let resource = Resource(url: APIs.addOrder.url, method: .post(coffeeOrderData), modelType: CoffeeOrder.self)
        let savedCoffeeOrder = try await httpClient.load(resource)
        onSave(savedCoffeeOrder)
    }
    
}
