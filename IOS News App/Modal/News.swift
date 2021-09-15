//
//  News.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import GRDB

struct News {
    let nid : String?
    let news_title : String?
    let news_image : String?
    let news_date : String?
    let news_description : String?
    let cat_id : String?
    let category_name : String?
    let content_type : String?
    let comments_count : String?
    let video_id : String?
    let video_url : String?

    init(nid: String? = nil,
         news_title : String? = nil
        ,news_image : String? = nil
        ,news_date : String? = nil
        ,news_description : String? = nil
        ,cat_id: String? = nil
        ,category_name : String? = nil
        ,content_type : String? = nil
        ,comments_count : String? = nil
        ,video_id : String? = nil
        ,video_url : String? = nil) {
        
        self.nid = nid
        self.news_title = news_title
        self.news_image = news_image
        self.news_date = news_date
        self.news_description = news_description
        self.cat_id = cat_id
        self.category_name = category_name
        self.content_type = content_type
        self.comments_count = comments_count
        self.video_id = video_id
        self.video_url = video_url
    }
}
