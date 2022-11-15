//
//  main.swift
//  MockServer
//
//  Created by Derek Clarkson on 10/11/2022.
//

import Foundation
import Voodoo

@main
struct MyApplication {
    static func main() throws {
        let server = try VoodooServer(verbose: true) {
            Endpoints.config
            Endpoints.bookSearch
            Endpoints.cart
        }
        server.wait()
    }
}
