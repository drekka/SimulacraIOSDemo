//
//  Created by Derek Clarkson on 14/10/2022.
//

import SwiftUI

struct ContentView: View {

    @State private var showAlert = false
    @State private var configVersion: Double?
    @State private var networkError: Error?

    @EnvironmentObject private var network: Network

    var body: some View {
        VStack {

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")

            Spacer()

            if let configVersion {
                Text(verbatim: "Config version: \(configVersion, decimalPlaces: 2)")
                    .accessibilityIdentifier("config-message")
            }
            if let networkError {
                switch networkError {
                case NetworkError.serverNotFound:
                    Text("Config server not found")
                        .accessibilityIdentifier("config-error")
                default:
                    Text("Network error \(networkError.localizedDescription)")
                        .accessibilityIdentifier("config-error")
                }
            }

            Spacer()

            Button("Add to cart") {
                Task {
                    try await network.addToCart()
                }
                showAlert.toggle()
            }
            .accessibilityIdentifier("alert")
            .alert(Text("Item added"), isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .padding()
        .onAppear {
            Task {
                do {
                    let response = try await network.getConfig()
                    configVersion = response["version"] as? Double
                } catch {
                    networkError = error
                }
            }
        }
    }
}

private extension String.StringInterpolation {

    mutating func appendInterpolation(_ double: Double, decimalPlaces: Int = .max) {

        if decimalPlaces == .max {
            appendInterpolation(String(double))
            return
        }

        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = decimalPlaces
        formatter.minimumFractionDigits = decimalPlaces
        if let version = formatter.string(from: double as NSNumber) {
            appendInterpolation(version)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
