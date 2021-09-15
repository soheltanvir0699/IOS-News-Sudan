//
//  NewsDetailViewController.swift
//  IOS News App
//
//  Created by GajoDev on 25/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation

import UIKit
import WebKit
import AVKit
import GRDB
import GoogleMobileAds
import Toast_Swift
import Alamofire
import SwiftyJSON

class NewsDetailViewController: UIViewController, WKNavigationDelegate, GADInterstitialDelegate, UITableViewDataSource, UITableViewDelegate {

    var bannerView: GADBannerView!
    @IBOutlet weak var mybannerView: GADBannerView!
    var interstitial: GADInterstitial!

    var news : News = News()
    var indexRow : Int = Int()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: WKWebView!
    @IBOutlet weak var postDescriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var mainContentViewHeight: NSLayoutConstraint!

    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postCommentsNb: UILabel!
    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var imagePlay: UIButton!
    @IBOutlet weak var commnetReadButton: UIButton!

    //Related articles
    @IBOutlet weak var relatedArticlesTableView: UITableView!
    @IBOutlet weak var suggestedLabel: UILabel!
    var relatednews = [News]()

    var isModal : Bool = false
    var inFav : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNewsData()
        checkIsFavorite()
        setupAdmobBanner()
        startIntertitial()
        addTopRightButtons()
        loadRelatedArticles()
        addTopLeftButtons()

