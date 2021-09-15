//
//  RegisterViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerHelpLabel: UILabel!
    @IBOutlet weak var termeprivacyButton: UIButton!
    @IBOutlet weak var alreadyAnAccountLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var bgColorView: UIView!

    @IBAction func LoginButton(_ sender: UIButton) {
        
        let PostVC : LoginViewController = storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(PostVC, animated: true)

    }
    
    @IBAction func privacyButton(_ sender: UIButton) {
        let PostVC : PrivacyViewController = storyboard!.instantiateViewController(withIdentifier: "PrivacyViewController") as! PrivacyViewController
        self.navigationController?.pushViewController(PostVC, animated: true)
        
    }

    
    @IBAction func RegisterButton(_ sender: UIButton) {
        
        self.view.makeToastActivity(.center)

        let parameters = [
            "user_type": "normal",
            "name": nameField.text!, //email
            "email": emailField.text!, //email
            "password": pwdField.text!, //password
            "api_key": ApiManager().API_KEY
        ]
        
        let url = ApiManager().SERVER_URL + ApiManager().REGISTER_URL
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
                                
                                
                                self.view.makeToast("Register Successfully, please login", duration: 4.0, position: .center )
                                
                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true, completion: nil)
                                //                                let profileViewController:ProfileViewController = ProfileViewController()
                                //                              self.present(profileViewController, animated: true, completion: nil)
                                //print("redirect")
                                
                            }
                        }
                    }
                    
                case .failure(_):
                    print("Error")
                }
                
        }
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientNavigationBar()
        setCornerAndShadows()
        setLabelText()
        
        bgColorView.backgroundColor = Constant().MAINCOLOR
        registerButton.backgroundColor = Constant().LIGHTCOLOR
    }
    
    func setGradientNavigationBar() {
        var colors = [UIColor]()
        colors.append(Constant().LIGHTCOLOR)
        colors.append(Constant().MAINCOLOR)
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    func setCornerAndShadows() {
        
        //Round Corner uiview
        // Round the corners
        self.registerView.layer.cornerRadius = 3
        self.registerView.layer.masksToBounds = true
        
        //backgroundColor = .clear // very important
        registerView.layer.masksToBounds = false
        registerView.layer.shadowOpacity = 0.23
        registerView.layer.shadowRadius = 4
        registerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        registerView.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    func setLabelText() {
        registerLabel.text = StringManager().register
        registerButton.setTitle(StringManager().register, for: .normal)
        registerHelpLabel.text = StringManager().registerhelp
        termeprivacyButton.setTitle(StringManager().termsprivacy, for: .normal)
        alreadyAnAccountLabel.text = StringManager().alreadyanaccount
        loginButton.setTitle(StringManager().loginnow, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
}
