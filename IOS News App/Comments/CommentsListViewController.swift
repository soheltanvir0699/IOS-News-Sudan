//
//  CommentsListViewController.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

class CommentsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var noCommentView: UIView!

    var comment = [Comments]()
    var status: String = ""
    var count: Int = 0
    
    var news : News = News()

    override func viewWillAppear(_ animated: Bool) {
        getComments(newsid: news.nid!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        setGradientNavigationBar()
        setupTopRightAction()
        self.noCommentView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentListTableViewCell
        populateCell(cell, index: (indexPath as NSIndexPath).row)
        return cell
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func AddCommentsButton(_ sender: UIButton) {
        
        //If user is connected we can load the form
        let checksession = SessionManager()
        if (checksession.isLoggedIn()) {
                let PostVC : AddCommentViewController = storyboard!.instantiateViewController(withIdentifier: "AddCommentViewController") as! AddCommentViewController
                PostVC.news = news
                self.navigationController?.pushViewController(PostVC, animated: true)
        } else { //Else we load login form
            let PostVC : LoginViewController = storyboard!.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(PostVC, animated: true)

        }
        
    }
    
    func setGradientNavigationBar() {
        var colors = [UIColor]()
        colors.append(Constant().LIGHTCOLOR)
        colors.append(Constant().MAINCOLOR)
        navigationController?.navigationBar.setGradientBackground(colors: colors)
    }

    func setupTopRightAction() {
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage(named: "add_circle_outline_white"), style: .done, target: self, action: #selector(AddCommentsButton(_:)))
        
        self.navigationItem.rightBarButtonItem = rightBarButtonItem

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
    
    func getComments(newsid: String) {
        
        self.view.makeToastActivity(.center)
        
        //If we don't have any category list, load the latest posts
        var urlcomments = ""
        urlcomments = ApiManager().SERVER_URL + ApiManager().GET_COMMENTS
        
        guard let url = URL(string: urlcomments) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY, "nid": newsid])
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    
                    if let status = swiftyJsonVar["status"].string {
                        self.status = status
                    }
                    if let count = swiftyJsonVar["count"].int {
                        self.count = count
                    }
                    if let commentsData = swiftyJsonVar["comments"].array {
                        
                        for com in commentsData {
                            let comment_id = com["comment_id"].int
                            let user_id = com["user_id"].int
                            let name = com["name"].string
                            let image_temp = com["image"].string!
                            //let date_time = com["date_time"].string
                            let content = com["content"].string
                            
                            var image = ""
                            if (image_temp != "") {
                                image = ApiManager().SERVER_URL + ApiManager().AVATAR_FOLDER + image_temp
                            }
                            
                            let dateFormatterGet = DateFormatter()
                            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            let dateFormatterPrint = DateFormatter()
                            dateFormatterPrint.dateFormat = "MMMM dd,yyyy"
                            
                            var date_time = ""
                            if let date = dateFormatterGet.date(from: com["date_time"].string!) {
                                date_time = dateFormatterPrint.string(from: date)
                                //print(dateFormatterPrint.string(from: date))
                            }
                            
                            
                            let comm = Comments(comment_id: "\(comment_id ?? 0)",
                                content:content,
                                date_time:date_time,
                                image: image,
                                name: name,
                                user_id: "\(user_id ?? 0)"
                            )
                            self.comment.append(comm)
                            
                        }
                    }
                    if self.comment.count > 0 {
                        self.tableView.isHidden = false
                        self.noCommentView.isHidden = true
                        self.view.hideToastActivity()
                        self.tableView.reloadData()
                    } else {
                        self.tableView.isHidden = true
                        self.noCommentView.isHidden = false
                        self.view.hideToastActivity()
                    }
                case .failure(_):
                    print("Error")
                }
                                
        }
        
    }
    
    
    func populateCell(_ cell: CommentListTableViewCell, index: Int){
        
        cell.comUser.text = self.comment[index].name
        cell.comDate.text = self.comment[index].date_time
        //cell.comImage.text =
        cell.comContent.text = self.comment[index].content

        
        let image = self.comment[index].image
        
        cell.comImage.image = UIImage(named: "ic_people")  //set placeholder image first.
        if (image != "") {
            cell.comImage.downloadImageFrom(link: image!, contentMode: UIView.ContentMode.scaleToFill)  //set your image from link array.
        }
    }
    
    
}
