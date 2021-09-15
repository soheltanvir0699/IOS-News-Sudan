//
//  PrivacyViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var privacyWeb: WKWebView!

    var privacy: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getPrivacy()
    }
    
    func getPrivacy() {
        
        self.view.makeToastActivity(.center)
        
        //If we don't have any category list, load the latest posts
        var urlcomments = ""
        urlcomments = ApiManager().SERVER_URL + ApiManager().GET_PRIVACY
        
        guard let url = URL(string: urlcomments) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY])
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    if let privacy = swiftyJsonVar["privacy_policy"].string {
                        self.view.hideToastActivity()
                        self.privacy = privacy
                        self.privacyWeb.loadHTML(fromString: privacy)
                        
                    }

                    
                case .failure(_):
                    print("Error")
                }
                            
        }
        
    }
    
}
