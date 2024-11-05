//
//  BulletWidgetsVC.swift
//  BULLET
//
//  Created by Khadim Hussain on 08/08/2020.
//  Copyright © 2020 Ziro Ride LLC. All rights reserved.
//

import UIKit
import UIKit
import NotificationCenter
import SDWebImage

class BulletWidgetsVC: UIViewController, NCWidgetProviding {
     
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var tbNews: UITableView!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    
    var newsId = ""
    private var articles: [ArticlesData] = []

    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        self.activityLoader.startAnimating()
        self.tbNews.isHidden = true
        self.activityLoader.isHidden = false
        self.tbNews.reloadData()
        self.btnLogin.layer.borderWidth = 2.5
        self.btnLogin.layer.borderColor = Constant.appColor.purple.cgColor
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        
        self.performWSToGetNews()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.updateColors()
    }
    
    func updateColors() {
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                
                self.visualEffect.effect = UIBlurEffect(style: .regular)
                self.btnMore.setTitleColor(.black, for: .normal)
                
            } else {
                
                self.visualEffect.effect = UIBlurEffect(style: .dark)
                self.btnMore.setTitleColor(.white, for: .normal)
            }
        } else {
            // Fallback on earlier versions
            self.visualEffect.effect = UIBlurEffect(style: .dark)
        }
        
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.tbNews.reloadData()
        self.updateColors()
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
     
        let url: URL? = URL(string: "open://\("login")")!
        if let appurl = url {
            self.extensionContext!.open(appurl, completionHandler: nil)
        }
    }
    
    @IBAction func didTapOpenApp(_ sender: UIButton) {
     
        let url: URL? = URL(string: "open://\("homevc")")!
        if let appurl = url {
            self.extensionContext!.open(appurl, completionHandler: nil)
        }
    }
//    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
//        // Perform any setup necessary in order to update the view.
//
//        // If an error is encountered, use NCUpdateResult.Failed
//        // If there's no update required, use NCUpdateResult.NoData
//        // If there's an update, use NCUpdateResult.NewData
//
//        completionHandler(NCUpdateResult.newData)
//    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {

            self.preferredContentSize = maxSize
        }
        else if activeDisplayMode == .expanded {

            self.preferredContentSize = CGSize(width: maxSize.width, height: 652)
           // self.preferredContentSize = CGSize(width: maxSize.width, height: (100*4)+52)
            
//            if articles.count > 4 {
//
//                let count = articles.count
//                self.preferredContentSize = CGSize(width: maxSize.width, height: (100*5)+52)
//            }
//            else {
//
//                self.preferredContentSize = CGSize(width: maxSize.width, height: (100*4)+52)
//            }
        }
    }
}

//MARK: - UITablview Delegates and DataSource
extension BulletWidgetsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCC") as! newsCC
        
        let news = self.articles[indexPath.row]
        
      //  cell.lblSource.textColor = UIColor(displayP3Red: 144.0, green: 144.0, blue: 144.0, alpha: 1)
        cell.lblNewsNumber.text = "\(indexPath.row + 1)."
        cell.lblNews.text = news.title
//        cell.lblNews.setLineSpacing(lineSpacing: 2)
        cell.lblSource.text = news.source_name ?? ""
        if let category = news.category, category.isEmpty || category == "" {
            
            cell.lblTime.text = self.generateDatTimeOfNews(news.time ?? "")
        }
        else {
            
            cell.lblTime.text = "\(news.category ?? "") - \(self.generateDatTimeOfNews(news.time ?? "").lowercased())"
        }
        cell.lblSource .sizeToFit()
        
     //   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
     
//            cell.imgNewsIcon.sd_setImage(with: URL(string: news.image ?? ""))
//            cell.imgSource.sd_setImage(with: URL(string: news.source_image ?? ""))
        
        
        // Create URL
//           let url = URL(string: news.image ?? "")!
//           DispatchQueue.global().async {
//               // Fetch Image Data
//               if let data = try? Data(contentsOf: url) {
//                   DispatchQueue.main.async {
//                       // Create Image and Update Image View
//                    cell.imgNewsIcon.image = UIImage(data: data)
//                   }
//               }
//           }
//
//        let imgSourceurl = URL(string: news.source_image ?? "")!
//        DispatchQueue.global().async {
//            // Fetch Image Data
//            if let data = try? Data(contentsOf: imgSourceurl) {
//                DispatchQueue.main.async {
//                    // Create Image and Update Image View
//                 cell.imgSource.image = UIImage(data: data)
//                }
//            }
//        }
        
