//
//  CategoryCollectionViewCell.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var categoryImage: UIImageView!
    @IBOutlet var categoryTitle: UILabel!
    
    @IBOutlet weak var mainCellView: UIView!

    func displayContent(image: UIImage, title: String) {
        categoryImage.image = image
        categoryTitle.text = title
        categoryImage.contentMode = .scaleToFill
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //mainCellView.layer.cornerRadius = 6
        //mainCellView.layer.masksToBounds = true

        setCornerAndShadows()
    }
    
    func setCornerAndShadows() {
        // Round the corners
        self.mainCellView.layer.cornerRadius = 3
        self.mainCellView.layer.masksToBounds = true
        
        backgroundColor = .clear // very important
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.23
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.black.cgColor
        
    }
    
}
