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

class NewsDetailViewControllerOld: UIViewController, WKNavigationDelegate {
    
    var bannerView: GADBannerView!

    var news : News = News()
    var indexRow : Int = Int()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: WKWebView!
    @IBOutlet weak var postDescriptionHeight: NSLayoutConstraint!

    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postCategory: UILabel!
    @IBOutlet weak var postCommentsNb: UILabel!
    @IBOutlet weak var postImage: UIImageView!

    @IBOutlet weak var imagePlay: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var commnetReadButton: UIButton!

    var inFav : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fillUpFields()
        checkIsFavorite()
        setupAdmobBanner()
        startIntertitial()

    }
    
    //MARK:- IBAction methods (Click Events)
    @IBAction func CommentsButton(_ sender: UIButton) {
        print("boutoncaclick")
        let PostVC : CommentsListViewController = storyboard!.instantiateViewController(withIdentifier: "CommentsListViewController") as! CommentsListViewController
        PostVC.news = news
        self.navigationController?.pushViewController(PostVC, animated: true)

    }

    //MARK:- IBAction methods (Click Events)
    @IBAction func FavoriteButton(_ sender: UIButton) {
        
        if (!self.inFav) {
            
            try! dbQueue.write { db in
                            
                try db.execute(
                    sql: "INSERT INTO favorite (nid, news_title, news_image, news_date, news_description, cat_id, category_name, content_type, comments_count, video_id, video_url ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [news.nid, news.news_title, news.news_image, news.news_date, news.news_description, news.cat_id, news.category_name, news.content_type, news.comments_count, news.video_id, news.video_url])
            }
            self.inFav = true
            favoriteButton.setImage(UIImage(named: "ic_favorite_white"), for: .normal)
            self.view.makeToast("Added to Favorite", duration: 1.0, position: .bottom )

        } else { //If already in favorite we delete if

            try! dbQueue.write { db in
                try db.execute(sql: "DELETE FROM favorite WHERE nid = ?", arguments: [news.nid]) }
            favoriteButton.setImage(UIImage(named: "ic_favorite_outline_white"), for: .normal)
            self.inFav = false
            self.view.makeToast("Remove from Favorite", duration: 1.0, position: .bottom )
        }
    }

    //MARK:- IBAction methods (Click Events)
    @IBAction func ShareButton(_ sender: UIButton) {
        
        let items = [news.news_description?.withoutHtmlTags]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
        
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

        //Hero Effect
        self.hero.isEnabled = true
        postImage.hero.id = news.news_image

        self.postTitle.text = news.news_title
        self.postCategory.text = news.category_name
        self.postDescription.navigationDelegate = self
        self.postDescription.loadHTML(fromString: news.news_description!)
        self.postCommentsNb.text = news.comments_count
        self.commnetReadButton.setTitle("Read " + news.comments_count! + " Comments", for: .normal)
        
        self.postDate.addTextWithImage(text: " " + news.news_date!, image: UIImage(named: "ic_time")!, imageBehindText: false, keepPreviousText: false)
        
        self.postCommentsNb.addTextWithImage(text: " " + news.comments_count!, image: UIImage(named: "ic_comment_grey")!, imageBehindText: false, keepPreviousText: false)
        
        self.postImage.downloadImageFrom(link: news.news_image!, contentMode: UIView.ContentMode.scaleToFill)  //set your image from link array.
        
        if ((news.content_type == "youtube") || (news.content_type == "Upload") || (news.content_type == "Url")) {
            self.imagePlay.isHidden = false
        } else {
            self.imagePlay.isHidden = true
        }
        
        self.postCommentsNb.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CommentsButton(_:)))
        self.postCommentsNb.addGestureRecognizer(gesture)
        
//        self.postDescription.scrollView.isScrollEnabled = false
        self.postDescription.navigationDelegate = self

    }
    
    /*
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        self.postDescription.isUserInteractionEnabled = false
        self.postDescription.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                self.postDescription.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
//                    print(height)
                    let tailleheight = height as! CGFloat
                    self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width, height:tailleheight + 400)
                    //self.postDescription.frame.size.height = tailleheight + 40
                    
                    self.postDescription.frame.size.height = tailleheight
//                    self.postDescription.removeConstraints(self.postDescription.constraints)
//                    self.postDescription.heightAnchor.constraint(equalToConstant: tailleheight).isActive = true
                    
                })
            }
            
        })
        
        self.view.hideToastActivity()
    }*/

    /*
     * Check is the news is in favorite or not
     */

    func checkIsFavorite() {
        
        //Check if news is in favory
        try! dbQueue.read { db in
            if (try Row.fetchOne(db, sql: "SELECT * FROM favorite WHERE nid = ?", arguments: [news.nid])) != nil {
                self.inFav = true
                //If it's in favorite, change the favorite button
                favoriteButton.setImage(UIImage(named: "ic_favorite_white"), for: .normal)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    func setupAdmobBanner() {
        if (Constant().ADBANNER != "") {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            bannerView.adUnitID = Constant().ADBANNER
            bannerView.rootViewController = self
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID ]
            bannerView.load(request)
            addBannerViewToView(bannerView)
        }
    }
    
    func startIntertitial() {
        if (Constant().ADINTERSTITIAL != "") {

            //To access to the interstitial
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            if (Constant().NUMBERARTICLETOOPEN == appDelegate.articleopened) {
                if appDelegate.interstitial.isReady {
                    appDelegate.interstitial.present(fromRootViewController: self)
                } else {
                    print("Ad not ready")
                }
            } else {
             appDelegate.articleopened += 1
            }
        }
    }
    
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self.bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.postDescriptionHeight.constant = webView.scrollView.contentSize.height
            self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width, height:webView.scrollView.contentSize.height + 400)
            self.view.hideToastActivity()

        }
    }

}

