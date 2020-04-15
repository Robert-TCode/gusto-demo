//
//  ProductViewCell.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ProductViewCell: UITableViewCell {
    
    @IBOutlet weak var presentationImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    public func configure(withProduct product: Product) {
        
        titleLabel.text = product.title
        
        let price = product.listPrice == nil ? "" : "£\(product.listPrice!)"
        priceLabel.text = price
        
        if let url = URL(string: product.image ?? "") {
            presentationImageView.kf.setImage(with: url)
        }
        
        presentationImageView.contentMode = .scaleAspectFill
        presentationImageView.layer.cornerRadius = 6
    }
}
