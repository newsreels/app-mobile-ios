//
//  DiscoverViewController.swift
//  Bullet
//
//  Created by Jade Lapuz on 5/31/22.
//  Copyright © 2022 Ziro Ride LLC. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var table: UITableView!
    var trendingTopicsModels = [TrendingTopic]()
    var cryptoPricesModels = [CryptoPrice]()
    var cricketModels = [Cricket]()
    var channelModels = [Channel]()
    
    let searchController = UISearchController()
    
    var categoryTitle: [String] = ["News in Conversation", "Vanity Fair", "People"]
    
    var newsContent: [String] = ["Inside the royal family's struggle to reinvent itself after the Diana years.", "How two photos - and one catastropic TV interview - brought down Prince Andrew.", "What tore brothers William and Harry apart."]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // demo purposes
        trendingTopicsModels.append(TrendingTopic(text: "Watchlist", imageName: "eye_circle"))
        trendingTopicsModels.append(TrendingTopic(text: "Price Alerts", imageName: "checkbox"))
        trendingTopicsModels.append(TrendingTopic(text: "Discover", imageName: "compass"))
        trendingTopicsModels.append(TrendingTopic(text: "Converter", imageName: "arrows"))
        trendingTopicsModels.append(TrendingTopic(text: "Watchlist", imageName: "eye_circle"))
        trendingTopicsModels.append(TrendingTopic(text: "Price Alerts", imageName: "checkbox"))
        trendingTopicsModels.append(TrendingTopic(text: "Discover", imageName: "compass"))
        trendingTopicsModels.append(TrendingTopic(text: "Converter", imageName: "arrows"))
        
        // demo purposes
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        cryptoPricesModels.append(CryptoPrice(text: "Bitcoin", imageName: "bitcoin", arrowImageName: "arrow_up", percentage: "3.89%", value: "$30,310.90"))
        
        // demo purposes
        cricketModels.append(Cricket(resultText: "RESULT", matchNumberText: "•3rd Match", locationText: "•Pune", firstTeamImageView: "cricket" , secondTeamImageView: "cricket_gray", firstTeamText: "TBL", secondTeamText: "VEL", someText: "(20 ov, T:191)", firstTeamScore: "190/5", secondTeamScore: "174/9", matchWinnerText: "Trailbrazers won by 16 runs", firstFooter: "Schedule", secondFooter: "Table", thirdFooter: "Report"))
        cricketModels.append(Cricket(resultText: "RESULT", matchNumberText: "•3rd Match", locationText: "•Pune", firstTeamImageView: "cricket" , secondTeamImageView: "cricket_gray", firstTeamText: "TBL", secondTeamText: "VEL", someText: "(20 ov, T:191)", firstTeamScore: "190/5", secondTeamScore: "174/9", matchWinnerText: "Trailbrazers won by 16 runs", firstFooter: "Schedule", secondFooter: "Table", thirdFooter: "Report"))
        cricketModels.append(Cricket(resultText: "RESULT", matchNumberText: "•3rd Match", locationText: "•Pune", firstTeamImageView: "cricket" , secondTeamImageView: "cricket_gray", firstTeamText: "TBL", secondTeamText: "VEL", someText: "(20 ov, T:191)", firstTeamScore: "190/5", secondTeamScore: "174/9", matchWinnerText: "Trailbrazers won by 16 runs", firstFooter: "Schedule", secondFooter: "Table", thirdFooter: "Report"))
        cricketModels.append(Cricket(resultText: "RESULT", matchNumberText: "•3rd Match", locationText: "•Pune", firstTeamImageView: "cricket" , secondTeamImageView: "cricket_gray", firstTeamText: "TBL", secondTeamText: "VEL", someText: "(20 ov, T:191)", firstTeamScore: "190/5", secondTeamScore: "174/9", matchWinnerText: "Trailbrazers won by 16 runs", firstFooter: "Schedule", secondFooter: "Table", thirdFooter: "Report"))
        
        // demo purposes
        channelModels.append(Channel(imageName: "car_1", text: "Car and Driver", plusImageName: "plus_circle"))
        channelModels.append(Channel(imageName: "car_2", text: "Card Chronicle", plusImageName: "plus_circle"))
        channelModels.append(Channel(imageName: "car_3", text: "Cardiac Hill", plusImageName: "plus_circle"))
        channelModels.append(Channel(imageName: "car_4", text: "The Car Connection", plusImageName: "plus_circle"))
        channelModels.append(Channel(imageName: "car_5", text: "Cars.com", plusImageName: "plus_circle"))
        
        // for these cells, an enum will be created to cater different position of the cells coming from the api once available.
        table.register(TrendingTopicsTableViewCell.nib(), forCellReuseIdentifier: TrendingTopicsTableViewCell.identifier)
        table.register(CryptoPricesTableViewCell.nib(), forCellReuseIdentifier:   CryptoPricesTableViewCell.identifier)
        table.register(CricketTableViewCell.nib(), forCellReuseIdentifier: CricketTableViewCell.identifier)
        table.register(ChannelsTableViewCell.nib(), forCellReuseIdentifier: ChannelsTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        table.register(MenuTableViewCell.nib(), forCellReuseIdentifier: MenuTableViewCell.identifier)
        table.register(TrendingTableViewCell.nib(), forCellReuseIdentifier: TrendingTableViewCell.identifier)
        table.delegate = self
        table.dataSource = self
        
        title = "Search"
        navigationItem.searchController = searchController
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Channels, Topics, & Stories")
        } else {
            searchController.searchBar.placeholder = "Channels, Topics, & Stories"
        }
        searchController.searchBar.showsBookmarkButton = true
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 5:
            let view = UIView()
            view.backgroundColor = UIColor(hexString: "3F85CC")
            
            let titleLabel = UILabel()
            titleLabel.text = "Listen Now"
            titleLabel.textAlignment = .left
            titleLabel.textColor = .white
            titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
            view.addSubview(titleLabel)
            
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  30).isActive = true
            
            return view
        case 3, 7:
            return nil
        default:
            let view = UIView()
            let titleLabel = UILabel()
            
            titleLabel.text = "Top Coins"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
            
            let seeAllButton = UIButton(type: .system)
            seeAllButton.setTitle("See All", for: .normal)
            seeAllButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            //        button.addTarget(self, action: #selector(showDetail), for: .touchUpInside)
            
            view.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
            
            view.addSubview(seeAllButton)
            seeAllButton.translatesAutoresizingMaskIntoConstraints = false
            seeAllButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
            
            return view
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 5:
            return categoryTitle.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = table.dequeueReusableCell(withIdentifier: TrendingTopicsTableViewCell.identifier, for: indexPath) as! TrendingTopicsTableViewCell
            cell.configure(with: trendingTopicsModels)
               
            return cell
        case 1:
            let cell = table.dequeueReusableCell(withIdentifier: CryptoPricesTableViewCell.identifier, for: indexPath) as! CryptoPricesTableViewCell
            cell.configure(with: cryptoPricesModels)
            
            return cell
        case 2:
            let cell = table.dequeueReusableCell(withIdentifier: CricketTableViewCell.identifier, for: indexPath) as! CricketTableViewCell
            cell.configure(with: cricketModels)
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
            
            return cell
        case 4:
            let cell = table.dequeueReusableCell(withIdentifier: CryptoPricesTableViewCell.identifier, for: indexPath) as! CryptoPricesTableViewCell
            cell.configure(with: cryptoPricesModels)
            
            return cell
        case 5:
            let cell = cellForTrendingCell(tableView, cellForRowAt: indexPath)
            
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: TrendingTableViewCell.identifier, for: indexPath) as! TrendingTableViewCell
            cell.titleLabel.text = "Trending"
            cell.titleLabel.font = UIFont.boldSystemFont(ofSize: 30)
            
            return cell
        default:
            let cell = table.dequeueReusableCell(withIdentifier: ChannelsTableViewCell.identifier, for: indexPath) as! ChannelsTableViewCell
            cell.configure(with: channelModels)
            
            return cell
        }
    }
    
    // these cell height will be changed once the api is integrated, they we statically set for demo purposes
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0, 1, 4:
            return 150
        case 2:
            return 230
        case 3:
            return UITableView.automaticDimension
        case 5:
            return 140
        case 7:
            return 170
        default:
            return 300
        }
    }
    
    // these cell height will be changed once the api is integrated, they we statically set for demo purposes
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 3, 7:
            return 0
        case 5:
            return 80
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch section {
        case 5:
            let view = UIView()
            view.backgroundColor = UIColor(hexString: "3F85CC")
            
            let moreAudioButton = UIButton()
            moreAudioButton.setTitle("More Audio Stories", for: .normal)
            moreAudioButton.setTitleColor(.white, for: .normal)
            moreAudioButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            if #available(iOS 13.0, *) {
                moreAudioButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            moreAudioButton.semanticContentAttribute = .forceRightToLeft
            moreAudioButton.tintColor = .white
            moreAudioButton.sizeToFit()
            view.addSubview(moreAudioButton)
            
            moreAudioButton.translatesAutoresizingMaskIntoConstraints = false
            moreAudioButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -22).isActive = true
            moreAudioButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:  15).isActive = true
            
            return view
        default:
            return nil
        }
    }
    
    // these cell height will be changed once the api is integrated, they we statically set for demo purposes
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 5:
            return 60
        default:
            return 0
        }
    }
    
    // demo purposes, the data coming here should be from the api
    private func cellForTrendingCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MenuTableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
            //TOP only CORNER RADIUS
            cell.containerView.layer.cornerRadius = 12
            cell.containerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            cell.photoView.image = UIImage(named: "royal-family")
            
            cell.imageTitle.isHidden = false
            cell.imageTitle.tintColor = .black
            let attributedTitle = NSMutableAttributedString(string: categoryTitle[0],
                                                            attributes: [NSAttributedString.Key
                                                                .foregroundColor : UIColor.black,
                                                                         .font: UIFont(name: "HelveticaNeue-Bold", size: 12) as Any])
            //change half color of the LABEL
            let myRange = NSRange(location: 5, length: 15)
            attributedTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: myRange)
            cell.titlelabel.attributedText = attributedTitle
            
            cell.contentLabel.text = newsContent[0]
            cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            //Insert Image in a BUTTON
            if #available(iOS 13.0, *) {
                let headphoneImage = UIImage(systemName: "headphones")
                cell.playButton.setImage(headphoneImage, for: .normal)
                cell.playButton.tintColor = .black
                cell.playButton.sizeToFit()
                cell.playButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
            } else {
                // Fallback on earlier versions
            }
            let attributedButtonTitle = NSMutableAttributedString(string: "Play Now",
                                                                  attributes: [NSAttributedString.Key.foregroundColor : UIColor.black,
                                                                               .font: UIFont(name: "HelveticaNeue-Bold", size: 10)
                                                                               as Any])
            let attributedButtonTime = NSMutableAttributedString(string: " 30 mins",
                                                                 attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray,
                                                                              .font: UIFont(name: "HelveticaNeue", size: 10) as Any])
            //to COMBINE the two ATTRIBUTED STRING
            attributedButtonTitle.append(attributedButtonTime)
            cell.playButton.setAttributedTitle(attributedButtonTitle, for: .normal)
            
            cell.playActionBlock = {
                
            }
            
            cell.moreActionBlock = {
                self.performSegue(withIdentifier: "stories", sender: nil)
            }
            
            cell.moreButton.tintColor = .gray
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
            
            cell.photoView.image = UIImage(named: "prince-andrew")
            
            cell.imageTitle.isHidden = true
            cell.titlelabel.text = categoryTitle[1]
            cell.titlelabel.font = UIFont.systemFont(ofSize: 17)
            cell.titlelabel.textColor = UIColor.black
            
            cell.contentLabel.text = newsContent[1]
            cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            if #available(iOS 13.0, *) {
                let headphoneImage = UIImage(systemName: "headphones")
                cell.playButton.setImage(headphoneImage, for: .normal)
                cell.playButton.tintColor = .black
                cell.playButton.sizeToFit()
                cell.playButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
            } else {
                // Fallback on earlier versions
            }
            
            
            cell.playActionBlock = {
                
            }
            
            cell.moreActionBlock = {
                self.performSegue(withIdentifier: "stories", sender: nil)
            }
            
            cell.moreButton.tintColor = .gray
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
            
            cell.photoView.image = UIImage(named: "william-harry")
            
            cell.imageTitle.isHidden = true
            cell.titlelabel.text = categoryTitle[2]
            cell.titlelabel.font = UIFont.boldSystemFont(ofSize: 15)
            cell.titlelabel.textColor = UIColor.blue
            
            cell.contentLabel.text = newsContent[2]
            cell.contentLabel.font = UIFont.boldSystemFont(ofSize: 14)
            
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "headphones")
                cell.playButton.setImage(image, for: .normal)
                cell.playButton.tintColor = .black
                cell.playButton.sizeToFit()
                cell.playButton.imageView?.layer.transform = CATransform3DMakeScale(0.6, 0.6, 0.6)
            } else {
                // Fallback on earlier versions
            }
            
            
            cell.playActionBlock = {
                
            }
            
            cell.moreActionBlock = {
                self.performSegue(withIdentifier: "stories", sender: nil)
            }
            //BOTTOM only CORNER RADIUS
            cell.containerView.layer.cornerRadius = 12
            cell.containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.lineView.isHidden = true
            
            cell.moreButton.tintColor = .gray
            
            return cell
        }
    }
}

