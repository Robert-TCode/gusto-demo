//
//  ProductDetailsViewController.swift
//  Gusto Demo
//
//  Created by TCode on 15/04/2020.
//  Copyright © 2020 TCode. All rights reserved.
//

import Foundation
import UIKit

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var product: Product!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = product.title
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
}
