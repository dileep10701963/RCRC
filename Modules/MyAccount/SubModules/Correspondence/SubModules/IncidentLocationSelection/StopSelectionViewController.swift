//
//  IncidentLocationSelectionFromStopfinderViewController.swift
//  RCRC
//
//  Created by Errol on 27/04/21.
//

import UIKit

protocol ReportLocationSelectionDelegate: AnyObject {
    func didSelectLocation(_ stopFinderLocation: Location)
    func didSelectLocation(_ mapLocation: MapLocation)
}

extension ReportLocationSelectionDelegate {
    func didSelectLocation(_ stopFinderLocation: Location) {}
    func didSelectLocation(_ mapLocation: MapLocation) {}
}

class StopSelectionViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let searchResultsViewModel = SearchResultsViewModel()
    var selected: Bool = false
    var stopFinderResult: SearchResults?
    weak var delegate: ReportLocationSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .stopSelection)
        configureNavigationBar(title: "Select Location of Incident".localized)
        initialize()
        configureObserver()
    }

    private func initialize() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        searchBar.textField?.borderWidth = 1.0
        searchBar.textField?.borderColor = .clear
        searchBar.textField?.cornerRadius = 10
        searchBar.textField?.font = Fonts.RptaSignage.eighteen
        searchBar.tintColor = Colors.green
        searchBar.delegate = self
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.masksToBounds = false
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.2
        tableView.layer.shadowOffset = CGSize(width: 1, height: 1)
    }

    private func configureObserver() {
        searchResultsViewModel.stopFinderResults.bind { (result, error) in
            if let result = result, error == nil, !self.selected {
                self.stopFinderResult = result
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else if let error = error {
                self.showCustomAlert(alertTitle: "Error".localized, alertMessage: error.localizedDescription, firstActionTitle: ok, firstActionStyle: .default)
            }
        }
    }
}

extension StopSelectionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopFinderResult = self.stopFinderResult else { return 0 }
        return stopFinderResult.locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopFinderResult = self.stopFinderResult else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = Images.historyPlace
        cell.textLabel?.text = stopFinderResult.locations[indexPath.row]?.name
        cell.textLabel?.font = Fonts.RptaSignage.eighteen
        cell.detailTextLabel?.text = stopFinderResult.locations[indexPath.row]?.id
        cell.detailTextLabel?.font =  Fonts.RptaSignage.fifteen
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let location = self.stopFinderResult?.locations[indexPath.row] else { return }
        delegate?.didSelectLocation(location)
        self.navigationController?.popViewController(animated: true)
    }
}

extension StopSelectionViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.textField?.borderColor = Colors.green
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.borderColor = .clear
//        searchBar.isLoading = false
        searchBar.text = nil
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            selected = false
//            searchBar.isLoading = true
            searchResultsViewModel.searchText = searchText
        } else {
//            searchBar.isLoading = false
            tableView.isHidden = true
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
