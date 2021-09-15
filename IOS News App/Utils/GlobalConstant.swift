//
//  GlobalConstant.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//


import UIKit
import Foundation

class Constant{

    var MAINCOLOR = UIColor(red: 13/255, green: 123/255, blue: 20/255, alpha: 6)
    var LIGHTCOLOR = UIColor(red: 10/255, green: 100/255, blue: 200/255, alpha: 9)

    var ADBANNER = "ca-app-pub-1694503539898082/3453739941"
    var ADINTERSTITIAL = "ca-app-pub-1694503539898082/7894374378"

    var NATIVE_AD_ON_NEWS_FEED = true
    var NATIVE_AD_ON_NEWS_FEED_CODE = "ca-app-pub-3940256099942544/3986624511"

    //Here set the number of article the visitor have to open to display interstital
    var NUMBERARTICLETOOPEN = 3
    
    //Disable comments and profile tab
    var DISABLE_COMMENT = false
}
