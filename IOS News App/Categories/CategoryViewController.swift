
import UIKit
import AVFoundation
import Alamofire
import Toast_Swift
import SwiftyJSON
import UserNotifications

class CategoryViewController: UICollectionViewController {
    @IBOutlet var catColl: UICollectionView!
    var refreshControl = UIRefreshControl()
    var category = [Category]()
    var status: String = ""
    var count: Int = 0

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
    @objc func refreshControlValueChanged() {
        category.removeAll()
        
        getCategories()
            self.catColl.reloadData()
        refreshControl.endRefreshing()
        
        
    }
    func setupCollectionView(){
          catColl.delegate = self
          catColl.dataSource = self
          catColl.alwaysBounceVertical = true
          self.refreshControl = UIRefreshControl()
          self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing content...")
          self.refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged), for: .valueChanged)
          catColl!.addSubview(refreshControl)
    }
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCollectionView()
//    let center = UNUserNotificationCenter.current()
//
//        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//            if granted {
//                print("Yay!")
//            } else {
//                print("D'oh")
//            }
//        }
//
//        let content = UNMutableNotificationContent()
//        content.title = "Late wake up call"
//        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
//        content.categoryIdentifier = "alarm"
//        content.userInfo = ["customData": "fizzbuzz"]
//        content.sound = UNNotificationSound.default
//
//        var dateComponents = DateComponents()
//        dateComponents.hour = 11
//        dateComponents.minute = 05
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        center.add(request)
    
    self.navigationItem.title = "Categories"

    getCategories()

    if let layout = collectionView?.collectionViewLayout as? PinterestLayout {
      layout.delegate = self
    }
//    collectionView?.backgroundColor = .clear
    collectionView?.contentInset = UIEdgeInsets(top: 23, left: 16, bottom: 10, right: 16)
    
    setGradientNavigationBar()
  }
    
    func setGradientNavigationBar() {

        self.navigationController?.navigationBar.setGradientBackground(colors: [Constant().LIGHTCOLOR, Constant().MAINCOLOR], startPoint: .topLeft, endPoint: .bottomRight)
    }
}

extension CategoryViewController: UICollectionViewDelegateFlowLayout {
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return category.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath as IndexPath) as! CategoryCollectionViewCell
    cell.categoryTitle.text = category[indexPath.item].category_name
    
/*
    cell.categoryImage.downloadImageFrom(link: ApiManager().SERVER_URL + ApiManager().CATEGORY_IMG_FOLDER + image!, contentMode: UIView.ContentMode.scaleToFill)  //set your image from link array.
*/
    let image = category[indexPath.item].category_image
    if let imageURL = URL(string: ApiManager().SERVER_URL + ApiManager().CATEGORY_IMG_FOLDER + image!), let placeholder = UIImage(named: "logo") {
        cell.categoryImage.af.setImage(withURL: imageURL, placeholderImage: placeholder) //set image automatically when download compelete.
    }

    return cell
  }
  
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let PostVC : NewsListViewController = storyboard!.instantiateViewController(withIdentifier: "NewsListViewController") as! NewsListViewController
        PostVC.category_id = category[(indexPath as NSIndexPath).row].cid!
        PostVC.category_name = category[(indexPath as NSIndexPath).row].category_name!
        self.navigationController?.pushViewController(PostVC, animated: true)
        
    }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
    return CGSize(width: itemSize, height: itemSize)
  }
}

extension CategoryViewController: PinterestLayoutDelegate {
  func collectionView(
    _ collectionView: UICollectionView,
    heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat {
    return 200
  }

   func getCategories() {
        
        self.view.makeToastActivity(.center)

        guard let url = URL(string: ApiManager().SERVER_URL + ApiManager().GET_CATEGORY_LIST) else {
            return
        }
        AF.request(url,
                          method: .get,
                          parameters: ["api_key": ApiManager().API_KEY])
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
                    
                    if let categoriesData = swiftyJsonVar["categories"].array {
                        
                        for category in categoriesData {
                            let cid = category["cid"].int
                            let category_name = category["category_name"].string
                            let category_image = category["category_image"].string
                            let post_count = category["post_count"].int
                            
                            let cat = Category(cid: "\(cid ?? 0)",
                                category_name: category_name,
                                category_image: category_image!,
                                post_count:"\(post_count ?? 0)"
                            )
                            self.category.append(cat)
                            
                        }
                    }
                    if self.category.count > 0 {
                        self.view.hideToastActivity()
                        self.collectionView!.reloadData()
                        
                    } else {
                        self.view.hideToastActivity()
                        let image: UIImage = UIImage(named: "ic_no_item")!
                        let imageView = UIImageView(image: image)
                        self.view.addSubview(imageView)
                        
                        let titleFont: UIFont = .boldSystemFont(ofSize: 16.0)
                        let messageFont: UIFont = .systemFont(ofSize: 15.0)
                        
                        imageView.frame = CGRect(x: 0, y: 0, width: 240, height: 200)
                        imageView.center.x = self.view.center.x
                        imageView.center.y = self.view.center.y
                        
                        let labeltitle = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
                        labeltitle.textAlignment = NSTextAlignment.center
                        labeltitle.text = StringManager().offline
                        //                    labeltitle.
                        labeltitle.numberOfLines = 0
                        self.view.addSubview(labeltitle)
                        labeltitle.center.x = self.view.center.x
                        labeltitle.center.y = imageView.center.y + 110 //We put the message under the image
                        labeltitle.font = titleFont
                        
                        
                        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
                        label.textAlignment = NSTextAlignment.center
                        label.text = StringManager().noconnexion
                        label.numberOfLines = 0
                        self.view.addSubview(label)
                        
                        label.center.x = self.view.center.x
                        label.center.y = labeltitle.center.y + 50 //We put the message under the image
                        label.font = messageFont
                    }
                case .failure(_):
                    print("Error")
                }
                                
        }
        
    }
    
}
