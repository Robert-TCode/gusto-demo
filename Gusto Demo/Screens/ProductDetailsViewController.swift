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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageRestrictedLabel: UILabel!
    @IBOutlet weak var alwaysOnMenuLabel: UILabel!
    
    @IBOutlet weak var orderButton: UIButton!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        
        orderButton.accessibilityIdentifier = "orderItemButtonId"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    public func configure(withProduct product: Product) {
        self.product = product
    }
    
    private func configureViews() {
        if let url = URL(string: product.image ?? "") {
            presentationImageView.contentMode = .scaleAspectFill
            presentationImageView.kf.setImage(with: url)
        }
        presentationImageView.layer.cornerRadius = 10
        
        titleLabel.text = product.title
        let price = product.listPrice == nil ? "" : "£\(product.listPrice!)"
        priceLabel.text = price
        
        descriptionLabel.text = product.productDescription
        ageRestrictedLabel.isHidden = !product.ageRestricted
        alwaysOnMenuLabel.isHidden = product.alwaysOnMenu
    }
    
    @IBAction func actionOrder(_ sender: Any) {
        let alert = UIAlertController(title: "Good choice!", message: "Enjoy your \(product.title ?? "meal")! :)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thanks", style: .default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }
}
