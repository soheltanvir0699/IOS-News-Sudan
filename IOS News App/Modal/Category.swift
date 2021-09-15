//
//  Category.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation

struct Category {
    let cid : String?
    let category_name : String?
    let category_image : String?
    let post_count : String?
    
    init(cid: String? = nil,
         category_name : String? = nil
        ,category_image : String? = nil
        ,post_count : String? = nil) {
        
        self.cid = cid
        self.category_name = category_name
        self.category_image = category_image
        self.post_count = post_count
        
    }
}
