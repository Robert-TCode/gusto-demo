//
//  Product+CoreDataProperties.swift
//  Gusto Demo
//
//  Created by TCode on 15/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var ageRestricted: Bool
    @NSManaged public var alwaysOnMenu: Bool
    @NSManaged public var boxLimit: Int16
    @NSManaged public var createdAt: String?
    @NSManaged public var id: String?
    @NSManaged public var image: String?
    @NSManaged public var isForSale: Bool
    @NSManaged public var isVatable: Bool
    @NSManaged public var listPrice: String?
    @NSManaged public var productDescription: String?
    @NSManaged public var productZone: String?
    @NSManaged public var tags: NSObject?
    @NSManaged public var title: String?
    @NSManaged public var volume: Int32

}
