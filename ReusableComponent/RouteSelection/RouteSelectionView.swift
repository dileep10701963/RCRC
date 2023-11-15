//
//  SelectOriginDestinationView.swift
//  RCRC
//
//  Created by Errol on 28/09/20.
//

import UIKit
import GoogleMaps

protocol RouteSelectionViewDelegate: AnyObject {
    func didTapButton(tag: Int)
    func didSelectPlace(for type: SearchBars, location: LocationData)
    func searchCancelled(for searchBar: SearchBars, searchBarField: UISearchBar, isBeginEditing: Bool)
    func locationSelectionButtonTapped()
    func didSelectPreference()
    func didSelect(preferences: SearchPreference)
    func didSelectLeaveArriveButton()
    func buttonHomeWorkFavPressed(placeType: PlaceType)
    func addToFavButtonTapped()
    func tableViewPresented(for searchBar: SearchBars)
   
    
}


protocol RouteSelectionViewBackButtonDelegate: AnyObject {
    func backButtonAction()
    
}


extension RouteSelectionViewDelegate {
    func didSelectPlace(for type: SearchBars, location: LocationData) {}
    func searchCancelled(for searchBar: SearchBars, searchBarField: UISearchBar, isBeginEditing: Bool) {}
    func locationSelectionButtonTapped() {}
    func didSelectPreference() {}
    func didSelectLeaveArriveButton() {}
    func buttonHomePressed(sender: UIButton) {}
    func buttonWorkPressed(sender: UIButton) {}
    func buttonHomeWorkFavPressed(placeType: PlaceType) {}
    func addToFavButtonTapped() {}
    func tableViewPresented(for searchBar: SearchBars) {}
}

class RouteSelectionView: UIView {

    @IBOutlet weak var originSearchBar: UISearchBar!
    @IBOutlet weak var destinationSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var imageHome: UIImageView!
    @IBOutlet weak var imageWork: UIImageView!
    @IBOutlet weak var imageSchool: UIImageView!
    
    @IBOutlet weak var labelHome: UILabel!
    @IBOutlet weak var labelWork: UILabel!
    @IBOutlet weak var labelMore: UILabel!
    @IBOutlet weak var labelChangeStop: UILabel!
    
    
    @IBOutlet weak var buttonleaveArriveButton: UIButton!
    @IBOutlet weak var imagePreferences: UIImageView!
    @IBOutlet weak var buttonSwap: UIButton!
    @IBOutlet weak var labelLeaveArrive: UILabel!
    
    @IBOutlet weak var buttonWork: UIButton!
    @IBOutlet weak var buttonHome: UIButton!
    @IBOutlet weak var buttonSchool: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    /*
    @IBOutlet weak var buttonOriginSearch: UIButton!
    @IBOutlet weak var buttonDestinationSearch: UIButton!
     */
    
    var contentView: UIView!
    weak var delegate: RouteSelectionViewDelegate?
    weak var backButtonDelegate: RouteSelectionViewBackButtonDelegate?

    let viewModel = SearchResultsViewModel()
    var activeSearchBar: UISearchBar?
    var workItem: DispatchWorkItem?
    var currentLocation: CurrentLocation?
    var stopFinderResult: SearchResults?
    var superviewHeight: CGFloat = 0
    lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
    var parentController: ParentScreenController = .none

    @IBOutlet weak var backArrowImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    @IBAction func buttonBackPressed(_ sender: UIButton) {
        backButtonDelegate?.backButtonAction()
    }
    
    private func configureView() {
        configureXib()
        configureUIs()
        configureSearchBars()
        configureLabel()
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        //backArrowImage.image = backArrowImage.image?.setNewImageAsPerLanguage()
    }

