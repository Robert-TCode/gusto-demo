//
//  NetworkService.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case badURL
    case badStatus
    case badJSON
    case requestError
}

class NetworkService {
    
    static private let productsUrlString = "https://api.gousto.co.uk/products/v2.0/products?includes[]=cat"
    
    static func fetchProducts(inContainer container: NSPersistentContainer, completion: @escaping (Result<[Product], NetworkError>) -> ()) {
        
        guard let url = URL(string: productsUrlString) else {
            completion(.failure(.badURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
                        
                        let productsData = try JSONSerialization.data(withJSONObject: productsJSONData, options: [])
                            
                        let decoder = JSONDecoder()
                        decoder.userInfo[CodingUserInfoKey.managedObjectContext!] = container.viewContext
                    
                        let products = try decoder.decode([Product].self, from: productsData)
                        completion(.success(products))
                    
                } else {
                    completion(.failure(.badJSON))
                }
                
            } catch _ {
                completion(.failure(.badJSON))
            }
            
        }.resume()
    }
}
