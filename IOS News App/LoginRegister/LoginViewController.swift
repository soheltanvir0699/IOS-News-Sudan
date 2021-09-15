//
//  LoginViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var forgotPwdButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var notaccountyet: UILabel!

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var bgColorView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientNavigationBar()
        setCornerAndShadows()
        setLabelText()
        
        bgColorView.backgroundColor = Constant().MAINCOLOR
        loginButton.backgroundColor = Constant().LIGHTCOLOR
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func LoginButton(_ sender: UIButton) {
        
        self.view.makeToastActivity(.center)

        let parameters = [
            "email": loginField.text!, //email
            "password": pwdField.text!, //password
            "api_key": ApiManager().API_KEY
        ]
        
        let url = ApiManager().SERVER_URL + ApiManager().USER_LOGIN
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
                                
                                let savesession = SessionManager()
                                savesession.setLogin(isLoggedIn: true)
                                
                                self.view.makeToast("Login Successfully", duration: 2.0, position: .bottom )
                                UserDefaults.standard.set(res["user_id"].string, forKey: "user_id")
                                UserDefaults.standard.set(res["name"].string, forKey: "user_name")
                                UserDefaults.standard.set(self.loginField.text, forKey: "email")
                                
                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true, completion: nil)
                                
                            }
                        }
                    }
                    
                case .failure(_):
                    print("Error")
                }
                
        }
        
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func RegisterButton(_ sender: UIButton) {
        
        let PostVC : RegisterViewController = storyboard!.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(PostVC, animated: true)

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
        self.loginView.layer.cornerRadius = 3
        self.loginView.layer.masksToBounds = true
        
        loginView.layer.masksToBounds = false
        loginView.layer.shadowOpacity = 0.23
        loginView.layer.shadowRadius = 4
        loginView.layer.shadowOffset = CGSize(width: 0, height: 0)
        loginView.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setLabelText() {
        loginLabel.text = StringManager().loginbutton
        loginButton.setTitle(StringManager().loginbutton, for: .normal)
        forgotPwdButton.setTitle(StringManager().forgotpwd, for: .normal)
        notaccountyet.text = StringManager().notaccount
        registerButton.setTitle(StringManager().registernowbutton, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
}
