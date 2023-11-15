//
//  EventListViewController.swift
//  RCRC
//
//  Created by Errol on 22/06/21.
//

import UIKit
import CoreLocation

class EventListViewController: UIViewController {
    typealias EventsDisplayData = (currentEvents: [EventCellViewModel], upcomingEvents: [EventCellViewModel])

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchBar: RCRCSearchBar!
    @IBOutlet weak var eventsTableView: UITableView!

    private var currentEvents: [EventCellViewModel] = []
    private var upcomingEvents: [EventCellViewModel] = []
    private let viewModel = EventListViewModel(eventsLoader: EventsLoader())
    private var currentLocation: CLLocationCoordinate2D?
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Colors.green
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    private var workItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .event)
        configureSearchBar()
        configureTableView()
        loadEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(title: Constants.events.localized)
    }

    private func configureSearchBar() {
        searchBar.delegate = self
    }

    private func configureTableView() {
        eventsTableView.register(EventTableViewCell.nib, forCellReuseIdentifier: EventTableViewCell.identifier)
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        eventsTableView.refreshControl = refreshControl
    }

    private func configureTableViewFooter(isEnabled: Bool = true) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: eventsTableView.frame.size.width, height: 15))
        view.backgroundColor = Colors.tableViewHeader
        let label = UILabel()
        label.text = Constants.thatsAll
        label.font = Fonts.RptaSignage.twelve
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.pinEdgesToSuperView()
        eventsTableView.tableFooterView = isEnabled ? view : .none
    }

    @objc private func onRefresh(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            loadEvents()
        }
    }

    private func loadEvents() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        refreshControl.beginRefreshing()
        viewModel.loadEvents { [weak self] result in
            self?.handleResult(result, errorMessage: Constants.noEventsMessage)
        }
    }

    private func searchEvents(keyword: String) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        refreshControl.beginRefreshing()
        viewModel.searchEvents(keyword: keyword) { [weak self] result in
            self?.handleResult(result, errorMessage: Constants.noEventsSearchMessage)
        }
    }

    private func handleResult(_ result: EventsDisplayData, errorMessage: String) {
        self.currentEvents = result.currentEvents
        self.upcomingEvents = result.upcomingEvents
        let isEventsNotEmpty = result.currentEvents.isNotEmpty || result.upcomingEvents.isNotEmpty
            self.searchBar.isLoading = false
            self.configureTableViewFooter(isEnabled: isEventsNotEmpty)
            self.eventsTableView.reloadData()
            self.refreshControl.endRefreshing()
        
        if currentEvents.isEmpty && upcomingEvents.isEmpty {
            self.searchBar.isLoading = false
            self.eventsTableView.setEmptyMessage(errorMessage.localized)
            self.eventsTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension EventListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if currentEvents.isNotEmpty, upcomingEvents.isNotEmpty {
            return 2
        }
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentEvents.isNotEmpty, upcomingEvents.isNotEmpty {
            if section == 0 {
                return currentEvents.count
            }
            return upcomingEvents.count
        }
        return currentEvents.count + upcomingEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EventTableViewCell = tableView.dequeue(cellForRowAt: indexPath)

        if currentEvents.isNotEmpty, upcomingEvents.isNotEmpty {
            if indexPath.section == 0 {
                let cellViewModel = currentEvents[indexPath.row]
                cell.initialize(with: cellViewModel)
            } else {
                let cellViewModel = upcomingEvents[indexPath.row]
                cell.initialize(with: cellViewModel)
            }
        } else if currentEvents.isNotEmpty {
            let cellViewModel = currentEvents[indexPath.row]
            cell.initialize(with: cellViewModel)
        } else if upcomingEvents.isNotEmpty {
            let cellViewModel = upcomingEvents[indexPath.row]
            cell.initialize(with: cellViewModel)
        }
        cell.readMoreTapped = self.readMoreTapped
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = .darkGray
        header.backgroundColor = Colors.tableViewHeader
        header.tintColor = Colors.tableViewHeader
        header.textLabel?.frame = header.frame
        header.textLabel?.font = Fonts.RptaSignage.fifteen
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if currentEvents.isNotEmpty, upcomingEvents.isNotEmpty {
            if section == 0 {
                return Constants.currentEvents
            }
            return Constants.upcomingEvents
        } else if currentEvents.isNotEmpty {
            return Constants.currentEvents
        } else if upcomingEvents.isNotEmpty {
            return Constants.upcomingEvents
        }
        return .none
    }

    private func readMoreTapped(_ viewModel: EventCellViewModel) {
        let viewController = EventDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension EventListViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.layer.borderColor = Colors.green.cgColor
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.layer.borderColor = UIColor.clear.cgColor
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        workItem?.cancel()
        if searchText.count > 0 {
            searchBar.isLoading = true
            workItem = DispatchWorkItem { self.searchEvents(keyword: searchText) }
            if let workItem = self.workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
            }
        } else {
            searchBar.isLoading = false
            loadEvents()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let searchBarText = searchBar.textField?.text, let textRange = Range(range, in: searchBarText) {
            let updatedText = searchBarText.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
}
