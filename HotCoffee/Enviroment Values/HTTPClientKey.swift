//
//  HTTPClientKey.swift
//  HotCoffee
//
//  Created by Yamamoto Kyo on 2024/05/29.
//

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
