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
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var productSearchBar: UISearchBar!
    @IBOutlet weak var productsTableView: UITableView!
    
    var persistentContainer: NSPersistentContainer!
    var productsData = [NSManagedObject]()
    
    var filteredProductsData = [NSManagedObject]()
    var isFilterActive: Bool = false
    var filterTitleString: String? = nil {
        didSet {
            filterProducts()
        }
    }
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitle()
        setupSearchBar()
        setupContainer()
        setupTableView()
       
        fetchData()
    }
    
    // MARK: - Setup Controller and View
    
    private func setupTitle() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        
        let attributedString = NSMutableAttributedString(string: "Gusto Market",
                                                         attributes: [.paragraphStyle: paragraph])
        attributedString.addAttribute(.foregroundColor, value: UIColor.gustoOrange, range: NSRange(location: 0, length: 12))
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Thin", size: 28)!, range: NSRange(location: 0, length: 5))
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 28)!, range: NSRange(location: 6, length: 6))
        
        titleTextView.attributedText = attributedString
    }
    
    private func setupSearchBar() {
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: "HelveticaNueue", size: 14)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont(name: "HelveticaNueue", size: 14)
               
        productSearchBar.delegate = self
        
         // UI Tests configuration
        productSearchBar.searchTextField.accessibilityIdentifier = "searchBarProductsId"
    }
    
    private func setupTableView() {
        productsTableView.delegate = self
        productsTableView.dataSource = self
        
         // UI Tests configuration
        productsTableView.accessibilityIdentifier = "productsTableViewId"
    }
    
    private func setupContainer() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let persistent = delegate?.persistentContainer {
            persistentContainer = persistent
        } else {
            print("Failed to find persistent container")
        }
    }
    
    // MARK: - Fetch Data
    
    private func fetchData() {
        // Double the screen width for a better quality like using assets (2x for most of the iPhones)
        let imagesWidth: CGFloat = 2 * UIScreen.main.bounds.width
        
        NetworkService.fetchProducts(imagesWidth: imagesWidth) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.saveContext()
                    self.loadSavedData()
                }
            case .failure(let error):
                print("Error while fetching products from server ", error)
                
                // Failed to fetch data, load saved products
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.loadSavedData()
                }
            }
        }
    }
    
    // MARK: - Database Functions
    
    func loadSavedData() {
        let request: NSFetchRequest<Product> = Product.fetchRequest()
        do {
            productsData = try persistentContainer.viewContext.fetch(request)
            self.productsTableView.reloadData()
        } catch {
            print("Fetch saved products failed")
        }
    }
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            persistentContainer.performBackgroundTask { (context) in
                do {
                    self.clearStorage()
                    try context.save()
                } catch {
                    print("An error occurred while saving")
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

// MARK: - Tableview Configuration

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFilterActive ? filteredProductsData.count : productsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let productCell = tableView.dequeueReusableCell(withIdentifier: "ProductViewCell")
            as? ProductViewCell else {
                return UITableViewCell()
        }
        
        let product = isFilterActive ? filteredProductsData[indexPath.row] as! Product : productsData[indexPath.row] as! Product
        productCell.configure(withProduct: product)
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.clear
        productCell.selectedBackgroundView = bgColorView
        
        // UI Tests configuration
        productCell.accessibilityIdentifier = "productCell\(indexPath.row)"
        
        return productCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let productDetailsViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController")
            as? ProductDetailsViewController else {
            return
        }
        
        let product = isFilterActive ? filteredProductsData[indexPath.row] as! Product : productsData[indexPath.row] as! Product
        
        productDetailsViewController.configure(withProduct: product)
        self.navigationController?.pushViewController(productDetailsViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
}

// MARK: - SearchBar Delegate and Filter

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTitleString = searchText
        
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func filterProducts() {
        guard let validTitleString = filterTitleString,
            validTitleString.isEmpty == false else {
                isFilterActive = false
                filteredProductsData.removeAll()
                productsTableView.reloadData()
            return
        }
        
        let trimmedFilterString = String(validTitleString.lowercased().trimmingCharacters(in: .whitespaces))
        filteredProductsData.removeAll()
        
        for productData in productsData {
            let product = productData as! Product
            if let trimmedTitle = product.title?.lowercased().trimmingCharacters(in: .whitespaces) {
                if trimmedTitle.contains(trimmedFilterString) {
                    filteredProductsData.append(productData)
                }
            }
        }
        
        isFilterActive = true
        productsTableView.reloadData()
    }
}
