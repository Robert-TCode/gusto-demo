//
//  NetworkService.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import UIKit
import CoreData

enum NetworkError: Error {
    case badURL
    case badStatus
    case badJSON
    case requestError
}

class NetworkService {
    
    static private let productsUrlString = "https://api.gousto.co.uk/products/v2.0/products"
    
    static func fetchProducts(inContainer container: NSPersistentContainer, imagesWidth: CGFloat, completion: @escaping (Result<[Product], NetworkError>) -> ()) {
        
        var urlComponents = URLComponents(string: productsUrlString)!
    
        urlComponents.queryItems = [
            URLQueryItem(name: "image_sizes[]", value: "\(imagesWidth)")
        ]
        
        guard let completeURL = urlComponents.url else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: completeURL) { data, response, error in
            if let _ = error {
                completion(.failure(.requestError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestError))
                return
            }
            
            do {
                if let responseJSON = (try JSONSerialization.jsonObject(with: data)) as? [String: Any],
                    let status = responseJSON["status"] as? String,
                    let productsJSONData = responseJSON["data"] as? [[String: Any]] {
                    
                    if status != "ok" {
                        completion(.failure(.badStatus))
                    }
                    
                    guard let productsData = extractProductsData(fromJSONArray: productsJSONData, imagesWidth: imagesWidth) else {
                        print("\nError at extracting products data from json")
                        completion(.failure(.badJSON))
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = container.viewContext
                    
                    let products = try decoder.decode([Product].self, from: productsData)
                    completion(.success(products))
                    
                } else {
                    print("\nUnexpected format\n\(String(decoding: data, as: UTF8.self))")
                    completion(.failure(.badJSON))
                }
                
            } catch _ {
                completion(.failure(.badJSON))
            }
            
        }.resume()
    }
    
    static func extractProductsData(fromJSONArray array: [[String: Any]], imagesWidth: CGFloat) -> Data? {
        var convertedProductsJSON = [[String: Any]]()
        
        for productJSON in array {
            
            let tags = productJSON["tags"] as? [String] ?? []
            if tags.contains("gift") {
                //TODO Special case for gifts
                continue
            }
            
            guard let _ = productJSON["id"] as? String,
                let _ = productJSON["title"] as? String,
                let _ = productJSON["age_restricted"] as? Bool,
                let _ = productJSON["always_on_menu"] as? Bool,
                let _ = productJSON["box_limit"] as? Int,
                let _ = productJSON["created_at"] as? String,
                let _ = productJSON["is_for_sale"] as? Bool,
                let _ = productJSON["is_vatable"] as? Bool,
                let _ = productJSON["list_price"] as? String,
                let _ = productJSON["description"] as? String else {
                    // Product doesn't contain all required fields and won't be displayed
                    continue
            }
            
            guard let allImagesJSON = productJSON["images"] as? [String: Any],
                let matchSizeImage = allImagesJSON["\(imagesWidth)"] as? [String: Any],
                let imageSource = matchSizeImage["src"] as? String else {
                    // Product doesn't contain photos and won't be displayed
                    continue
            }
            
            let zone = productJSON["zone"] as? String ?? ""
            let volume = productJSON["volume"] as? Int ?? 0
            
            var convertedProductJSON = productJSON
            
            convertedProductJSON.updateValue(imageSource, forKey: "image")
            convertedProductJSON.updateValue(zone, forKey: "zone")
            convertedProductJSON.updateValue(volume, forKey: "volume")
            
            convertedProductsJSON.append(convertedProductJSON)
        }
        
        do {
            let productsData = try JSONSerialization.data(withJSONObject: convertedProductsJSON, options: [])
            return productsData
        } catch _ {
            return nil
        }
    }
}
