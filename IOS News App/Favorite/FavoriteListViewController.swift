//
//  FavoriteListViewController.swift
//  IOS News App
//
//  Created by GajoDev on 28/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import GRDB

class FavoriteListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imgnoFav: UIImageView!
    @IBOutlet weak var labnoFav: UILabel!

    @IBOutlet weak var tableView: UITableView!
    var news = [News]()
    var status: String = ""
    var count: Int = 0
    var count_sum: Int = 0
    var count_total: Int = 0
    var pages: Int = 1
    var pagenumber: Int = 1
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        getFavorites()
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labnoFav.numberOfLines = 0
        labnoFav.textAlignment = NSTextAlignment.center
        labnoFav.text = StringManager().favoriteempty
        
        let tableNewscellNib = UINib(nibName: "NewsListTableViewCell", bundle: nil)
        tableView.register(tableNewscellNib, forCellReuseIdentifier: "NewsCell")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        setGradientNavigationBar()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 115
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsListTableViewCell

            populateCell(cell, index: (indexPath as NSIndexPath).row)
            return cell
    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let PostVC : NewsDetailViewController = storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        PostVC.news = self.news[(indexPath as NSIndexPath).row]
        PostVC.indexRow = (indexPath as NSIndexPath).row;
        self.navigationController?.pushViewController(PostVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = news.count - 1
        if indexPath.row == lastElement {
            if (count_sum < count_total) {
                pagenumber += 1
                getFavorites()
            }
        }
    }

    func setGradientNavigationBar() {

        self.navigationController?.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
    
    func getFavorites() {
        
        //We empty the array
        //before reload
        news.removeAll()
        self.view.makeToastActivity(.center)
        
        //Check if news is in favory
        try! dbQueue.read { db in
            let rows = try Row.fetchAll(db, sql: "SELECT * FROM favorite", arguments: [])
            
                for news in rows {
                    let nid = news["nid"]
                    let news_title = news["news_title"]
                    let news_image = news["news_image"]
                    let news_date = news["news_date"]
                    let news_description = news["news_description"]
                    let cat_id = news["cat_id"]
                    let category_name = news["category_name"]
                    let content_type = news["content_type"]
                    let comments_count = news["comments_count"]
                    let video_id = news["video_id"]
                    let video_url = news["video_url"]

                    let news = News(nid: "\(nid ?? 0)",
                        news_title: news_title as? String,
                        news_image: news_image as? String,
                        news_date:news_date as? String,
                        news_description:news_description as? String,
                        cat_id:"\(cat_id ?? 0)",
                        category_name:category_name as? String,
                        content_type:content_type as? String,
                        comments_count:"\(comments_count ?? 0)",
                        video_id:video_id as? String,
                        video_url:video_url as? String
                    )
                    self.news.append(news)
                    
                }
                
                if self.news.count > 0 {
                    
                    imgnoFav.isHidden = true
                    labnoFav.isHidden = true

                    self.view.hideToastActivity()
                    self.tableView.reloadData()

                    self.view.setNeedsLayout()
                    //self.viewToReload.layoutIfNeeded()
                } else {

                    self.view.hideToastActivity()

                    imgnoFav.isHidden = false
                    labnoFav.isHidden = false

                }
        }
    }
    
    
    func populateCell(_ cell: NewsListTableViewCell, index: Int){
        
        
        cell.postTitle.text = self.news[index].news_title
        
        //Text with image
        cell.postDate.text = self.news[index].news_date!
        
        //remove html tags
        let string = self.news[index].news_description
        var str = string!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        
        str = str.withoutHtmlHexaTags

        cell.postDescription.text = str
        
        cell.postComments.text = self.news[index].comments_count!
        
        var image = self.news[index].news_image
        image = image!.replacingOccurrences(of: " ",with: "%20")

        if let imageURL = URL(string: image!), let placeholder = UIImage(named: "logo") {
            cell.postImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        if ((self.news[index].content_type == "youtube") || (self.news[index].content_type == "Upload") || (self.news[index].content_type == "Url")) {
            cell.imagePlay.isHidden = false
        } else {
            cell.imagePlay.isHidden = true
        }

//        cell.postImage.hero.id = self.news[index].news_image

    }
}
