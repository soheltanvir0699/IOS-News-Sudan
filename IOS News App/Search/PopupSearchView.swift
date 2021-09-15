//
//  PopupSearchView.swift
//  IOS News App
//
//  Created by Fabien Maurice on 18/06/2020.
//  Copyright © 2020 Fabien Maurice. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class PopupSearchView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsListTableViewCell
            populateCell(cell, index: (indexPath as NSIndexPath).row)
        return cell;

    }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

                return 115
        }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let PostVC : NewsDetailViewController = storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
        PostVC.news = self.news[(indexPath as NSIndexPath).row]
        PostVC.indexRow = (indexPath as NSIndexPath).row;
        self.navigationController?.pushViewController(PostVC, animated: true)

    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imgnoRes: UIImageView!
    @IBOutlet weak var labnoRes: UILabel!

    var searchActive : Bool = false
    var filtered:[String] = []

    var news = [News]()

    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var viewPopup: UIView!
    
    @IBOutlet weak var presentImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableView By Id
        let tablecellNib = UINib(nibName: "NewsListTableViewCell", bundle: nil)
        tableView.register(tablecellNib, forCellReuseIdentifier: "NewsCell")

        /* Setup delegates */
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.endEditing(true)
        searchNews(searchTxt: searchBar.text!)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
        
    }
    
    func searchNews(searchTxt: String) {
        
        self.view.makeToastActivity(.center)

        let urlnews = ApiManager().SERVER_URL + ApiManager().GET_NEWS_SEARCH
        
        
        guard let url = URL(string: urlnews) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY, "search": searchTxt, "count":100])
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)
                    
                    if let newsData = swiftyJsonVar["posts"].array {
                        
                        for news in newsData {
                            let nid = news["nid"].int
                            var news_title = news["news_title"].string
                            
                            news_title = news_title?.replacingOccurrences(of: "\\\'", with: "'")
                            
                            var news_image = ApiManager().SERVER_URL + ApiManager().IMG_FOLDER + news["news_image"].string!

                            let dateFormatterGet = DateFormatter()
                            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            
                            let dateFormatterPrint = DateFormatter()
                            dateFormatterPrint.dateFormat = "MMMM dd,yyyy"
                            
                            var news_date = ""
                            if let date = dateFormatterGet.date(from: news["news_date"].string!) {
                                news_date = dateFormatterPrint.string(from: date)
                            }
                            
                            var news_description = news["news_description"].string
                            news_description = news_description?.withoutHtmlHexaTags

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
                        
                        self.imgnoRes.isHidden = true
                        self.labnoRes.isHidden = true

                        self.view.hideToastActivity()
                        self.tableView.reloadData()
                        
                        self.view.setNeedsLayout()

                    } else {
                        self.view.hideToastActivity()
                        self.imgnoRes.isHidden = false
                        self.labnoRes.isHidden = false

                    }

                case .failure(let error):

                    print("Error \(error.localizedDescription)")
                }
                
        
        }
    }
    
    func populateCell(_ cell: NewsListTableViewCell, index: Int){
        
        cell.postTitle.text = self.news[index].news_title
        cell.postDate.text = self.news[index].news_date!
        
        //remove html tags
        let string = self.news[index].news_description
        //let str = string!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        var str = string!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        str = str.withoutHtmlHexaTags

        cell.postDescription.text = str
        cell.postComments.text = self.news[index].comments_count!

        var image = self.news[index].news_image
        image = image!.replacingOccurrences(of: " ",with: "%20")

        cell.postImage.image = UIImage(named: "logo")  //set placeholder image first.
        
        if let imageURL = URL(string: image!), let placeholder = UIImage(named: "logo") {
            cell.postImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        if ((self.news[index].content_type == "youtube") || (self.news[index].content_type == "Upload") || (self.news[index].content_type == "Url")) {
            cell.imagePlay.isHidden = false
        } else {
            cell.imagePlay.isHidden = true
        }

        //Hero image
//        cell.postImage.hero.id = self.news[index].news_image
    }
    
}
