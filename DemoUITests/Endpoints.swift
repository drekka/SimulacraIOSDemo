//
//  Scenarios.swift
//  DemoUITests
//
//  Created by Derek Clarkson on 10/11/2022.
//

import Foundation
import Voodoo

struct Book: Codable {
    let id: String
    let name: String
    let author: String
    let price: Double
}

struct CartItem: Codable {
    let price: Double
    let quantity: Int
}

public enum Endpoints {
    
    public static var config: HTTPEndpoint {
        HTTPEndpoint(.GET, "/app/config", response: .ok(body: .json([
            "version": 1.0,
            "featureFlag": true,
        ])))
    }

    public static var bookSearch: [Endpoint] {

        let book1 = Book(id: "1000-01", name: "Consider Phlebas", author: "Ian M. Banks", price: 25)
        let book2 = Book(id: "1000-02", name: "Surface Detail", author: "Ian M. Banks", price: 30)
        let book3 = Book(id: "1000-03", name: "The State of the Art", author: "Ian M. Banks", price: 20.99)

        return [
            HTTPEndpoint(.GET, "/books", response: .ok(body: .json([book1, book2, book3]))),
            HTTPEndpoint(.GET, "/book/:bookId", response: .dynamic { request, _ in
                switch request.pathParameters.bookId {
                case "1000-01":
                    return .ok(body: .json(book1))
                case "1000-02":
                    return .ok(body: .json(book2))
                case "1000-03":
                    return .ok(body: .json(book3))
                default:
                    return .notFound
                }
            }),
        ]
    }

    public static var cart: [Endpoint] {
        [
            HTTPEndpoint(.GET, "/cart", response: .dynamic { _, cache in
                .ok(body: .json(cache.cart ?? [String: Any]()))
            }),

            HTTPEndpoint(.PUT, "/cart", response: .dynamic { request, cache in

                guard let payload = request.bodyJSON as? [String: Any],
                      let bookId = payload["id"] as? String,
                      let quantity = payload["quantity"] as? Int,
                      let price = payload["price"] as? Double else {
                    return .badRequest()
                }

                var cart: [String: CartItem] = cache.cart ?? [:]
                let cartItem = cart[bookId] ?? CartItem(price: price, quantity: quantity)
                cart[bookId] = CartItem(price: price, quantity: cartItem.quantity + quantity)
                cache.cart = cart

                return .ok()
            }),
        ]
    }
}
