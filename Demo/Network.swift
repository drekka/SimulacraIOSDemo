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
        let response = try await query(path: "/app/config")
        if let payload = try JSONSerialization.jsonObject(with: response.data) as? [String: Any] {
            return payload
        }
        throw NetworkError.invalidPayload
    }

    func addToCart() async throws {
        _ = try await query(method: "PUT", path: "/cart", payload: [
            "id": "1000-01",
            "quantity": 1,
            "price": 10.99,
        ])
    }

    private func query(method: String = "GET", path: String, payload: Any? = nil) async throws -> (status: Int, data: Data) {

        let queryURL = serverURL.appending(path: path)
        var request = URLRequest(url: queryURL)
        request.httpMethod = method
        if let payload {
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let session = URLSession(configuration: .default)
        let response = try await session.data(for: request)

        guard let status = (response.1 as? HTTPURLResponse)?.statusCode else {
            throw NetworkError.nonHTTPResponse
        }

        switch status {
        case 200:
            break

        case 404:
            throw NetworkError.serverNotFound

        default:
            throw NetworkError.general
        }
        return (status: status, data: response.0)
    }
}
