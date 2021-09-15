//
//  ForgotPasswordViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var forgotpwdLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var helpforgotlabel: UILabel!
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var bgColorView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientNavigationBar()
        setCornerAndShadows()
        setLabelText()
        
        bgColorView.backgroundColor = Constant().MAINCOLOR
        sendButton.backgroundColor = Constant().LIGHTCOLOR

    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func ForgotPwdButton(_ sender: UIButton) {
        
        self.view.makeToastActivity(.center)

        let parameters = [
            "email": emailField.text!, //email
            "api_key": ApiManager().API_KEY
        ]
        
        let url = ApiManager().SERVER_URL + ApiManager().FORGET_PASSWORD
        AF.request(url,
                          method: .get,
                          parameters: parameters)
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    
                    if let result = swiftyJsonVar["result"].array {
                        
                        for res in result {
                            self.view.hideToastActivity()
                            
                            if (res["success"].string == "0") {
                                self.view.makeToast(res["msg"].string, duration: 4.0, position: .bottom )
                            }
                            
                            if (res["success"].string == "1") {
                                
                                self.view.makeToast(res["msg"].string, duration: 2.0, position: .bottom )
                            }
                        }
                    }
                    
                case .failure(_):
                    print("Error")
                }
        }
    }
    
    
    func setGradientNavigationBar() {
        var colors = [UIColor]()
        colors.append(Constant().LIGHTCOLOR)
        colors.append(Constant().MAINCOLOR)
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    func setCornerAndShadows(){
        //Round Corner uiview
        // Round the corners
        self.loginView.layer.cornerRadius = 3
        self.loginView.layer.masksToBounds = true
        
        //backgroundColor = .clear // very important
        loginView.layer.masksToBounds = false
        loginView.layer.shadowOpacity = 0.23
        loginView.layer.shadowRadius = 4
        loginView.layer.shadowOffset = CGSize(width: 0, height: 0)
        loginView.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    func setLabelText(){
    
        helpforgotlabel.text = StringManager().forgotdescription
        forgotpwdLabel.text = StringManager().forgotpwd
        sendButton.setTitle(StringManager().sendbutton, for: .normal)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
}
