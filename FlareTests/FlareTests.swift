//
//  FlareTests.swift
//  FlareTests
//
//  Created by Georgia Mills on 06/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import XCTest

class FlareTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        let friends = app.scrollViews.childrenMatchingType(.TextView).element.value as? String
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