    func configureSearchBars() {

        self.originSearchBar.backgroundImage = UIImage()
        self.originSearchBar.textField?.backgroundColor = .clear
        self.originSearchBar.textField?.background = UIImage()
        self.originSearchBar.placeholder = Constants.enterOrigin.localized
        self.originSearchBar.textField?.font = Fonts.CodecBold.fourteen
        self.originSearchBar.textField?.setAlignment()
        self.originSearchBar.returnKeyType = .done
        self.originSearchBar.showsBookmarkButton = true
        self.originSearchBar.setImage(Images.tripMap, for: .bookmark, state: .normal)
        self.originSearchBar.setImage(UIImage(), for: .search, state: .normal)
        self.originSearchBar.textField?.textColor = Colors.textColor
        
       // self.destinationSearchBar.backgroundImage = Images.searchBox
        //self.destinationSearchBar.textField?.backgroundColor = .clear
        //self.destinationSearchBar.textField?.layer.cornerRadius = 20
        //self.destinationSearchBar.textField?.layer.borderWidth = 0.25
        //self.destinationSearchBar.textField?.layer.borderColor = UIColor.lightGray.cgColor
        //self.destinationSearchBar.showsBookmarkButton = true
       // self.destinationSearchBar.setImage(Images.tripMap, for: .bookmark, state: .normal)
        //self.destinationSearchBar.textField?.backgroundColor = .white
        
        
       // destinationSearchBar.
        self.destinationSearchBar.circularCorner()
        //self.destinationSearchBar.setImage(UIImage(), for: .search, state: .normal)
        self.destinationSearchBar.textField?.backgroundColor = .clear
        
        self.destinationSearchBar.placeholder = Constants.routeTitleSearch.localized
        self.destinationSearchBar.textField?.font = Fonts.CodecBold.fourteen
        self.destinationSearchBar.textField?.setAlignment()
        self.destinationSearchBar.returnKeyType = .done
        self.destinationSearchBar.textField?.textColor = Colors.textColor

        originSearchBar.delegate = self
        destinationSearchBar.delegate = self

        configureSearchObserver()

        tableView.register(SearchResultsTableViewCell.nib, forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
        tableView.register(RecentSearchTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        tableView.tableFooterView = UIView()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = CGFloat.leastNormalMagnitude
        } else {
            // Fallback on earlier versions
        }
    }
    
    func configureLabel() {
        labelHome.font = Fonts.CodecRegular.sixteen
        labelWork.font = Fonts.CodecRegular.sixteen
        labelMore.font = Fonts.CodecBold.sixteen
        
        labelHome.textColor = Colors.textDarkColor
        labelWork.textColor = Colors.textDarkColor
        labelMore.textColor = Colors.buttonTintColor //textDarkColor
        
        labelHome.text = Constants.home.localized
        labelWork.text = Constants.work.localized
        labelMore.text = Constants.favoriteRoutes.localized //myFavoriteRoutes
        labelChangeStop.text = Constants.changeStop.localized
        buttonCancel.setTitle(cancel, for: .normal)
    }
    
    func configureUIs() {
        
        imageHome.image = Images.tripHome
        imageWork.image = Images.tripWork
        imageSchool.image = Images.tripFavGreen //.tripFav
        imagePreferences.image = Images.ptAddToFavorite
        imageSchool.isHidden = true
        self.addActionToFavIcon()
    }
    
    private func addActionToFavIcon() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addFavIconButtonTapped))
        imagePreferences.isUserInteractionEnabled = true
        imagePreferences.addGestureRecognizer(tapGesture)
    }
    
    @objc func addFavIconButtonTapped() {
        delegate?.addToFavButtonTapped()
    }
    
    @IBAction func buttonLeaveArriveButtonTapped(_ sender: UIButton) {
        delegate?.didSelectLeaveArriveButton()
    }

    func configureXib() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }

    var selectedPreferences: SelectedSearchPreferences? = nil
    func initialize(with preferences: SelectedSearchPreferences? = nil) {
        selectedPreferences = preferences
    }

    @IBAction func buttonHomeTapped(_ sender: UIButton) {
        delegate?.buttonHomeWorkFavPressed(placeType: .home)
    }
    
    @IBAction func buttonWorkTapped(_ sender: UIButton) {
        delegate?.buttonHomeWorkFavPressed(placeType: .work)
    }

    @IBAction func buttonSchoolTapped(_ sender: UIButton) {
        self.endEditing(true)
        workItem?.cancel()
        DispatchQueue.main.async {
            self.activeSearchBar?.isLoading = false
            self.tableViewHeight.constant = 0
        }
        delegate?.buttonHomeWorkFavPressed(placeType: .favorite)
    }
    
    @IBAction func swapButtonTapped(_ sender: UIButton) {
        delegate?.didTapButton(tag: sender.tag)
        if originSearchBar.text == Constants.yourCurrentLocation {
            self.originSearchBar.text = self.destinationSearchBar.text
            self.destinationSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized, attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
        } else if destinationSearchBar.text == Constants.yourCurrentLocation {
            self.destinationSearchBar.text = self.originSearchBar.text
            self.originSearchBar.textField?.attributedText = NSAttributedString(string: Constants.yourCurrentLocation.localized, attributes: [.foregroundColor: Colors.yourCurrentLocationGreen])
        } else {
            (originSearchBar.text, destinationSearchBar.text) = (destinationSearchBar.text, originSearchBar.text)
        }
    }
    
    /*
    @IBAction func buttonOriginSearchBarTapped(_ sender: UIButton) {
        delegate?.didTapButton(tag: 10)
    }
    
    @IBAction func buttonDestinationSearchBarTapped(_ sender: UIButton) {
        delegate?.didTapButton(tag: 11)
    }
    */
    
    func loadViewFromNib() -> UIView? {
        let nibName = ReusableViews.routeSelectionView
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let translatedPoint = tableView.convert(point, from: self)
        if tableView.bounds.contains(translatedPoint) {
            return tableView.hitTest(translatedPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }
}

// MARK: - Search Implementation
extension RouteSelectionView: UISearchBarDelegate {

    private func configureSearchObserver() {
        self.viewModel.stopFinderResults.bind { [weak self] (result, error) in
            guard let self = self else { return }
            self.activeSearchBar?.isLoading = false
            if result != nil, error == nil {
                self.stopFinderResult = result
                if self.activeSearchBar?.text?.count ?? 0 >= 0 {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if let safeAreaLayoutGuide = self.superview?.safeAreaLayoutGuide {
                            self.superviewHeight = safeAreaLayoutGuide.layoutFrame.size.height
                        }
                        self.tableViewHeight.constant = UIScreen.main.bounds.height - (self.bounds.height + Constants.navBarWithPadding) //self.superviewHeight
                        if self.tableViewHeight.constant > 0 {
                            self.delegate?.tableViewPresented(for: self.activeSearchBar == self.originSearchBar ? .origin: .destination)
                        }
                    }
                }
            } else if error != nil {
                DispatchQueue.main.async {
                    self.activeSearchBar?.resignFirstResponder()
                    self.tableViewHeight.constant = 0
                }
            }
        }
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.activeSearchBar = searchBar
        if let text = searchBar.text, text == Constants.yourCurrentLocation.localized {
            searchBar.text = emptyString
        }
        searchBar.textField?.layer.borderColor = Colors.green.cgColor
        //searchBar.isLoading = false
        if searchBar == originSearchBar {
            delegate?.searchCancelled(for: .origin, searchBarField: searchBar, isBeginEditing: true)
        } else {
            delegate?.searchCancelled(for: .destination, searchBarField: searchBar, isBeginEditing: true)
        }
        
        if searchBar.text == nil || searchBar.text == emptyString {
            workItem?.cancel()
            searchBar.isLoading = false
            searchBar.isLoading = true
            self.activeSearchBar = searchBar
            workItem = DispatchWorkItem { self.viewModel.searchText = emptyString }
            if let workItem = self.workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
            }
            
        }
        
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.textField?.layer.borderColor = UIColor.clear.cgColor
        //searchBar.isLoading = false
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.textField?.layer.borderColor = UIColor.clear.cgColor
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        workItem?.cancel()
        searchBar.isLoading = false
        if searchText.count > 0 {
            searchBar.isLoading = true
            self.activeSearchBar = searchBar
            workItem = DispatchWorkItem { self.viewModel.searchText = searchText }
            if let workItem = self.workItem {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
            }
        } else if searchText.count == 0 {
            tableViewHeight.constant = 0
            if searchBar == originSearchBar {
                delegate?.searchCancelled(for: .origin, searchBarField: searchBar, isBeginEditing: false)
            } else if searchBar == destinationSearchBar {
                delegate?.searchCancelled(for: .destination, searchBarField: searchBar, isBeginEditing: false)
            }
        } else {
            tableViewHeight.constant = 0
        }
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }

    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if searchBar == originSearchBar {
            delegate?.didTapButton(tag: 10)
        } else if searchBar == destinationSearchBar {
            delegate?.didTapButton(tag: 11)
        }
        
    }
    
    func isPlaceSaved(location: RecentSearch) -> Bool {
        if let savedData = RecentSearchDataRepository.shared.fetchAll(),
           savedData.contains(location) {
            return true
        }
        return false
    }
    
}

