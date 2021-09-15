//
//  AboutViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var Appname: UILabel!
    @IBOutlet weak var copyright: UILabel!


    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appname = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        Appname.text = appname
        copyright.text = StringManager().copyright

    }
    
    private func centerAll() {
        
        viewPopup.center.x = self.view.center.x
        
    }
    
}
