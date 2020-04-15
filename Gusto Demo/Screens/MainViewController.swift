//
//  ViewController.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    @IBOutlet weak var productsTableView: UITableView!
    
    var persistentContainer: NSPersistentContainer!
    var productsData = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContainer()
        
        productsTableView.delegate = self
        productsTableView.dataSource = self
        
        fetchData()
    }
    
    private func setupContainer() {
        // Create the persistent container and point to the xcdatamodeld - so matches the xcdatamodeld filename
        persistentContainer = NSPersistentContainer(name: "Gusto_Demo")
        
        // Load the database if it exists, if not create it.
        persistentContainer.loadPersistentStores { storeDescription, error in
            self.persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    private func fetchData() {
        NetworkService.fetchProducts(inContainer: persistentContainer) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.saveContext()
                    self.loadSavedData()
                }
            case .failure(let error):
                print("Failed to fetch products with error ", error)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadSavedData()
                }
            }
        }
    }
    
    func loadSavedData() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        
        do {
            productsData = try persistentContainer.viewContext.fetch(request)
            print("Got \(productsData.count) products")
            
            self.productsTableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            persistentContainer.performBackgroundTask { (context) in
                do {
                    self.clearStorage()
                    print ("Saved")
                    try context.save()
                } catch {
                    print("An error occurred while saving: \(error)")
                }
            }
        }
    }
    
    func clearStorage() {
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }

        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let users = try managedObjectContext.fetch(fetchRequest)
                for user in users {
                    managedObjectContext.delete(user as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductViewCell")
            as? ProductViewCell else {
                return UITableViewCell()
        }
        
        productCell.configure(withProduct: productsData[indexPath.row] as! Product)
        return productCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let productDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController")
            as? ProductDetailsViewController else {
            return
        }
        
        productDetailsViewController.configure(withProduct: productsData[indexPath.row] as! Product)
        self.navigationController?.pushViewController(productDetailsViewController, animated: true)
    }
}
