//
//  NewsViewModel.swift
//  RCRC
//
//  Created by anand madhav on 28/09/20.
//

import UIKit
import Alamofire
import AlamofireImage

class NewsViewModel: NSObject {

    var newsResult: Observable<[NewsModel]?, Error?> = Observable(nil, nil)
    var newsCount: Int {
        return self.newsResult.value?.count ?? 0
    }

    func fetchNews(index: Int) -> NewsModel? {
        guard let value = self.newsResult.value?[safe: index] else { return nil }
        return value
    }

    func fetchNews(completion: (() -> Void)? = nil) {
        
        let endPoints = EndPoint(baseUrl: .latestNews,
                                 methodName: URLs.latestNewsStartEndpoint + currentLanguage.rawValue + URLs.newsEndEndpoint,
                                 method: .get, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParam: Encodable {}
        let param = DefaultParam()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoints, params: param, res: [NewsModel].self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(news):
                self.newsResult.value = news
            case let .failure(error):
                self.newsResult.error = error
            }
            if let completion = completion {
                completion()
            }
        }
    }
}
