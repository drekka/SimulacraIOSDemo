//
//  SimulcraIOSDemoApp.swift
//  SimulcraIOSDemo
//
//  Created by Derek Clarkson on 14/10/2022.
//

import SwiftUI

@main
struct SimulcraIOSDemoApp: App {

    private let network: Network

    init() {
        let args = ProcessInfo.processInfo.arguments

        // Find the server launch argument and get the next which should be the url.
        if let idx = args.firstIndex(of: "--server"),
           let server = args.dropFirst(idx + 1).first,
           let url = URL(string: server) {
            network = Network(serverURL: url)
        } else {
            network = Network(serverURL: URL(string: "http://myrealserver.com")!)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(network)
        }
    }
}
