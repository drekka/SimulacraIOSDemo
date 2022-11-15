//
//  Created by Derek Clarkson on 14/10/2022.
//

import Nimble
import Voodoo
import XCTest

// Simple test suite where the same launch is done for every test.
class SimpleUITests: UITestCase {

    override open func setUpWithError() throws {

        try super.setUpWithError()

        try launchServer {
            Endpoints.config
            Endpoints.bookSearch
            Endpoints.cart
        }

        launchApp()
    }

    func testConfigIsLoaded() throws {
        let configText = app.staticTexts["config-message"].firstMatch
        _ = configText.waitForExistence(timeout: 5.0)
        expect(configText.label) == "Config version: 1.00"
    }
}
