//
//  Created by Derek Clarkson on 14/10/2022.
//

import SimulcraCore
import XCTest
import Nimble

/// Simple UI test suite base class that can be used to start a mock server instance before
/// running each test.
open class UITestCase: XCTestCase {

    /// The mock server.
    private(set) var server: Simulcra!

    /// Local app reference.
    private(set) var app: XCUIApplication!

    /// Launch arguments to be passed to your app. These can  be augmented
    /// in each test suite to control feature flags and other things for the test.
    open var launchArguments: [String] {
        [
            "--server", server.url.absoluteString,
        ]
    }

    // Overridden tear down that ensures the server is unloaded.
    override open func tearDown() {
        server = nil
        super.tearDown()
    }

    /// Call to launch the server. This should be done before ``launchApp()``
    ///
    /// - parameter endpoints: The end points needed by the server.
    func launchServer(@EndpointBuilder endpoints: () -> [Endpoint]) throws {
        server = try Simulcra(verbose: true, endpoints: endpoints)
    }

    /// Launches your app, passing the common launch arguments and any additional
    /// arguments.
    ///
    /// - parameter additionalLaunchArguments: Allows you to add additional arguments
    /// to a launch. Note that if you specify an argument twice, the later argument will
    /// override any prior ones.
    func launchApp(additionalLaunchArguments: [String] = []) {
        app = XCUIApplication()
        app.launchArguments = launchArguments + additionalLaunchArguments
        app.launch()
    }
}

// Simple test suite where the same launch is done for every test.
class SimpleUITests: UITestCase {

    override open func setUpWithError() throws {
        try super.setUpWithError()
        try launchServer {
            Endpoint(.GET, "/config", response: .ok(body: .json(["configVersion": 1.0])))
        }
        launchApp()
    }

    func testConfigIsLoaded() throws {
        let configText = app.staticTexts["config-message"].firstMatch
        _ = configText.waitForExistence(timeout: 5.0)
        expect(configText.label) == "Config version: 1.00"
    }
}

// Test suite where each test has it's own setup.
class IndividualUITests: UITestCase {

    func testConfigIsLoaded() throws {

        try launchServer {
            Endpoint(.GET, "/config", response: .ok(body: .json(["configVersion": 1.0])))
        }
        launchApp()

        let configText = app.staticTexts["config-message"].firstMatch
        _ = configText.waitForExistence(timeout: 5.0)
        expect(configText.label) == "Config version: 1.00"
    }
}
