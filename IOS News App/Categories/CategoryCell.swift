//
//  CategoryCell.swift
//  IOS News App
//
//  Created by Fabien Maurice on 31/10/2019.
//  Copyright © 2019 Fabien Maurice. All rights reserved.
//

import Foundation
import UIKit
import CollectionView

class CategoryCell: Cell {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        self.textLabel.textColor = .black

        self.imageView.layer.cornerRadius = 8
        self.imageView.layer.masksToBounds = true
    }
    
    override func reset() {
        super.reset()
        
        self.textLabel.text = nil
        self.imageView.image = nil
    }
}
