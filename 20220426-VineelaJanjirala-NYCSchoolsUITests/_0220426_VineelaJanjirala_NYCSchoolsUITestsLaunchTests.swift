//
//  _0220426_VineelaJanjirala_NYCSchoolsUITestsLaunchTests.swift
//  20220426-VineelaJanjirala-NYCSchoolsUITests
//
//  Created by Vineela Janjirala on 26/04/22.
//

import XCTest

class _0220426_VineelaJanjirala_NYCSchoolsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}