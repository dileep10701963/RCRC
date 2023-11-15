//
//  DetailedNewsViewController.swift
//  RCRC
//
//  Created by Errol on 01/03/21.
//

import UIKit
import AlamofireImage

class DetailedNewsViewController: UIViewController {

    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsTimeLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var previousNewsButton: UIButton!
    @IBOutlet weak var nextNewsButton: UIButton!
    @IBOutlet weak var moreNewsCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailedNewsView: UIView!
    @IBOutlet weak var shareNewsButton: UIButton!

    var newsData: [NewsModel]? {
        didSet {
            configureMoreNews()
        }
    }
    var moreNewsData: [NewsModel]?
    var index: Int?
    var didLoadView: Bool = false
    var collectionViewIndex: Int? {
        didSet {
            if let index = collectionViewIndex {
                if index == 0 {
                    self.previousNewsButton.setImage(Images.moreNewsPreviousDisabled, for: .normal)
                } else if index == 8 {
                    self.nextNewsButton.setImage(Images.moreNewsNextDisabled, for: .normal)
                } else {
                    self.previousNewsButton.setImage(Images.moreNewsPreviousEnabled, for: .normal)
                    self.nextNewsButton.setImage(Images.moreNewsNextEnabled, for: .normal)
                }
            }
        }
    }
    var newsViewModel: NewsViewModel?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.news.localized)
        self.navigationItem.backBarButtonItem?.tintColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.shareNewsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            self.shareNewsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        } else {
            self.shareNewsButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            self.shareNewsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        }
        self.newsTitleLabel.setAlignment()
        self.newsTimeLabel.setAlignment()
        self.newsDescription.setAlignment()
        self.disableLargeNavigationTitleCollapsing()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .newsDetails)
        didLoadView = true
        displayNews()
        moreNewsCollectionView.register(MoreNewsCollectionViewCell.nib, forCellWithReuseIdentifier: MoreNewsCollectionViewCell.identifier)
        moreNewsCollectionView.dataSource = self
        moreNewsCollectionView.delegate = self
    }

    fileprivate func configureMoreNews() {
        moreNewsData = newsData
        if let index = index {
            moreNewsData?.remove(at: index)
            if index == 0 {
                self.previousNewsButton.setImage(Images.moreNewsPreviousDisabled, for: .normal)
            } else if index == 9 {
                self.nextNewsButton.setImage(Images.moreNewsNextDisabled, for: .normal)
            } else {
                self.previousNewsButton.setImage(Images.moreNewsPreviousEnabled, for: .normal)
                self.nextNewsButton.setImage(Images.moreNewsNextEnabled, for: .normal)
            }
        }
        navigateToNews(index ?? 0)
        collectionViewIndex = index
    }

    fileprivate func displayNews() {
        newsViewModel?.newsResult.bind({ (news, error) in
            guard let news = news, error == nil, let index = self.index else { return }
            self.newsData = news
            let imagePath = news[index].tileImageURL ?? emptyString
            let imageUrl = URLs.baseUrl + imagePath
            if let url = URL(string: imageUrl) as NSURL? {
                if let image = newsImageCache.object(forKey: NewsImageCache(url: url)) {
                    DispatchQueue.main.async {
                        self.newsImage.image = image
                    }
                } else {
                    NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                        if let image = image {
                            newsImageCache.setObject(image, forKey: NewsImageCache(url: url))
                            DispatchQueue.main.async {
                                self?.newsImage.image = image
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self.newsTitleLabel.text = news[index].title
                self.newsTimeLabel.text = news[index].publishDate?.toDate(timeZone: .AST)?.toString(withFormat: "EEEE MMMM dd, yyyy", timeZone: .AST)
                self.newsDescription.text = news[index].newsModelDescription
            }
        })
    }

    fileprivate func navigateToNews(_ index: Int) {
        if index == moreNewsData?.count ?? 0 - 1 {
            DispatchQueue.main.async {
                self.moreNewsCollectionView.isPagingEnabled = false
                self.moreNewsCollectionView.scrollToItem(at: IndexPath(item: index - 1, section: 0), at: .centeredHorizontally, animated: true)
                self.moreNewsCollectionView.isPagingEnabled = true
            }
        } else {
            DispatchQueue.main.async {
                self.moreNewsCollectionView.isPagingEnabled = false
                self.moreNewsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                self.moreNewsCollectionView.isPagingEnabled = true
            }
        }
    }

    @IBAction func previousNewsTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.moreNewsCollectionView.isPagingEnabled = false
            if let collectionViewIndex = self.collectionViewIndex, collectionViewIndex > 0 {
                self.moreNewsCollectionView.scrollToItem(at: IndexPath(row: collectionViewIndex - 1, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionViewIndex! -= 1
            }
            if self.collectionViewIndex == 0 {
                self.previousNewsButton.setImage(Images.moreNewsPreviousDisabled, for: .normal)
            }
            self.moreNewsCollectionView.isPagingEnabled = true
        }
    }

    @IBAction func nextNewsTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.moreNewsCollectionView.isPagingEnabled = false
            if let collectionViewIndex = self.collectionViewIndex, collectionViewIndex < 8 {
                self.moreNewsCollectionView.scrollToItem(at: IndexPath(row: collectionViewIndex + 1, section: 0), at: .centeredHorizontally, animated: true)
                self.collectionViewIndex! += 1
            }
            if self.collectionViewIndex == 8 {
                self.nextNewsButton.setImage(Images.moreNewsNextDisabled, for: .normal)
            }
            self.moreNewsCollectionView.isPagingEnabled = true
        }
    }

    @IBAction func shareNewsTapped(_ sender: UIButton) {
        guard let url = URL(string: newsData?[sender.tag].newsURL ?? emptyString) else { return }
        let viewController = UIActivityViewController(activityItems: [url], applicationActivities: [])
        present(viewController, animated: true)
    }
}

extension DetailedNewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = self.moreNewsData?.count {
            return count
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = moreNewsCollectionView.dequeueReusableCell(withReuseIdentifier: MoreNewsCollectionViewCell.identifier, for: indexPath) as? MoreNewsCollectionViewCell
        cell?.newsTitle.text = self.moreNewsData?[indexPath.row].title
        cell?.newsTime.text = self.moreNewsData?[indexPath.row].publishDate?.toDate(timeZone: .AST)?.toString(withFormat: "EEEE MMMM dd, yyyy", timeZone: .AST)
        let imagePath = self.moreNewsData?[indexPath.row].tileImageURL ?? emptyString
        let imageUrl = URLs.baseUrl + imagePath
        if let url = URL(string: imageUrl) as NSURL? {
            if let image = newsImageCache.object(forKey: NewsImageCache(url: url)) {
                DispatchQueue.main.async {
                    cell?.newsImage.image = image
                }
            } else {
                ServiceManager.sharedInstance.downloadImage(url: imageUrl) { [weak cell] result in
                    if case let .success(newsImage) = result {
                        newsImageCache.setObject(newsImage, forKey: NewsImageCache(url: url))
                        DispatchQueue.main.async {
                            cell?.newsImage.image = newsImage
                        }
                    }
                }
            }
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= index ?? 0 {
            self.index = indexPath.row + 1
        } else {
            self.index = indexPath.row
        }
        self.scrollView.setContentOffset(.zero, animated: true)
        moreNewsData = newsData
        moreNewsData?.remove(at: index ?? 0)
        displayNews()
        self.moreNewsCollectionView.reloadData()
        navigateToNews(index ?? 0)
    }
}
