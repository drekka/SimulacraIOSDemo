//
//  Network.swift
//  SimulcraIOSDemo
//
//  Created by Derek Clarkson on 14/10/2022.
//

import Foundation

enum NetworkError: Error {
    case nonHTTPResponse
    case general
    case serverNotFound
    case invalidPayload
}

class Network: ObservableObject {

    let serverURL: URL

    init(serverURL: URL) {
        self.serverURL = serverURL
    }

    func getConfig() async throws -> [String: Any] {
        let response = try await query(path: "/config")
        switch response.status {
        case 200:
            if let payload = try JSONSerialization.jsonObject(with: response.data) as? [String: Any] {
                return payload
            }
            throw NetworkError.invalidPayload

        case 404:
            throw NetworkError.serverNotFound

        default:
            throw NetworkError.general
        }
    }

    private func query(path: String) async throws -> (status: Int, data: Data) {

        let queryURL = serverURL.appending(path: path)
        let request = URLRequest(url: queryURL)

        let session = URLSession(configuration: .default)
        let response = try await session.data(for: request)

        guard let status = (response.1 as? HTTPURLResponse)?.statusCode else {
            throw NetworkError.nonHTTPResponse
        }

        return (status: status, data: response.0)
    }
}
