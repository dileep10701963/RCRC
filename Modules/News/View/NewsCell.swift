//
//  NewsCell.swift
//  RCRC
//
//  Created by anand madhav on 27/09/20.
//

import UIKit
import AlamofireImage

class NewsCell: UITableViewCell {
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsDateLabel: UILabel!
    @IBOutlet weak var newsDescriptionLabel: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var incidentImage: UIImageView!
    @IBOutlet weak var readMoreButton: UIButton!

    var onReuse: () -> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
    }

    func displayNews(newsModel: NewsModel) {
        newsTitleLabel.text = newsModel.title
        newsDescriptionLabel.text = newsModel.newsModelDescription
        newsDateLabel.text = newsModel.publishDate?.toDate(timeZone: .AST)?.toString(withFormat: "EEEE MMMM dd, yyyy", timeZone: .AST)
    }

    override func layoutSubviews() {
        newsTitleLabel.setAlignment()
        newsDateLabel.setAlignment()
        newsDescriptionLabel.setAlignment()
    }
}
