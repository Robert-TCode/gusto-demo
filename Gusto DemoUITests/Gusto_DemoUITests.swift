//
//  Gusto_DemoUITests.swift
//  Gusto DemoUITests
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import XCTest

class Gusto_DemoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOrderItem() throws {
        let app = XCUIApplication()
        app.launch()

        app.tables["productsTableViewId"].cells["productCell0"].tap()
        
        let orderButton = app.buttons.matching(identifier: "orderItemButtonId").firstMatch
        
        orderButton.tap()
    }
    
    func testSearchItems() throws {
        let app = XCUIApplication()
        app.launch()
        
        let initialCells = app.tables["productsTableViewId"].cells.count
        
        app.searchFields["searchBarProductsId"].tap()
        app.searchFields["searchBarProductsId"].typeText("Chocolate")
        
        let filteredCells = app.tables["productsTableViewId"].cells.count
        
        // The filteredCells number is 35 currently, but since the API respone might be dynamic, I wouldn't compare the result with a fixed number
        XCTAssertGreaterThan(initialCells, filteredCells)
    }
}
