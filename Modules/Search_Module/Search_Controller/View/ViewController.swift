//
//  ViewController.swift
//  TwoWayBindingDemo
//
//  Created by Errol on 09/07/20.
//  Copyright © 2020 Errol. All rights reserved.
//

import UIKit

class SearchResultViewController: UIViewController {
    @IBOutlet weak var searchTextField: BindedUITextField! {
        didSet {
            searchTextField.bind {
                self.viewModel.fetchSearchResults(input: $0)
            }
        }
    }
    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel: SearchResultViewModel = {
        let viewModel = SearchResultViewModel()
        return viewModel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SearchResultTableViewCell.nib, forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()

        self.viewModel.searchResults.bind { (_) in
            self.tableView.reloadData()
        }
    }
}
extension SearchResultViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.searchResults.value?.stopFinder.points.count == nil {
            return 0
        } else {
            return (self.viewModel.searchResults.value?.stopFinder.points.count)!
        }
        // return 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath) as? SearchResultTableViewCell
        cell?.item = self.viewModel.searchResults.value?.stopFinder.points[indexPath.row].name
        return cell ?? UITableViewCell()
    }
}
