//
//  CommentListTableViewCell.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit

class CommentListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var comUser: UILabel!
    @IBOutlet weak var comDate: UILabel!
    @IBOutlet weak var comImage: UIImageView!
    @IBOutlet weak var comContent: UILabel!
    
    @IBOutlet weak var mainCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setRoundAvatar()
    }
    
    func setRoundAvatar() {
        comImage.layer.masksToBounds = false
        comImage.layer.cornerRadius = comImage.frame.height/2
        comImage.clipsToBounds = true

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
