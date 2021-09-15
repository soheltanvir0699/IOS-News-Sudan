//
//  ApiManager.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

class ApiManager {
    
    //Put here 
    var SERVER_URL = "https://api.khaleejtowers.com/"
    var API_KEY = "cda11XtZyEqga5MAuFwS0hz7HD8cjP4x1JVKp3Uos9nYeBQmrT"

    var GET_NEWS_LIST = "api/get_recent_posts/"
    var GET_NEWS_SEARCH = "api/get_search_results/"
    var GET_NEWS_DETAIL = "api/get_news_detail/"
    var GET_CATEGORY_LIST = "api/get_category_index/"
    var GET_CATEGORY_POSTS = "api/get_category_posts/"
    var GET_COMMENTS = "api/get_comments/"
    var POST_COMMENT = "api/post_comment/"
    var IMG_FOLDER = "upload/"
    var CATEGORY_IMG_FOLDER = "upload/category/"
    var VIDEO_FOLDER = "upload/video/"
    var AVATAR_FOLDER = "upload/avatar/"
    var GET_VIDEOS_LIST = "api/get_video_posts/"

    var YOUTUBE_IMG_FRONT = "https://img.youtube.com/vi/"
    var YOUTUBE_IMG_BACK = "/mqdefault.jpg"

    var USER_LOGIN = "api/get_user_login/"
    var FORGET_PASSWORD = "api/forgot_password/"
    var REGISTER_URL = "api/user_register/"
    var PROFILE_UPDATE_URL = "api/update_user_profile/"
    var PROFILE_URL = "api/get_user_profile/"

    var GET_PRIVACY = "api/get_privacy_policy/"

}
