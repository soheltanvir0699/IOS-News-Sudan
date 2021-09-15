//
//  UpdateProfileViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class UpdateProfileViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var registerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientNavigationBar()
        setCornerAndShadows()
        getProfil()
        
        saveButton.setTitle(StringManager().save, for: .normal)
    }
    
    
    @IBAction func SaveButton(_ sender: UIButton) {
        
        self.view.makeToastActivity(.center)
        let userid = UserDefaults.standard.string(forKey: "user_id")

        let parameters = [
            "user_id": userid!, //email
            "name": nameField.text!, //email
            "email": emailField.text!, //email
            "password": pwdField.text!, //password
            "api_key": ApiManager().API_KEY
        ]
        
        let url = ApiManager().SERVER_URL + ApiManager().PROFILE_UPDATE_URL
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
                                self.view.makeToast("Profile Successfully updated", duration: 4.0, position: .center )
                                UserDefaults.standard.set(self.nameField.text, forKey: "user_name")
                                UserDefaults.standard.set(self.emailField.text, forKey: "email")
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
    
    func getProfil() {
        
        self.view.makeToastActivity(.center)
        
        //If we don't have any category list, load the latest posts
        var urlcomments = ""
        urlcomments = ApiManager().SERVER_URL + ApiManager().PROFILE_URL
        
        let userid = UserDefaults.standard.string(forKey: "user_id")

        guard let url = URL(string: urlcomments) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY, "id": userid!])
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    self.view.hideToastActivity()
                    
                    if let result = swiftyJsonVar["result"].array {
                        
                        for res in result {
                            self.view.hideToastActivity()
                            
                            if (res["success"].string == "0") {
                                self.view.makeToast(res["msg"].string, duration: 4.0, position: .bottom )
                            }
                            
                            if (res["success"].string == "1") {
                                
                                self.emailField.text = res["email"].string
                                self.nameField.text = res["name"].string
                                self.pwdField.text = res["password"].string
                                let image_temp = res["image"].string
                                var image = ""
                                if (image_temp != "") {
                                    
                                    
                                    let image = ApiManager().SERVER_URL + ApiManager().AVATAR_FOLDER + image_temp!
                                    if let imageURL = URL(string: image), let placeholder = UIImage(named: "logo") {
                                        self.avatar.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
                                    }
                                }
                                
                            }
                        }
                    }
                    
                case .failure(_):
                    print("Error")
                }
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
}