        if (Constant().DISABLE_COMMENT == true) {
            postCommentsNb.isHidden = true
            commnetReadButton.isHidden = true
        }

    }

    func loadNewsData() {
        
        let urlrelated = ApiManager().SERVER_URL + ApiManager().GET_NEWS_DETAIL
        guard let url = URL(string: urlrelated) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["id":news.nid])
            .validate()
            .responseJSON { (response) -> Void in
                
                switch response.result {
                case let .success(value):
                    let swiftyJsonVar = JSON(value)

                    let currentNews = swiftyJsonVar["post"]
                    self.news = self.getTheNewsFromJson(newsdata: currentNews)
                    self.fillUpFields()
                                        
                    if let newsData = swiftyJsonVar["related"].array {
                        for news in newsData {

                            let newnews = self.getTheNewsFromJson(newsdata: news)
                            self.relatednews.append(newnews)
                            
                        }
                    }
                    
                    if self.relatednews.count > 0 {
                        self.relatedArticlesTableView.isHidden = false
                        self.suggestedLabel.isHidden = false
                        self.relatedArticlesTableView.reloadData()
                        
                    } else {
                        self.suggestedLabel.isHidden = true
                        self.relatedArticlesTableView.isHidden = true
                    }

                case .failure(let error):

                    print("Error \(error.localizedDescription)")
                }

        }
        
    }

    func getTheNewsFromJson(newsdata: JSON) -> News {
        
        let nid = newsdata["nid"].int
        var news_title = newsdata["news_title"].string
        
        news_title = news_title?.replacingOccurrences(of: "\\\'", with: "'")
        
        var news_image = ApiManager().SERVER_URL + ApiManager().IMG_FOLDER + newsdata["news_image"].string!

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMMM dd,yyyy"
        
        var news_date = ""
        if let date = dateFormatterGet.date(from: newsdata["news_date"].string!) {
            news_date = dateFormatterPrint.string(from: date)
        }
        
        var news_description = newsdata["news_description"].string
        news_description = news_description?.withoutHtmlHexaTags

        let cat_id = newsdata["cat_id"].int
        let category_name = newsdata["category_name"].string
        let content_type = newsdata["content_type"].string
        let comments_count = newsdata["comments_count"].int
        let video_id = newsdata["video_id"].string
        var video_url = newsdata["video_url"].string
        
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
        
        return news
    }
    
    func loadRelatedArticles() {
        
        let tableNewscellNib = UINib(nibName: "RelatedNewsTableViewCell", bundle: nil)
        relatedArticlesTableView.register(tableNewscellNib, forCellReuseIdentifier: "NewsRelatedCell")

        self.relatedArticlesTableView.delegate = self
        self.relatedArticlesTableView.dataSource = self
        self.relatedArticlesTableView.separatorStyle = .none

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("relatednews.count")
        print(relatednews.count)
        return relatednews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsRelatedCell", for: indexPath) as! RelatedNewsTableViewCell

        let mynews = self.relatednews[indexPath.row]
        cell.postTitle.text = mynews.news_title
        cell.postDate.text = mynews.news_date!
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
        return cell

    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let mynews = self.relatednews[indexPath.row] as? News {
            let PostVC : NewsDetailViewController = storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
            PostVC.news = mynews
            PostVC.indexRow = (indexPath as NSIndexPath).row
            PostVC.isModal = true
            
            let navBarOnModal: UINavigationController = UINavigationController(rootViewController: PostVC)
            navBarOnModal.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
            self.present(navBarOnModal, animated: true)
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 60
    }

    func addTopLeftButtons() {
        
        if (isModal == true) {
        let backImage =  UIImage(named: "topbar-chevron")!
        let backButton   = UIBarButtonItem(image: backImage,  style: .plain, target: self, action: #selector(closeAction))

            if (news.cat_id != "0") {
                let backButtonTxt   = UIBarButtonItem(title: news.category_name,  style: .plain, target: self, action: #selector(closeAction))
                navigationItem.leftBarButtonItems = [backButton,backButtonTxt]
            } else {
                navigationItem.leftBarButtonItems = [backButton]
            }
        }

    }
    
    @objc func closeAction(_ sender: UITapGestureRecognizer) {
    
        dismiss(animated: true, completion: nil)

    }

    
    func addTopRightButtons() {
        
        let favImage:UIImage
        if (!self.inFav) {
            favImage    = UIImage(named: "topbar-favorite")!
        } else {
            favImage    = UIImage(named: "topbar-favorite_plain")!
        }
        let shareImage  = UIImage(named: "topbar-share")!

        let favButton   = UIBarButtonItem(image: favImage,  style: .plain, target: self, action: #selector(saveFavorite))
        let shareButton = UIBarButtonItem(image: shareImage,  style: .plain, target: self, action: #selector(shareAction))

        navigationItem.rightBarButtonItems = [shareButton,favButton]
    }
    
    @objc func shareAction(_ sender: UITapGestureRecognizer) {
    
            let shareText = news.news_description?.withoutHtmlTags
            //For iPad and iPhone
            let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func saveFavorite(_ sender: UITapGestureRecognizer) {

        if (!self.inFav) {
            
            try! dbQueue.write { db in
                            
                try db.execute(
                    sql: "INSERT INTO favorite (nid, news_title, news_image, news_date, news_description, cat_id, category_name, content_type, comments_count, video_id, video_url ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [news.nid, news.news_title, news.news_image, news.news_date, news.news_description, news.cat_id, news.category_name, news.content_type, news.comments_count, news.video_id, news.video_url])
            }
            self.inFav = true
            self.view.makeToast("Added to Favorite", duration: 1.0, position: .top )

        } else { //If already in favorite we delete if

            try! dbQueue.write { db in
                try db.execute(sql: "DELETE FROM favorite WHERE nid = ?", arguments: [news.nid]) }
            self.inFav = false
            self.view.makeToast("Removed from Favorite", duration: 1.0, position: .top )
        }
        
        addTopRightButtons()
    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func CommentsButton(_ sender: UIButton) {
        print("boutoncaclick")
        let PostVC : CommentsListViewController = storyboard!.instantiateViewController(withIdentifier: "CommentsListViewController") as! CommentsListViewController
        PostVC.news = news
        self.navigationController?.pushViewController(PostVC, animated: true)

    }

    //MARK:- IBAction methods (Click Events)
    @IBAction  func playVideo(_ sender: UIButton) {
        
        // Do any additional setup after loading the view, typically from a nib.
        if (news.content_type == "youtube") {
            let PostVC : VideoPlayerViewController = storyboard!.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
            PostVC.video = news
            self.navigationController?.pushViewController(PostVC, animated: true)

        } else {
            
            let video = AVPlayer(url: URL(string: self.news.video_url!)!)
            let videoPlayer = AVPlayerViewController()
            videoPlayer.player = video
            
            present(videoPlayer, animated: true, completion:
                {
                    video.play()
            })
        }

    }
    
    /*
     * Populate the fields in the view
     */

    func fillUpFields() {
                
        self.view.makeToastActivity(.center)

        self.postTitle.text = news.news_title
//        self.postCategory.text = news.category_name
        self.postDescription.navigationDelegate = self
        self.postDescription.loadHTML(fromString: news.news_description!)
        self.postCommentsNb.text = news.comments_count
        self.commnetReadButton.setTitle("Read " + news.comments_count! + " Comments", for: .normal)
        
        self.postDate.addTextWithImage(text: " " + news.news_date!, image: UIImage(named: "ic_time")!, imageBehindText: false, keepPreviousText: false)
        
        self.postCommentsNb.addTextWithImage(text: " " + news.comments_count!, image: UIImage(named: "ic_comment_grey")!, imageBehindText: false, keepPreviousText: false)
        
        var image = news.news_image!
        image = image.replacingOccurrences(of: " ",with: "%20")

        if let imageURL = URL(string: image), let placeholder = UIImage(named: "logo") {
            self.postImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
        }

        if ((news.content_type == "youtube") || (news.content_type == "Upload") || (news.content_type == "Url")) {
            self.imagePlay.isHidden = false
        } else {
            self.imagePlay.isHidden = true
        }
        
        self.postCommentsNb.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CommentsButton(_:)))
        self.postCommentsNb.addGestureRecognizer(gesture)
        
//        self.postDescription.scrollView.isScrollEnabled = false
//        self.postDescription.navigationDelegate = self

    }
    
    /*
     * Check is the news is in favorite or not
     */

    func checkIsFavorite() {
        
        //Check if news is in favory
        try! dbQueue.read { db in
            if (try Row.fetchOne(db, sql: "SELECT * FROM favorite WHERE nid = ?", arguments: [news.nid])) != nil {
                self.inFav = true
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func setupAdmobBanner() {
        if (Constant().ADBANNER != "") {
            
            mybannerView.adUnitID = Constant().ADBANNER
            mybannerView.rootViewController = self
            let request = GADRequest()
            mybannerView.load(request)
            mybannerView.isHidden = false
            
        }
    }
    
    func startIntertitial() {
        if (Constant().ADINTERSTITIAL != "") {
            //To access to the interstitial
            
            //On a recu l'interstitiel et on louvre si il rempli les conditions
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            if (Constant().NUMBERARTICLETOOPEN == appDelegate.articleopened) {

                //Si ca remplli les condiotions alors on charge l'interstitiel
                interstitial = GADInterstitial(adUnitID: Constant().ADINTERSTITIAL)
                interstitial.delegate = self
                let request = GADRequest()
                interstitial.load(request)

            } else {
                appDelegate.articleopened += 1
            }

        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.postDescriptionHeight.constant = webView.scrollView.contentSize.height
            self.mainContentViewHeight.constant = self.postDescriptionHeight.constant + self.relatedArticlesTableView.frame.height + 200
/*            self.postDescriptionHeight.constant = webView.scrollView.contentSize.height
            self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width, height:webView.scrollView.contentSize.height + 400)*/
            self.view.hideToastActivity()
        }
    }

    
    // this handles target=_blank links by opening them in the same view
    func webView(webView: WKWebView!, createWebViewWithConfiguration configuration: WKWebViewConfiguration!, forNavigationAction navigationAction: WKNavigationAction!, windowFeatures: WKWindowFeatures!) -> WKWebView! {

        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        
        let url = navigationAction.request.url?.absoluteString
        let url_elements = url!.components(separatedBy:":")

        switch url_elements[0] {
            case "file":
                decisionHandler(.allow)
                return
            case "http":
                            let PostVC : InternalBrowserVC = storyboard!.instantiateViewController(withIdentifier: "InternalBrowserVC") as! InternalBrowserVC
                            PostVC.myurl = url!
                        self.navigationController?.pushViewController(PostVC, animated: true)
                            decisionHandler(.cancel)
                            return

            case "https":
                            let PostVC : InternalBrowserVC = storyboard!.instantiateViewController(withIdentifier: "InternalBrowserVC") as! InternalBrowserVC
                            PostVC.myurl = url!
                            self.navigationController?.pushViewController(PostVC, animated: true)
                            decisionHandler(.cancel)
                            return

        default:
            decisionHandler(.allow)
            return
        }

        decisionHandler(.allow)

        if let url = navigationAction.request.url {
                let PostVC : InternalBrowserVC = storyboard!.instantiateViewController(withIdentifier: "InternalBrowserVC") as! InternalBrowserVC
            PostVC.myurl = url.absoluteString
            self.navigationController?.pushViewController(PostVC, animated: true)
//                UIApplication.shared.open(url)
                decisionHandler(.allow)
                return
        }
        decisionHandler(.allow)
    }
    
        /// Tells the delegate an ad request succeeded.
        func interstitialDidReceiveAd(_ ad: GADInterstitial) {
          print("interstitialDidReceiveAd")
            
            //Si il est chargé et que toutes les condisioton sont remplies alors on affiche
            //On a recu l'interstitiel et on louvre si il rempli les conditions
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            if (appDelegate.articleopened == Constant().NUMBERARTICLETOOPEN) {

                if self.interstitial.isReady {

                    self.interstitial.present(fromRootViewController: self)
                    appDelegate.articleopened = 1
                } else {
                    print("Ad not ready")
                }
            }

        }

        /// Tells the delegate an ad request failed.
        func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
          print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }

        /// Tells the delegate that an interstitial will be presented.
        func interstitialWillPresentScreen(_ ad: GADInterstitial) {
          print("interstitialWillPresentScreen")
        }

        /// Tells the delegate the interstitial is to be animated off the screen.
        func interstitialWillDismissScreen(_ ad: GADInterstitial) {
          print("interstitialWillDismissScreen")
        }

        /// Tells the delegate the interstitial had been animated off the screen.
        func interstitialDidDismissScreen(_ ad: GADInterstitial) {
          print("interstitialDidDismissScreen")
        }

        /// Tells the delegate that a user click will open another app
        /// (such as the App Store), backgrounding the current app.
        func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
          print("interstitialWillLeaveApplication")
        }
        
}

