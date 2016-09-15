//
//  FlareUITests.swift
//  FlareUITests
//
//  Created by Georgia Mills on 06/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import XCTest

class ProfileViewControllerUITests: XCTestCase {
        
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
    
    func testProfilePageHasUserName() {
        let app = XCUIApplication()
        app.buttons["profileIcon"].tap()
        XCTAssert(app.staticTexts["Dave Alaccfaggijfj Lausen"].exists)
    }
    
    func testProfilePageHasEmail() {
        let app = XCUIApplication()
        app.buttons["profileIcon"].tap()
        XCTAssert(app.staticTexts["ixtmobl_lausen_1473860087@tfbnw.net"].exists)
    }
    
    func testProfilePageHasFriends() {
        let app = XCUIApplication()
        app.buttons["profileIcon"].tap()
        let friends = app.scrollViews.textViews.element.value as? String
        XCTAssertEqual(friends, "- Harry Alaceahgbehbd Valtchanovescu\n- Jennifer Alacdhgdfhagj Wisemanescu")
    }
    
    func testKeyBoardAppears() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        app.buttons["whiteCamera"].tap()
        let textField = app.textFields["What's going on?"]
        textField.tap()
        textField.typeText("Daveeeeeee")
        XCTAssert(app.keyboards.count > 0, "The keyboard is not shown")
        
    }
    
    
    
  
}
