//
//  ProductViewCell.swift
//  Gusto Demo
//
//  Created by TCode on 14/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import UIKit

class ProductViewCell: UITableViewCell {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    var product: Product? {
        didSet {
//            mainLabel.text = product?.title
        }
    }
    
    override func layoutSubviews() {
        mainLabel.text = product?.title
    }
    
    public func configure(withProduct product: Product) {
        //TODO update the view
        
        self.product = product
    }
}
