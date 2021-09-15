//
//  VideoListTableViewCell.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit

class VideoListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postComments: UILabel!
    @IBOutlet weak var postCategoryName: UILabel!
    @IBOutlet weak var imagePlay: UIImageView!

    @IBOutlet weak var mainCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setCornerAndShadows()

        if (Constant().DISABLE_COMMENT == true) {
            postComments.isHidden = true
        }

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
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