extension RouteSelectionView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stopFinderResult?.locations.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecentSearchTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
        if let place = stopFinderResult?.locations[safe: indexPath.row], let lat = place?.coord?.first, let long = place?.coord?.last {
            let location = SavedLocation(location: place?.disassembledName ?? place?.name ?? emptyString, address: emptyString, id: place?.id, latitude: lat, longitude: long, type: Constants.stop, tag: place?.name)
            cell.configure(image: Images.triangleLocationMarker, location: location, screenName: .none)//Images.triangleLocationMarker
            cell.updateUIForStopFinderResult(location: location)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.endEditing(true)
        workItem?.cancel()
        DispatchQueue.main.async {
            self.activeSearchBar?.isLoading = false
            self.tableViewHeight.constant = 0
        }
        
        let selectedLocation = stopFinderResult?.locations[indexPath.row]
        let placeName = selectedLocation?.disassembledName ?? selectedLocation?.name ?? emptyString
        
        if let lat = selectedLocation?.coord?.first, let long = selectedLocation?.coord?.last {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let data = LocationData(id: selectedLocation?.id ?? "", address: "", subAddress: placeName, coordinate: coordinate, type: .stop)
            activeSearchBar?.text = selectedLocation?.disassembledName ?? selectedLocation?.name ?? ""
            activeSearchBar?.resignFirstResponder()
            let isOriginActive = activeSearchBar == originSearchBar
            delegate?.didSelectPlace(for: isOriginActive ? .origin : .destination, location: data)
            backButtonDelegate?.backButtonAction()
            
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.searchResultsTableHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.tempHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
