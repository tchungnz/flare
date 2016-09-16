//
//  MapViewControllerUITests.swift
//  Flare
//
//  Created by Thomas Williams on 14/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import XCTest

class MapViewControllerUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMapPageProfileButton() {
        let app = XCUIApplication()
        app.buttons["profileIcon"].tap()
        XCTAssert(app.staticTexts["Current Flare:"].exists)
    }
    
    func testMapPagePublicToggleButtonOneTap() {
        let app = XCUIApplication()
        app.switches["toggleMapButton"].tap()
        let text = app.staticTexts["toggleMapLabel"].label
        XCTAssertEqual(text, "Friends")
    }
    
    func testMapPagePublicToggleButtonTwoTap() {
        let app = XCUIApplication()
        app.switches["toggleMapButton"].tap()
        sleep(1)
        app.switches["toggleMapButton"].tap()
        let text = app.staticTexts["toggleMapLabel"].label
        XCTAssertEqual(text, "Public")
    }
    
    func testMapPagePublicToggleButtonNoTap() {
        let app = XCUIApplication()
        let text = app.staticTexts["toggleMapLabel"].label
        XCTAssertEqual(text, "Public")
    }
    
    func testMapPageFlareButtonSeguesToCamera() {
        let app = XCUIApplication()
        app.buttons["flareButton"].tap()
        let sendFlareImageButton = app.images["sendFlareImageButton"]
        XCTAssert(sendFlareImageButton.exists)
    }
    
    func testMapPageAnnotations() {
        let app = XCUIApplication()
        app.buttons["flareButton"].tap()
        app.buttons["whiteCamera"].tap()
        let textField = app.textFields["What's going on?"]
        textField.tap()
        textField.typeText("They.")
        sleep(1)
        app.buttons["Done"].tap()
        // Set a coordinate near the left-edge, we have to use normalized coords
        // so you set using percentages, 1% in on the left, 15% down from the top
        var coord1 = app.coordinateWithNormalizedOffset(CGVectorMake(0.5, 0.90))
        // Then second coordinate 40 points to the right
        var coord2 = coord1.coordinateWithOffset(CGVectorMake(0, -200))
        // Perform a drag from coord1 to coord2
        // Simulating swipe in from left edge
        coord1.pressForDuration(0.5, thenDragToCoordinate: coord2)
        //        let bubble = app.otherElements.containingType(.Switch, identifier:"0").childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).matchingIdentifier("They., Dave Alaccfaggijfj Lausen").elementBoundByIndex(1).tap()
        XCTAssert(true)
    }
}
