//
//  AddCoffeeOrderScreen.swift
//  HotCoffee
//
//  Created by Mohammad Azam on 8/14/23.
//

import SwiftUI

struct AddCoffeeOrderScreen: View {

    @Environment(CoffeeStore.self) private var coffeeStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var coffeeName: String = ""
    @State private var total: Double = 0.0
    @State private var size: CoffeeSize = .medium
    @State private var saving: Bool = false
    
    private var isFormValid: Bool {
        return true 
    }

    private func placeOrder() async {

        do {
            let order = CoffeeOrder(name: name, coffeeName: coffeeName, total: total, size: size)
            try await coffeeStore.placeOrder(coffeeOrder: order)
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
    AddCoffeeOrderScreen()
        .environment(CoffeeStore(httpClient: HTTPClient()))
}
