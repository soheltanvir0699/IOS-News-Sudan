//
//  InternalBrowserVC.swift
//  IOS News App
//
//  Created by Fabien Maurice on 18/06/2020.
//  Copyright © 2020 Fabien Maurice. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class InternalBrowserVC: UIViewController {
    
    let webView = WKWebView()
    var myurl:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: myurl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func loadView() {
        self.view = webView
    }
}
