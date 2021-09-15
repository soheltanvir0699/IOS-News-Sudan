//
//  AddCommentViewController.swift
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

class AddCommentViewController: UIViewController, UITextViewDelegate{
    
    @IBOutlet weak var commentWrite: UITextView!
    var news : News = News()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientNavigationBar()
        configureField()
        setupTopRightAction()
    }
    
    func setGradientNavigationBar() {
        var colors = [UIColor]()
        colors.append(Constant().LIGHTCOLOR)
        colors.append(Constant().MAINCOLOR)
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    func configureField() {
        
        commentWrite.text = "Write your comment..."
        commentWrite.textColor = UIColor.lightGray
        commentWrite.font = UIFont(name: "verdana", size: 13.0)
        commentWrite.returnKeyType = .done
        commentWrite.delegate = self

    }
    
    func setupTopRightAction() {
        
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "ic_send"), style: .done, target: self, action: #selector(SendCommentsButton(_:)))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

    }
    //MARK:- IBAction methods (Click Events)
    @IBAction func SendCommentsButton(_ sender: UIButton) {
        
        if ((commentWrite.text.count == 0) || (commentWrite.text == "Write your comment...")) {
            
            self.view.makeToast("Please write your message first...", duration: 2.0, position: .center )
            return
        }

        if (commentWrite.text.count < 6) {
            self.view.makeToast("your message should be at least 6 characters...", duration: 2.0, position: .center )
            return
        }
        
        self.view.makeToastActivity(.center)
        let userid = UserDefaults.standard.string(forKey: "user_id")
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let parameters = [
            "nid": news.nid!, //post id
            "user_id": userid!, //user_id
            "content": commentWrite.text!, //content
            "date_time": formatter.string(from: currentDateTime), //datetime
            "api_key": ApiManager().API_KEY
        ]
        print(parameters)
        
        let url = ApiManager().SERVER_URL + ApiManager().POST_COMMENT
        AF.request(url,
                          method: .post,
                          parameters: parameters)
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    
                    print(swiftyJsonVar)
                    
                    self.view.hideToastActivity()
                    
                    if (swiftyJsonVar["value"].int == 0) {
                        self.view.makeToast(swiftyJsonVar["message"].string, duration: 4.0, position: .bottom )
                    }
                    
                    if (swiftyJsonVar["value"].int == 1) {
                        
                        
                        self.view.makeToast("Comment send Successfully", duration: 4.0, position: .center )
                        
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                        //                                let profileViewController:ProfileViewController = ProfileViewController()
                        //                              self.present(profileViewController, animated: true, completion: nil)
                        //print("redirect")
                        
                    }
                    
                case .failure(_):
                    print("Error while fetching news")

                }
                
        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
   }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Write your comment..." {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 18.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write your comment..."
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "verdana", size: 13.0)
        }
    }
    
}
