//
//  NewsViewController.swift
//  RCRC
//
//  Created by anand madhav on 24/06/20.
//  Copyright © 2020 fluffy. All rights reserved.
//

import UIKit

let defaultSelectiontag = 10001

class NewsViewController: ContentViewController {

    var newsViewModel = NewsViewModel()
    var selected = defaultSelectiontag
    @IBOutlet weak var newsTableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.white, NSAttributedString.Key.font: Fonts.Bold.eighteen!]
        self.navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .white
        self.configureNavigationBar(title: Constants.news.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .news)
        self.navigationItem.rightBarButtonItem = nil
        newsTableView.register(NewsCell.nib, forCellReuseIdentifier: NewsCell.identifier)
        newsTableView.register(ButtonTableViewCell.nib, forCellReuseIdentifier: ButtonTableViewCell.identifier)
        newsTableView.dataSource = self
        newsTableView.delegate = self
        self.newsTableView?.rowHeight = UITableView.automaticDimension
        self.newsTableView.backgroundColor = Colors.backgroundGray
        self.disableLargeNavigationTitleCollapsing()
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchLatestNews()
        fetchNews()
    }

    private func fetchNews() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        newsViewModel.fetchNews()
    }
    
    func fetchLatestNews() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activityIndicator = self.startActivityIndicator()
        newsViewModel.newsResult.bind { [weak self] result, error in
            if error != nil {
                self?.showAlert(for: .serverError)
                self?.newsTableView.setEmptyMessage(Constants.noResultsAlertTitle)
            } else if result != nil {
                DispatchQueue.main.async {
                    activityIndicator.stop()
                    if self?.newsViewModel.newsCount ?? 0 < 1 {
                        self?.newsTableView.setEmptyMessage(Constants.noResultsAlertTitle)
                    }
                    self?.newsTableView.reloadData()
                }
            }
        }
    }
}

extension NewsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return newsViewModel.newsCount + 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsViewModel.newsCount > 0 ? 1 : 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = Colors.backgroundGray
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as? ButtonTableViewCell
            cell?.backgroundColor = Colors.backgroundGray
            cell?.button.setTitle(Constants.subscribe.localized, for: .normal)
            return cell ?? UITableViewCell()
        } else if indexPath.section == newsViewModel.newsCount + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as? ButtonTableViewCell
            cell?.backgroundColor = Colors.backgroundGray
            cell?.button.setTitle(Constants.readMoreNews.localized, for: .normal)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell
            if indexPath.section < 2 {
                cell?.readMoreButton.tag = indexPath.section
                cell?.readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
                if let news = newsViewModel.fetchNews(index: indexPath.section) {
                    let imagePath = news.tileImageURL ?? emptyString
                    let imageUrl = URLs.baseUrl + imagePath
                    if let url = URL(string: imageUrl) as NSURL? {
                        NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                            if let image = image {
                                newsImageCache.setObject(image, forKey: NewsImageCache(url: url))
                                DispatchQueue.main.async {
                                    cell?.incidentImage.image = image
                                }
                            }
                        }
                    }
                    cell?.displayNews(newsModel: news)
                }
            } else if indexPath.section > 2 && indexPath.section < (newsViewModel.newsCount + 1) {
                cell?.readMoreButton.tag = indexPath.section - 1
                cell?.readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)
                if let news = newsViewModel.fetchNews(index: indexPath.section - 1) {
                    let imagePath = news.tileImageURL ?? emptyString
                    let imageUrl = URLs.baseUrl + imagePath
                    if let url = URL(string: imageUrl) as NSURL? {
                        NetworkImage.shared.fetchImage(url as URL) { [weak self] (image) in
                            if let image = image {
                                newsImageCache.setObject(image, forKey: NewsImageCache(url: url))
                                DispatchQueue.main.async {
                                    cell?.incidentImage.image = image
                                }
                            }
                        }
                    }
                    cell?.displayNews(newsModel: news)
                }
            }
            cell?.backgroundColor = .white
            cell?.borderWidth = 0.4
            cell?.borderColor = Colors.darkGray
            return cell ?? UITableViewCell()
        }
    }

    @objc func readMoreTapped(sender: UIButton) {
        let detailedNewsViewController: DetailedNewsViewController = DetailedNewsViewController.instantiate(appStoryboard: .news)
        detailedNewsViewController.newsViewModel = newsViewModel
        detailedNewsViewController.index = sender.tag
        self.navigationController?.pushViewController(detailedNewsViewController, animated: true)
    }
}

extension NewsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            return
        } else if indexPath.section == newsViewModel.newsCount + 1 {
            self.showCustomAlert(alertTitle: Constants.moreNews.localized,
                                 alertMessage: Constants.moreNewsAlertMessage.localized,
                                 firstActionTitle: cancel,
                                 secondActionTitle: proceed,
                                 secondActionStyle: .default,
                                 secondActionHandler: {
                                    let url = "https://37.224.41.117:8080/web/guest/news"
                                    ApplicationSchemes.shared.openInBrowser(url)
                                 })
        }
    }
}
