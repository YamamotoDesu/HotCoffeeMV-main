//
//  HotCoffeeApp.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 8/14/23.
//

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
