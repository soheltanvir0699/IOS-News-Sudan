//
//  Comments.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation

struct Comments {
    let comment_id : String?
    let content : String?
    let date_time : String?
    let image : String?
    let name : String?
    let user_id : String?

    init(comment_id: String? = nil,
         content : String? = nil
        ,date_time : String? = nil
        ,image : String? = nil
        ,name : String? = nil
        ,user_id : String? = nil) {
        
        self.comment_id = comment_id
        self.content = content
        self.date_time = date_time
        self.image = image
        self.name = name
        self.user_id = user_id

    }
}