//        cell.imgNewsIcon.image = UIImage(named: "WImage")
//        cell.imgSource.image = UIImage(named: "WLogo")
        
            
//            cell.imgNewsIcon.sd_setImage(with: URL(string: news.image ?? ""), placeholderImage: UIImage(named: ""), options: .lowPriority)
//            cell.imgSource.sd_setImage(with: URL(string: news.source_image ?? ""), placeholderImage: UIImage(named: ""), options: .lowPriority)
        
        cell.imgSource.sd_setImage(with: URL(string: news.source_image ?? ""), placeholderImage: UIImage(named: "WLogo"), completed: { (image, error, cacheType, imageURL) in
            
            var image = image
            if image == nil {
                
            }
            else {
                
                //If image height is greater than image view height then resize image by height
                if ((image?.size.height)! > cell.imgSource.frame.height) { //Resize the image
                    image = NetworkManager.resizeImageByHeight(image!, height: cell.imgSource.frame.height)
                }
                cell.imgSource.image = image
            }
        })
        
        cell.imgNewsIcon.sd_setImage(with: URL(string: news.image ?? ""), placeholderImage: UIImage(named: "WImage"), completed: { (image, error, cacheType, imageURL) in
            
            var image = image
            if image == nil {
                
            }
            else {
                
                //If image height is greater than image view height then resize image by height
                if ((image?.size.height)! > cell.imgNewsIcon.frame.height) { //Resize the image
                    image = NetworkManager.resizeImageByHeight(image!, height: cell.imgNewsIcon.frame.height)
                }
                cell.imgNewsIcon.image = image
            }
        })
        
        
        if #available(iOS 13.0, *) {
            cell.lblNewsNumber.textColor = .link
        } else {
            
            cell.lblNewsNumber.textColor = .blue
        }
        
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                
                cell.lblSource.textColor =  "#282828".hexStringToUIColor()
                cell.lblTime.textColor =  "#282828".hexStringToUIColor()
                
            } else {
                
                cell.lblSource.textColor = .white
                cell.lblTime.textColor = .white
            }
        } else {
            // Fallback on earlier versions
            cell.lblSource.textColor = .white
            cell.lblTime.textColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let news = self.articles[indexPath.row]
        if let url = URL(string: "open://\(news.id ?? "")")
        {
            self.extensionContext?.open(url, completionHandler: nil)
        }
    }
}

extension BulletWidgetsVC {
    
    func performWSToGetNews() {

        var url = ""
        var token = ""
        if let userDefaults = UserDefaults(suiteName: "group.app.newsreels") {

            token = userDefaults.string(forKey: "accessToken") ?? ""
//            if token.isEmpty {
//
//                self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
//                self.activityLoader.isHidden = true
//                self.activityLoader.stopAnimating()
//                self.btnLogin.isHidden = false
//                self.tbNews.isHidden = true
//                return
//            }
            
            if token.isEmpty {
                
                url = "news/public/articles"
            }
            else {
                
                url = "news/articles/widget"
            }
        }
        NetworkManager.URLResponse(url, method: .get, parameters: nil, headers: token, withSuccess: { (response) in

            do{
                let FULLResponse = try
                    JSONDecoder().decode(newsArticlesDC.self, from: response)

                if let arr = FULLResponse.articles {
                    
                    self.articles.removeAll()
                    if arr.count > 5  {
                        
                        let array = arr.prefix(5)
                        self.articles += array
                    }
                    else {
                        
                        self.articles += arr
                    }
                    self.activityLoader.isHidden = true
                    self.activityLoader.stopAnimating()
                    self.tbNews.isHidden = false
                    self.tbNews.reloadData()
                }

            } catch let jsonerror {
                print("error parsing json objects",jsonerror)
            }
        }) { (error) in

            self.activityLoader.isHidden = true
            self.activityLoader.stopAnimating()
            self.tbNews.isHidden = false
          //  self.tbNews.reloadSections([0], with: UITableView.RowAnimation.fade)
            print("error parsing json objects",error)
        }
    }
}

extension UILabel {
    
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString:NSMutableAttributedString
        
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}

extension String {
    
    func hexStringToUIColor() -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension BulletWidgetsVC {
    
    func generateDatTimeOfNews(_ pubDate: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        //Check pulbished date is nil with format
        var pDate = formatter.date(from: pubDate) //"2021-07-31T16:45:05Z"
        if pDate == nil {
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSX" //was "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            pDate = formatter.date(from: pubDate)
        }

        let curStr = formatter.string(from: Date())
        
        if let pDate = pDate, let currentDate = formatter.date(from: curStr) {
                        
            let calendar = Calendar.current
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .month, .year])
            let differenceOfDate = calendar.dateComponents(components, from: pDate, to: currentDate)
            //print("date", differenceOfDate)
            var day = differenceOfDate.day!
            let hours = differenceOfDate.hour!
            let min = differenceOfDate.minute!
            
            if day > 0 {
                
                let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: pDate), to: currentDate)
                //print("date", differenceOfDate)
                day = daysDiff.day!
            }
            
            if abs(day) == 0 {
                
                if abs(hours) < 2 {
                    
                    if abs(hours) < 1 {
                        
                        if min < 1 {
                            return "\(NSLocalizedString("JUST NOW", comment: ""))"
                        } else {
                            return "\(min) \(NSLocalizedString("MINS AGO", comment: ""))"
                        }
                    }
                    else {
                        
                        return NSLocalizedString("AN HOUR AGO", comment: "")
                    }
                }
                else {
                    return "\(hours) \(NSLocalizedString("HOURS AGO", comment: ""))"
                }
            }
            else if abs(day) > 7 {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                return "\(dateFormatter.string(from: pDate))".uppercased()
            }
            else if abs(day) == 7 {
                
                return NSLocalizedString("1 WEEK AGO", comment: "")
            }
            else if abs(day) < 2 {

                return NSLocalizedString("YESTERDAY", comment: "")
            }
            else if day > 1 {
                
                return "\(day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
            else {
                
                return "\(-day) \(NSLocalizedString("DAYS AGO", comment: ""))"
            }
        }
        return ""
    }
}
