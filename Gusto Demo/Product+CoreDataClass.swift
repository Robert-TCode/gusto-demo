//
//  Product+CoreDataClass.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Product)
public class Product: NSManagedObject, Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case productDescription = "description"
        case listPrice = "list_price"
        case isVatable = "is_vatable"
        case isForSale = "is_for_sale"
        case ageRestricted = "age_restricted"
        case boxLimit = "box_limit"
        case alwaysOnMenu = "always_on_menu"
        case volume
        case productZone = "zone"
        case createdAt = "created_at"
        case tags
        case image
    }
    
    // MARK: - Decodable
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Product", in: managedObjectContext) else {
            fatalError("Failed to decode Product")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.productDescription = try container.decodeIfPresent(String.self, forKey: .productDescription)
        self.listPrice = try container.decodeIfPresent(String.self, forKey: .listPrice)
        self.isVatable = try container.decodeIfPresent(Bool.self, forKey: .isVatable) ?? false
        self.isForSale = try container.decodeIfPresent(Bool.self, forKey: .isForSale) ?? false
        self.ageRestricted = try container.decodeIfPresent(Bool.self, forKey: .ageRestricted) ?? false
        self.boxLimit = try (container.decodeIfPresent(Int16.self, forKey: .boxLimit) ?? -1)
        self.alwaysOnMenu = try container.decodeIfPresent(Bool.self, forKey: .alwaysOnMenu) ?? false
        self.volume = try container.decodeIfPresent(Int32.self, forKey: .volume) ?? 0
        self.productZone = try container.decodeIfPresent(String.self, forKey: .productZone)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.image = try container.decodeIfPresent(String.self, forKey: .image)
        
        // The default values can be changed for a better fit when having a good understanding of what each field means
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(productDescription, forKey: .productDescription)
        try container.encode(listPrice, forKey: .listPrice)
        try container.encode(isVatable, forKey: .isVatable)
        try container.encode(isForSale, forKey: .isForSale)
        try container.encode(ageRestricted, forKey: .ageRestricted)
        try container.encode(boxLimit, forKey: .boxLimit)
        try container.encode(alwaysOnMenu, forKey: .alwaysOnMenu)
        try container.encode(volume, forKey: .volume)
        try container.encode(productZone, forKey: .productZone)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(tags, forKey: .tags)
        try container.encode(image, forKey: .image)
    }
}
