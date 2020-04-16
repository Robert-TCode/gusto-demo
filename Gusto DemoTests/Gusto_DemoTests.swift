//
//  Gusto_DemoTests.swift
//  Gusto DemoTests
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import CoreData
import XCTest
import OHHTTPStubs

@testable import Gusto_Demo

// !!! Careful
// Tests require being run one by one

class Gusto_DemoTests: XCTestCase {
    
    private static let defaultWait = 5.0
    private static let entityName = "Product"
    private static let imagesWidth: CGFloat = 750.0
    
    var gustoDemoTestingHelper: GustoDemoTestingHelper!
    
    override func setUp() {
        super.setUp()
        
        gustoDemoTestingHelper = GustoDemoTestingHelper()
        gustoDemoTestingHelper.clearStorage(for: Gusto_DemoTests.entityName)
        
        HTTPStubs.stubRequests(passingTest: { request in
            return request.url!.path.contains("products")
        }, withStubResponse: { _ in
            return self.gustoDemoTestingHelper.stubResponse(for: "products.json", statusCode: 200)
        })
    }
    
    // Test if the number of products received matches with the number of products saved in the CoreData (persistence)
    func testFetchCompletionBlock() {
        let expectation = XCTNSNotificationExpectation(name: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue))
        
        NetworkService.fetchProducts(imagesWidth: Gusto_DemoTests.imagesWidth) { (result) in
            switch result {
            case .success(let products):
                
                XCTAssertEqual(products.count, self.gustoDemoTestingHelper.numberOfItemsInPersistentStore(for: Gusto_DemoTests.entityName))
                expectation.fulfill()
                break
                
            case .failure(_):
                // Failed to fetch products
                XCTAssertNotNil(nil)
                expectation.fulfill()
                break
            }
        }
        
        wait(for: [expectation], timeout: Gusto_DemoTests.defaultWait)
    }
    
    // Test if fetched items match
    // The file products.json is a copy of what the server returned at the moment of writting the code
    // The server may respond dynamically and in that case the test will fail
    func testFetchItemsMatch() {
        let jsonData = gustoDemoTestingHelper.jsonData(for: "products.json")
        var expectedProducts = [Product]()
        do {
            let managedObjectContext = gustoDemoTestingHelper.mockPersistentContainer.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = managedObjectContext
            
            // Execute additional modifications for decoding the json
            if let productsJSON = try JSONSerialization.jsonObject(with: jsonData!, options: []) as? [[String : Any]],
                let productsConvertedJSONData = NetworkService.extractProductsData(fromJSONArray: productsJSON, imagesWidth: Gusto_DemoTests.imagesWidth) {
                
                    // Decode products
                    let products = try decoder.decode([Product].self, from: productsConvertedJSONData)
                
                    // Order prodcuts
                    let sortDescriptor1 = NSSortDescriptor(key: "id", ascending: true)
                    let sortedProducts = (products as NSArray).sortedArray(using: [sortDescriptor1])
                    
                    // Filter nil products
                    expectedProducts = sortedProducts.map { (product) in
                        XCTAssertNotNil(product)
                        return product as! Product
                    }
                    
                    // We need to clean the storage to remove the User instances we inserted in the decoding phase!
                    gustoDemoTestingHelper.clearStorage(for: Gusto_DemoTests.entityName)
                
            } else {
                // Failed to parse
                XCTAssertNotNil(nil)
            }
            
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        let expectation = XCTNSNotificationExpectation(name: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue))
        
        // Get the products from server
        NetworkService.fetchProducts(imagesWidth: Gusto_DemoTests.imagesWidth) { (result) in
            switch result {
            case .success(let products):
                
                // Check the match for number of products
                XCTAssertEqual(products.count, self.gustoDemoTestingHelper.numberOfItemsInPersistentStore(for: Gusto_DemoTests.entityName))
                
                // Order products
                let productItems = products
                let sortDescriptor1 = NSSortDescriptor(key: "id", ascending: true)
                let sortedProducts = (productItems as NSArray).sortedArray(using: [sortDescriptor1])
                
                // Check if every and each product matches
                for index in 0..<sortedProducts.count {
                    let actualProduct = sortedProducts[index]
                    
                    XCTAssertNotNil(actualProduct)
                    XCTAssertEqual(expectedProducts[index], actualProduct as! Product)
                }
                
                expectation.fulfill()
                break
                
            case .failure(_):
                // Failed to fetch products
                XCTAssertNotNil(nil)
                expectation.fulfill()
                break
            }
        }
        
        wait(for: [expectation], timeout: Gusto_DemoTests.defaultWait)
    }
    
    // !!! Unfinished test
    // When converting from Data to JSON String and the other way, the fields of a product are changing their order
    // For fixing this, the fields should have a standart priority
    
    // Check if the products are converted correctly for Decodable
    func testConvertProductsJSON() {
        let rawProductJSONData = gustoDemoTestingHelper.jsonData(for: "rawProductsJSON.json")
        let convertedProductJSONData = gustoDemoTestingHelper.jsonData(for: "convertedProductsJSON.json")
        let expectedConvertedProductsString = String(data: convertedProductJSONData!, encoding: String.Encoding.utf8) ?? ""
        
        let expectation = XCTNSNotificationExpectation(name: NSNotification.Name(rawValue: Notification.Name.NSManagedObjectContextDidSave.rawValue))
        
        do {
            if let rawProductJSON = (try JSONSerialization.jsonObject(with: rawProductJSONData!)) as? [[String: Any]] {
                if let convertedData = NetworkService.extractProductsData(fromJSONArray: rawProductJSON, imagesWidth: 828.0) {
                    let actualConvertedProductsString = String(data: convertedData, encoding: String.Encoding.utf8) ?? ""
                    
                    XCTAssertFalse(expectedConvertedProductsString.isEmpty)
                    XCTAssertFalse(actualConvertedProductsString.isEmpty)
                    
                    XCTAssertEqual(expectedConvertedProductsString, actualConvertedProductsString)
                    
                    expectation.fulfill()
                } else {
                    // Failed to convert products data
                    XCTAssertNotNil(nil)
                }
            } else {
                // Failed to parse
                XCTAssertNotNil(nil)
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
            
        wait(for: [expectation], timeout: Gusto_DemoTests.defaultWait)
    }
}
