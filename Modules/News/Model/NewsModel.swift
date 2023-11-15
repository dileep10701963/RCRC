//
//  NewsModel.swift
//  RCRC
//
//  Created by anand madhav on 24/09/20.
//

import Foundation
import UIKit

var newsImageCache = NSCache<NewsImageCache, UIImage>()

// MARK: - NewsModel
struct NewsModel: Codable {
    let categoryName: String?
    let bannerImageURL, tileImageURL: String?
    let title, newsModelDescription: String?
    let publishDate: String?
    let newsURL: String?

    enum CodingKeys: String, CodingKey {
        case categoryName, bannerImageURL, tileImageURL, title
        case newsModelDescription = "description"
        case publishDate, newsURL
    }
}

class NewsImageCache: Hashable {

    let id = UUID()
    let url: NSURL

    init(url: NSURL) {
        self.url = url
    }

    static func == (lhs: NewsImageCache, rhs: NewsImageCache) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
