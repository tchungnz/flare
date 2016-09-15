//
//  CameraViewControllerUITests.swift
//  Flare
//
//  Created by Tim Chung on 14/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import XCTest

class CameraViewControllerUItests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMapButtonReturnsToMapView() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["backToMapButton"].tap()
        XCTAssert(app.buttons["profileIcon"].exists)
    }
    
    func testRetakeButtonAppears() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["takePhotoButton"].tap()
        XCTAssert(app.buttons["retakePhotoButton"].exists)
    }
    
    func testRetakeButtonGoesBackToPhoto() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["takePhotoButton"].tap()
        app.buttons["retakePhotoButton"].tap()
        XCTAssert(app.buttons["takePhotoButton"].exists)
    }
    
    func testFlashDisappearsAfterFlipButton() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["cameraFlipButton"].tap()
        XCTAssert(app.buttons["flashButton"].exists)
    }
    
    func testTapCameraButtonShowsTextField() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["takePhotoButton"].tap()
        XCTAssert(app.textFields["flareTextInput"].exists)
    }
    
    func testTapCameraButtonShowsToggle() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["takePhotoButton"].tap()
        XCTAssert(app.switches["friendPublicToggle"].exists)
    }

    func testToggleButtonChangesLabel() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["takePhotoButton"].tap()
        app.switches["friendPublicToggle"].tap()
        var text = app.staticTexts["toggleLabel"].label
        XCTAssertEqual(text, "Friends")
    }
    
//    func testSendFlare() {
//        let app = XCUIApplication()
//        app.buttons["Button"].tap()
//        app.buttons["whiteCamera"].tap()
//        let textField = app.textFields["What's going on?"]
//        textField.tap()
//        textField.typeText("They.")
//        sleep(1)
//        app.buttons["Done"].tap()
//        // Set a coordinate near the left-edge, we have to use normalized coords
//        // so you set using percentages, 1% in on the left, 15% down from the top
//        var coord1 = app.coordinateWithNormalizedOffset(CGVectorMake(0.5, 0.90))
//        // Then second coordinate 40 points to the right
//        var coord2 = coord1.coordinateWithOffset(CGVectorMake(0, -200))
//        // Perform a drag from coord1 to coord2
//        // Simulating swipe in from left edge
//        coord1.pressForDuration(0.5, thenDragToCoordinate: coord2)
//        XCTAssert(XCUIApplication().otherElements["They."].exists)
//    }
    
    
//    let app = XCUIApplication()
//    app.buttons["Button"].tap()
//    app.buttons["whiteCamera"].tap()
//
    

    
}
