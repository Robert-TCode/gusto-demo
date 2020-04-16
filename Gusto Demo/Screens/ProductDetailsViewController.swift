//
//  ProductDetailsViewController.swift
//  Gusto Demo
//
//  Created by TCode on 15/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var presentationImageView: UIImageView!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var quantityContainerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var alwaysOnMenuLabel: UILabel!
    @IBOutlet weak var ageRestrictionView: UIView!
    
    @IBOutlet weak var orderButton: UIButton!
    
    private var product: Product!
    
    // MARK: - Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        
        // UI Tests configuration
        orderButton.accessibilityIdentifier = "orderItemButtonId"
    }
    
    // MARK: - Setup Controller and View
    
    public func configure(withProduct product: Product) {
        self.product = product
    }
    
    private func configureViews() {
        
        // Configure Ui
        bottomContainerView.backgroundColor = UIColor.gustoOrange
        quantityContainerView.backgroundColor = UIColor.gustoOrange
        ageRestrictionView.backgroundColor = UIColor.gustoOrange
        
        detailsContainerView.layer.cornerRadius = 30
        detailsContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomContainerView.layer.cornerRadius = 33
        
        // Load data in view
        if let url = URL(string: product.image ?? "") {
            presentationImageView.contentMode = .scaleAspectFill
            presentationImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = product.title
        let price = product.listPrice == nil ? "" : "£\(product.listPrice!)"
        priceLabel.text = price
        
        descriptionLabel.text = product.productDescription
        ageRestrictionView.isHidden = !product.ageRestricted
        alwaysOnMenuLabel.isHidden = product.alwaysOnMenu
    }
    
    // MARK: - Controller Actions
    
    @IBAction func actionOrder(_ sender: Any) {
        let alert = UIAlertController(title: "Good choice!", message: "Enjoy your \(product.title ?? "meal")! :)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionBackToMenu(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
