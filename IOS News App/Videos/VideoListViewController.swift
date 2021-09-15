//
//  VideoListViewController.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

class VideoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var news = [News]()
    var status: String = ""
    var count: Int = 0
    var count_sum: Int = 0
    var count_total: Int = 0
    var pages: Int = 1
    var pagenumber: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        setGradientNavigationBar()
        getVideos(pagenb: pagenumber)
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! VideoListTableViewCell
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
                getVideos(pagenb: pagenumber)
            }
            // handle your logic here to get more items, add it to dataSource and reload tableview
        }
    }
    
    func setGradientNavigationBar() {

        self.navigationController?.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.arrow-down
    }
    
    func getVideos(pagenb: Int) {
        
        self.view.makeToastActivity(.center)

        //If we don't have any category list, load the latest posts
        var urlnews = ""
            urlnews = ApiManager().SERVER_URL + ApiManager().GET_VIDEOS_LIST
        
        guard let url = URL(string: urlnews) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY, "page": pagenb])
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
                        self.count_sum += count
                    }
                    if let count_total = swiftyJsonVar["count_total"].int {
                        self.count_total = count_total
                    }
                    if let pages = swiftyJsonVar["pages"].int {
                        self.pages = pages
                    }
                    
                    if let newsData = swiftyJsonVar["posts"].array {
                        
                        for news in newsData {
                            let nid = news["nid"].int
                            let news_title = news["news_title"].string
                            var news_image = ApiManager().SERVER_URL + ApiManager().IMG_FOLDER + news["news_image"].string!
                            
                            let dateFormatterGet = DateFormatter()
                            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            let dateFormatterPrint = DateFormatter()
                            dateFormatterPrint.dateFormat = "MMMM dd,yyyy"
                            
                            var news_date = ""
                            if let date = dateFormatterGet.date(from: news["news_date"].string!) {
                                news_date = dateFormatterPrint.string(from: date)
                                //print(dateFormatterPrint.string(from: date))
                            }
                            
                            let news_description = news["news_description"].string
                            let cat_id = news["cat_id"].int
                            let category_name = news["category_name"].string
                            let content_type = news["content_type"].string
                            let comments_count = news["comments_count"].int
                            let video_id = news["video_id"].string
                            var video_url = news["video_url"].string

                            //If the content_type is youtube, we will grab the thumb from youtube
                            if (content_type == "youtube") {
                                news_image = ApiManager().YOUTUBE_IMG_FRONT + video_id! + ApiManager().YOUTUBE_IMG_BACK
                            } else if (content_type == "Upload") { //We are on selfvideo upload
                                video_url = ApiManager().SERVER_URL + ApiManager().VIDEO_FOLDER + video_url!
                            }
                            
                            let news = News(nid: "\(nid ?? 0)",
                                news_title: news_title,
                                news_image: news_image,
                                news_date:news_date,
                                news_description:news_description,
                                cat_id:"\(cat_id ?? 0)",
                                category_name:category_name,
                                content_type:content_type,
                                comments_count:"\(comments_count ?? 0)",
                                video_id:video_id,
                                video_url:video_url
                            )
                            self.news.append(news)
                            
                        }
                    }
                    if self.news.count > 0 {
                        self.view.hideToastActivity()
                        self.tableView.reloadData()
                    } else {
                        self.view.hideToastActivity()
                        let image: UIImage = UIImage(named: "ic_no_item")!
                        let imageView = UIImageView(image: image)
                        self.view.addSubview(imageView)
                        
                        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                        imageView.center.x = self.view.center.x
                        imageView.center.y = self.view.center.y
                        
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                        label.textAlignment = NSTextAlignment.center
                        label.text = "No News Available"
                        self.view.addSubview(label)
                        
                        label.center.x = self.view.center.x
                        label.center.y = self.view.center.y + 120 //We put the message under the image
                    }
                    
                case .failure(_):
                    print("Error")
                }                
        }
        
    }
    
    
    func populateCell(_ cell: VideoListTableViewCell, index: Int){
        
        
        cell.postTitle.text = self.news[index].news_title

        cell.postCategoryName.text = self.news[index].category_name

        //Text with image
        cell.postDate.addTextWithImage(text: " " + self.news[index].news_date!, image: UIImage(named: "ic_time")!, imageBehindText: false, keepPreviousText: false)
                
        cell.postComments.addTextWithImage(text: " " + self.news[index].comments_count!, image: UIImage(named: "ic_comment_grey")!, imageBehindText: false, keepPreviousText: false)
        
        var image = self.news[index].news_image
        image = image!.replacingOccurrences(of: " ",with: "%20")

        if let imageURL = URL(string: image!), let placeholder = UIImage(named: "logo") {
            cell.postImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        //Hero image
//        cell.postImage.hero.id = self.news[index].news_image
        
    }
    
    
}
