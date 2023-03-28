//
//  CricketCollectionViewCell.swift
//  NewsReels2.0
//
//  Created by Harlene James Cruz on 6/2/22.
//

import UIKit

class CricketCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var resultText: UILabel!
    @IBOutlet var matchNumberText: UILabel!
    @IBOutlet var locationText: UILabel!
    @IBOutlet var firstTeamImageView: UIImageView!
    @IBOutlet var secondTeamImageView: UIImageView!
    @IBOutlet var firstTeamText: UILabel!
    @IBOutlet var secondTeamText: UILabel!
    @IBOutlet var someText: UILabel!
    @IBOutlet var firstTeamScore: UILabel!
    @IBOutlet var secondTeamScore: UILabel!
    @IBOutlet var matchWinnerText: UILabel!
    @IBOutlet var firstFooter: UILabel!
    @IBOutlet var secondFooter: UILabel!
    @IBOutlet var thirdFooter: UILabel!
    @IBOutlet var containerView: UIView!
    @IBOutlet var lineView: UIView!
    
    static let identifier = "CricketCollectionViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "CricketCollectionViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with model: Cricket) {
//        self.matchText.text = model.matchText
//        self.challengeText.text = model.challengeText
//        self.firstMatchText.text = model.firstMatchText
//        self.secondMatchText.text = model.secondMatchText
        self.resultText.text = model.resultText
        self.matchNumberText.text = model.matchNumberText
        self.locationText.text = model.locationText
        self.firstTeamImageView.image = UIImage(named: model.firstTeamImageView)
        self.secondTeamImageView.image = UIImage(named: model.secondTeamImageView)
        self.firstTeamText.text = model.firstTeamText
        self.secondTeamText.text = model.secondTeamText
        self.someText.text = model.someText
        self.firstTeamScore.text = model.firstTeamScore
        self.secondTeamScore.text = model.secondTeamScore
        self.matchWinnerText.text = model.matchWinnerText
        self.firstFooter.text = model.firstFooter
        self.secondFooter.text = model.secondFooter
        self.thirdFooter.text = model.thirdFooter
//        self.lineView.layer.borderWidth = 100
        self.containerView.cardView()
    }
}
