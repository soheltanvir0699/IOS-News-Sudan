//
//  HeaderNewsListTableViewCell.swift
//  IOS News App
//
//  Created by GajoDev on 24/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit

class HeaderNewsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postImage2: UIImageView!
    @IBOutlet weak var postComments: UILabel!
    @IBOutlet weak var postCommentsImage: UIImageView!

    @IBOutlet weak var imagePlay: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        
        if (Constant().DISABLE_COMMENT == true) {
            postComments.isHidden = true
            postCommentsImage.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