/// these models are for demo purposes, they will be updated from the response we get from api
struct TrendingTopic {
    let text: String
    let imageName: String
    
    init(text: String, imageName: String) {
        self.text = text
        self.imageName = imageName
    }
}


struct CryptoPrice {
    let text: String
    let imageName: String
    let arrowImageName: String
    let percentage: String
    let value: String
    
    init(text: String, imageName: String, arrowImageName: String, percentage: String, value: String) {
        self.text = text
        self.imageName = imageName
        self.arrowImageName = arrowImageName
        self.percentage = percentage
        self.value = value
    }
}

struct Cricket {
    let resultText: String
    let matchNumberText: String
    let locationText: String
    let firstTeamImageView: String
    let secondTeamImageView: String
    let firstTeamText: String
    let secondTeamText: String
    let someText: String
    let firstTeamScore: String
    let secondTeamScore: String
    let matchWinnerText: String
    let firstFooter: String
    let secondFooter: String
    let thirdFooter: String
    
    init(resultText: String, matchNumberText: String, locationText: String, firstTeamImageView: String, secondTeamImageView: String, firstTeamText: String, secondTeamText: String, someText: String, firstTeamScore: String, secondTeamScore: String, matchWinnerText: String, firstFooter: String, secondFooter: String, thirdFooter: String) {
        self.resultText = resultText
        self.matchNumberText = matchNumberText
        self.locationText = locationText
        self.firstTeamImageView = firstTeamImageView
        self.secondTeamImageView = secondTeamImageView
        self.firstTeamText = firstTeamText
        self.secondTeamText = secondTeamText
        self.someText = someText
        self.firstTeamScore = firstTeamScore
        self.secondTeamScore = secondTeamScore
        self.matchWinnerText = matchWinnerText
        self.firstFooter = firstFooter
        self.secondFooter = secondFooter
        self.thirdFooter = thirdFooter
    }
}

struct Channel {
    let imageName: String
    let text: String
    let plusImageName: String
    
    init(imageName: String, text: String, plusImageName: String) {
        self.imageName = imageName
        self.text = text
        self.plusImageName = plusImageName
    }
}
