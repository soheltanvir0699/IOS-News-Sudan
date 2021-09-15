//
//  ProfileViewController.swift
//  IOS News App
//
//  Created by GajoDev on 27/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LoginView: UIView!

    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var ProfileButton: UIButton!
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var optionsView: UIView!
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var rateButton: UIButton!
    var status: String = ""
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setGradientNavigationBar()
        setCornerAndShadows()
        
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func rateusButton(_ sender: UIButton) {

        SKStoreReviewController.requestReview()
        
    }

    //MARK:- IBAction methods (Click Events)
    @IBAction func LogoutButton(_ sender: UIButton) {
        let checksession = SessionManager()
        checksession.setLogin(isLoggedIn: false)

        welcomeLabel.text = StringManager().Welcome
        registerLabel.text = StringManager().notregistered
        LoginButton.setTitle(StringManager().loginbutton, for: .normal)
        logoutButton.isHidden = true
        RegisterButton.isHidden = false
        ProfileButton.isHidden = true
        LoginButton.isHidden = false

    }

    @IBAction func LoginButton(_ sender: UIButton) {

        let PostVC : LoginViewController = storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(PostVC, animated: true)

    }


    func setGradientNavigationBar() {
        self.navigationController?.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        welcomeLabel.text = StringManager().Welcome
        registerLabel.text = StringManager().notregistered
        RegisterButton.setTitle(StringManager().registernowbutton, for: .normal)
        LoginButton.setTitle(StringManager().loginbutton, for: .normal)
        logoutButton.isHidden = true
        ProfileButton.isHidden = true

        let checksession = SessionManager()
        if (checksession.isLoggedIn()) {
            LoginButton.setTitle(StringManager().editbutton, for: .normal)
            logoutButton.setTitle(StringManager().logoutbutton, for: .normal)
            
            welcomeLabel.text = UserDefaults.standard.string(forKey: "user_name")
            registerLabel.text = UserDefaults.standard.string(forKey: "email")
            RegisterButton.isHidden = true
            logoutButton.isHidden = false
            ProfileButton.isHidden = false
            LoginButton.isHidden = true

        }
        
    }
    
    func setCornerAndShadows() {
        /*
        //Round Corner uiview
        // Round the corners
        self.LoginView.layer.cornerRadius = 3
        self.LoginView.layer.masksToBounds = true
        
        //backgroundColor = .clear // very important
        LoginView.layer.masksToBounds = false
        LoginView.layer.shadowOpacity = 0.23
        LoginView.layer.shadowRadius = 4
        LoginView.layer.shadowOffset = CGSize(width: 0, height: 0)
        LoginView.layer.shadowColor = UIColor.black.cgColor
        */
        //Round Corner uiview
        // Round the corners
        self.optionsView.layer.cornerRadius = 3
        self.optionsView.layer.masksToBounds = true
        
        //backgroundColor = .clear // very important
        optionsView.layer.masksToBounds = false
        optionsView.layer.shadowOpacity = 0.23
        optionsView.layer.shadowRadius = 4
        optionsView.layer.shadowOffset = CGSize(width: 0, height: 0)
        optionsView.layer.shadowColor = UIColor.black.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
    }
}

