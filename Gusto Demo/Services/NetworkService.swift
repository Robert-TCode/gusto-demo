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

// MARK: - NetworkError

enum NetworkError: Error {
    case badURL
    case badStatus
    case badJSON
    case requestError
    case noContextFound
}

class NetworkService {
    
    static private let productsUrlString = "https://api.gousto.co.uk/products/v2.0/products"
    static private let imageSizeQuery = "image_sizes[]"
    
    // MARK: - Fetch Products Request
    
    static func fetchProducts(imagesWidth: CGFloat, completion: @escaping (Result<[Product], NetworkError>) -> ()) {
        
        var urlComponents = URLComponents(string: productsUrlString)!
    
        urlComponents.queryItems = [
            URLQueryItem(name: imageSizeQuery, value: "\(imagesWidth)")
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
                        return
                    }
                    
                    guard let productsData = extractProductsData(fromJSONArray: productsJSONData, imagesWidth: imagesWidth) else {
                        completion(.failure(.badJSON))
                        return
                    }
                    
                    // Decoding JSON and saving items in CoreData, context is needed
                    // CoreData operation must be performed on main thread for avoiding threads concurrency issues
                    DispatchQueue.main.async {
                        let delegate = UIApplication.shared.delegate as? AppDelegate
                        if let context = delegate?.persistentContainer.viewContext {
                            
                            do {
                                let decoder = JSONDecoder()
                                decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = context
                                
                                let products = try decoder.decode([Product].self, from: productsData)
                                completion(.success(products))
                                
                            } catch _ {
                                completion(.failure(.badJSON))
                            }
                            
                        } else {
                            completion(.failure(.noContextFound))
                        }
                    }
                   
                } else {
                    completion(.failure(.badJSON))
                }
                
            } catch _ {
                completion(.failure(.badJSON))
            }
            
        }.resume()
    }
    
    // MARK: - Extract Product Data
    
    // The JSON response doesn't match exactly the Decodable object Product's fields
    // Extract only porducts data and adapt fields for perfect match
    static func extractProductsData(fromJSONArray array: [[String: Any]], imagesWidth: CGFloat) -> Data? {
        var convertedProductsJSON = [[String: Any]]()
        
        for productJSON in array {
            
            let tags = productJSON["tags"] as? [String] ?? []
            if tags.contains("gift") {
                //TODO Special case for gifts. They probably require different treatment/UI
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
            
            // Remove products without photos from list
            // Just for a neat, better looking design
            guard let allImagesJSON = productJSON["images"] as? [String: Any],
                let matchSizeImage = allImagesJSON["\(imagesWidth)"] as? [String: Any],
                let imageSource = matchSizeImage["src"] as? String else {
                    // Product doesn't contain photos and won't be displayed
                    continue
            }
            
            let zone = productJSON["zone"] as? String ?? ""
            let volume = productJSON["volume"] as? Int ?? 0
            
            var convertedProductJSON = productJSON
            
            // Adapt the new JSON to the Decodable Product object expectations
            convertedProductJSON.updateValue(imageSource, forKey: "image")
            convertedProductJSON.updateValue(zone, forKey: "zone")
            convertedProductJSON.updateValue(volume, forKey: "volume")
            
            convertedProductsJSON.append(convertedProductJSON)
        }
        
        // Convert products JSON to Data for decoding
        do {
            let productsData = try JSONSerialization.data(withJSONObject: convertedProductsJSON, options: [])  
            return productsData
        } catch _ {
            return nil
        }
    }
}
