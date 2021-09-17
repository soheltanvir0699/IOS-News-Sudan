//
//  NewsListViewController.swift
//  IOS News App
//
//  Created by GajoDev on 23/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

/*
Fix small bug on pushtorefresh on the front page
Fix share HTML when sharing article
 
*/

import UIKit
import Alamofire
import AlamofireImage
import Toast_Swift
import SwiftyJSON
import GoogleMobileAds

class NewsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,GADBannerViewDelegate, GADUnifiedNativeAdLoaderDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var news = [Any]()
    var status: String = ""
    var count: Int = 0
    var count_sum: Int = 0
    var count_total: Int = 0
    var pages: Int = 1
    var pagenumber: Int = 1

    //If we are comming from category page
    var category_id: String = "0"
    var category_name: String = ""
    
    
    //Native Ads
    /// The ad unit ID from the AdMob UI.
    let nativAdUnitID = Constant().NATIVE_AD_ON_NEWS_FEED_CODE
    /// The number of native ads to load (must be less than 5).
    let numAdsToLoad = 1
    /// The native ads.
    var nativeAds = [GADUnifiedNativeAd]()
    /// The ad loader that loads the native ads.
    var adLoader: GADAdLoader!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tablecellNib = UINib(nibName: "HeaderNewsListeTableViewCell", bundle: nil)
        tableView.register(tablecellNib, forCellReuseIdentifier: "HeaderCell")

        let tableNewscellNib = UINib(nibName: "NewsListTableViewCell", bundle: nil)
        tableView.register(tableNewscellNib, forCellReuseIdentifier: "NewsCell")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshControlValueChanged), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        setViewTitle()
        getlatestNews(pagenb: pagenumber)
                
        //To update when the app go to background and reopen
        NotificationCenter.default.addObserver(self,
        selector: #selector(appWillEnterForeground),
        name: UIApplication.willEnterForegroundNotification,
        object: nil)
        
        addTopRightButtons()
        setGradientNavigationBar()
        
        if (Constant().NATIVE_AD_ON_NEWS_FEED == true) {
            loadnativads()
        }
    }
    
    func loadnativads() {
        
        tableView.register(UINib(nibName: "UnifiedNativeAdCell", bundle: nil),
            forCellReuseIdentifier: "UnifiedNativeAdCell")

        //Chargement Native
        let options = GADMultipleAdsAdLoaderOptions()
        options.numberOfAds = numAdsToLoad
        // Prepare the ad loader and start loading ads.
        adLoader = GADAdLoader(adUnitID: nativAdUnitID,
                               rootViewController: self,
                               adTypes: [.unifiedNative],
                               options: [options])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func addTopRightButtons() {
        
        let searchImage  = UIImage(named: "topbar-search")!
        let loginImage  = UIImage(named: "topbar-user")!

        let searchButton   = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(searchAction))
        
        let loginButton = UIBarButtonItem(image: loginImage,  style: .plain, target: self, action: #selector(loginAction))

        if (Constant().DISABLE_COMMENT == false) {
            navigationItem.rightBarButtonItems = [loginButton,searchButton]
        } else {
            navigationItem.rightBarButtonItems = [searchButton]
        }
    }

    @objc func searchAction() {
        
        let PostVC : PopupSearchView = storyboard!.instantiateViewController(withIdentifier: "PopupSearchView") as! PopupSearchView
        self.navigationController?.pushViewController(PostVC, animated: true)

    }

    @objc func loginAction() {

        let PostVC : ProfileViewController = storyboard!.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(PostVC, animated: true)

    }

    @objc func appWillEnterForeground() {
        pagenumber = 1
        news.removeAll()
        getlatestNews(pagenb: pagenumber)
        self.tableView.reloadData()
    }
    
    @IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
            pagenumber = 1
            news.removeAll()
            count_sum=0
            getlatestNews(pagenb: pagenumber)
            self.tableView.reloadData()
            sender.endRefreshing()
        
    }
    /*
    override func viewWillAppear(_ animated: Bool) {
        pagenumber = 1
        news.removeAll()
        getlatestNews(pagenb: pagenumber)
        self.tableView.reloadData()
    }*/
    
    func setGradientNavigationBar() {

        //Setup Navigation Bar text color and background
        self.navigationController?.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
    }
    
    func setViewTitle() {
        
        if (category_id != "0") {
            self.navigationItem.title = category_name
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //FOR NATIVE BANNERS
                if let nativeAd = news[indexPath.row] as? GADUnifiedNativeAd {
                    nativeAd.rootViewController = self

                    let nativeAdCell = tableView.dequeueReusableCell(
                        withIdentifier: "UnifiedNativeAdCell", for: indexPath)

                    let adView : GADUnifiedNativeAdView = nativeAdCell.contentView.subviews
                      .first as! GADUnifiedNativeAdView

                    // Associate the ad view with the ad object.
                    // This is required to make the ad clickable.
                    adView.nativeAd = nativeAd

                    (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
                    (adView.iconView as! UIImageView).layer.cornerRadius = 4

                    // Populate the ad view with the ad assets.
                    (adView.headlineView as! UILabel).text = nativeAd.headline
        //            (adView.priceView as! UILabel).text = nativeAd.price
                 

                      (adView.starRatingView as! UILabel).text = nil
                      (adView.starRatingView as! UILabel).isHidden = true
                        (adView.bodyView as! UILabel).isHidden = false
                    
                    //                    (adView.bodyView as! VerticalAlignLabel).text = nativeAd.body

                    (adView.callToActionView as! UIButton).isUserInteractionEnabled = false
                    (adView.callToActionView as! UIButton).layer.cornerRadius = 5

                    (adView.callToActionView as! UIButton).setTitle(
                        nativeAd.callToAction?.uppercased(), for: UIControl.State.normal)

                    return nativeAdCell
                    
                } else {
                    
        if (indexPath as NSIndexPath).row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderNewsListTableViewCell
            populateHeaderCell(cell, index: (indexPath as NSIndexPath).row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsListTableViewCell
            populateCell(cell, index: (indexPath as NSIndexPath).row)
            return cell

        }
                }

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (indexPath as NSIndexPath).row == 0 {
            return 282
        } else {
            return 115
        }
    }

    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mynews = news[indexPath.row] as? News {
            let PostVC : NewsDetailViewController = storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
            PostVC.news = mynews
            PostVC.indexRow = (indexPath as NSIndexPath).row
            
            self.navigationController?.pushViewController(PostVC, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = news.count - 1
        if indexPath.row == lastElement {
            if (count_sum < count_total) {
                pagenumber += 1
                getlatestNews(pagenb: pagenumber)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getlatestNews(pagenb: Int) {
        
        self.view.makeToastActivity(.center)

        //If we don't have any category list, load the latest posts
        var urlnews = ""
        if (category_id == "0") {
            urlnews = ApiManager().SERVER_URL + ApiManager().GET_NEWS_LIST
        } else {
            urlnews = ApiManager().SERVER_URL + ApiManager().GET_CATEGORY_POSTS
        }
        
        
        guard let url = URL(string: urlnews) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY, "page": pagenb, "id":category_id])
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
                        let PostVC : NewsDetailViewController = self.storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
                        for (i,data) in self.news.enumerated() {
                            guard let data2 = data as? News else {
                                return
                            }
                            print(data2.news_title)
                            if data2.news_title == UserDefaults.standard.value(forKey: "title") as? String {
                                PostVC.news = data2
                                PostVC.indexRow = i

                                self.navigationController?.pushViewController(PostVC, animated: true)
                                UserDefaults.standard.set("", forKey: "title")
                            }
                        }
                        
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

                case .failure(let error):

                    print("Error \(error.localizedDescription)")
                }
                
        
        }
    }
    
    func populateCell(_ cell: NewsListTableViewCell, index: Int){
        
        if let mynews = self.news[index] as? News {
        
        cell.postTitle.text = mynews.news_title
        cell.postDate.text = mynews.news_date!
        
        //remove html tags
        let string = mynews.news_description

        var str = string!.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        str = str.withoutHtmlHexaTags

        cell.postDescription.text = str
        cell.postComments.text = mynews.comments_count!

        var image = mynews.news_image
        image = image!.replacingOccurrences(of: " ",with: "%20")

        cell.postImage.image = UIImage(named: "logo")  //set placeholder image first.
        
        if let imageURL = URL(string: image!), let placeholder = UIImage(named: "logo") {
            cell.postImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        if ((mynews.content_type == "youtube") || (mynews.content_type == "Upload") || (mynews.content_type == "Url")) {
            cell.imagePlay.isHidden = false
        } else {
            cell.imagePlay.isHidden = true
        }

        //Hero image
//        cell.postImage.hero.id = mynews.news_image
            
        }
    }
    
    
    func populateHeaderCell(_ cell: HeaderNewsListTableViewCell, index: Int){
        
        if let mynews = self.news[index] as? News {

        cell.postTitle.text = mynews.news_title
        
        cell.postDate.text = mynews.news_date!
        
        cell.postComments.text = mynews.comments_count!

        var image = mynews.news_image
        image = image!.replacingOccurrences(of: " ",with: "%20")

        cell.postImage2.image = UIImage(named: "logo")  //set placeholder image first.
        
        if let imageURL = URL(string: image!), let placeholder = UIImage(named: "logo") {
            cell.postImage2.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        if ((mynews.content_type == "youtube") || (mynews.content_type == "Upload") || (mynews.content_type == "Url")) {
            cell.imagePlay.isHidden = false
        } else {
            cell.imagePlay.isHidden = true
        }

        }
        
    }
 
    func addNativeAds() {
      if nativeAds.count <= 0 {
        return
      }

    let adInterval = (news.count / nativeAds.count) + 1
              var index = 4
              for nativeAd in nativeAds {
                if index < news.count {
                  news.insert(nativeAd, at: index)
                  index += adInterval
                } else {
                  break
                }
              }

        self.tableView.reloadData()

    }

    // MARK: - GADAdLoaderDelegate

    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
      print("\(adLoader) failed with error: \(error.localizedDescription)")
    }

    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADUnifiedNativeAd) {
        print("Received native ad: \(nativeAd)")
        
            nativeAds.append(nativeAd)
    }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
      guard let rating = starRating?.doubleValue else {
        return nil
      }
      if rating >= 5 {
        return UIImage(named: "stars_5")
      } else if rating >= 4.5 {
        return UIImage(named: "stars_4_5")
      } else if rating >= 4 {
        return UIImage(named: "stars_4")
      } else if rating >= 3.5 {
        return UIImage(named: "stars_3_5")
      } else {
        return nil
      }
    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
      addNativeAds()
    }

    
}

