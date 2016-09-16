//
//  ProfileViewUITests.swift
//  Flare
//
//  Created by Tim Chung on 16/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import XCTest

class ProfileViewUITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
       
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
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
        let friends = app.scrollViews.childrenMatchingType(.TextView).element.value as? String
        XCTAssertEqual(friends, "- Harry Alaceahgbehbd Valtchanovescu\n- Jennifer Alacdhgdfhagj Wisemanescu")
    }

}
