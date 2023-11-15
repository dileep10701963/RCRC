//
//  ViewController.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

protocol TravelPreferenceViewControllerDelegate: AnyObject {
    func updatedTravelPreferences(modal: TravelPreferenceModel)
}

class TravelPreferenceViewController: UIViewController {
    @IBOutlet weak var preferenceTableView: UITableView!
    @IBOutlet weak var savePreferencesButton: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var arrayImageView: [UIImageView]!
    
    var picker: PickerWithDoneButton?
    var travelPreferencesViewModel = TravelPreferencesViewModel()
    var travelPreferenceModel: TravelPreferenceModel!
    var activityIndicator: UIActivityIndicatorView?
    var selectedWalkMaxTime: Int = 2
    var delegate: TravelPreferenceViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .travelPreference)
        configureTableView()
        headerTitle.text = Constants.travelPreferences.localized
        
        if self.travelPreferenceModel == nil {
            self.travelPreferenceModel = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: false, maxTime: .fifteenMin, metroTransport: false, routePreference: .quickest, uberTransport: false, walkSpeed: .normal)
        } else {
            if let selectedWalkMaxTimeIndex = MaxWalkTimePreferences.allCases.firstIndex(where: {$0.rawValue == travelPreferenceModel.maxTime?.rawValue}) {
                selectedWalkMaxTime = selectedWalkMaxTimeIndex
            }
        }
        
        self.disableLargeNavigationTitleCollapsing()
        self.configureNavigationBar(title: emptyString)
        
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        
        savePreferencesButton.setTitle(Constants.savePreferences.localized, for: .normal)
        savePreferencesButton.setBackgroundImage(Images.buttonLarge?.setNewImageAsPerLanguage(), for: .normal)
        savePreferencesButton.titleLabel?.textAlignment = .center
        
    }
    
    func configureTableView() {
        preferenceTableView.rowHeight = UITableView.automaticDimension
        preferenceTableView.estimatedRowHeight = 44
        preferenceTableView.registerHeaderFooterViewNib(TravelPreferenceHeaderView.self)
        preferenceTableView.register(FriendlyStopCell.self)
        preferenceTableView.register(MaximumWalkTimeCell.self)
        preferenceTableView.register(TravelPreferenceCollectionCell.self)
        preferenceTableView.register(TransportMethodSubHeader.self)
        preferenceTableView.register(TransportMethodCell.self)
        preferenceTableView.register(FilterRoutesByCell.self)
        preferenceTableView.register(SortRoutesByCell.self)
        preferenceTableView.register(ResetButtonCell.self)
        preferenceTableView.register(AlternativeStopCell.self)
        preferenceTableView.backgroundColor = Colors.backgroundGray
        if #available(iOS 15.0, *) {
            preferenceTableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }

    @IBAction func savePreferencesTapped(_ sender: Any) {
        
        switch AppDefaults.shared.isUserLoggedIn {
        case true:
            self.showCustomAlert(alertTitle: Constants.savePreferencesTitle.localized, alertMessage: Constants.savePreferencesMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel, firstActionHandler: {
                DispatchQueue.main.async {
                    if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                        return
                    }
                    self.activityIndicator = self.startActivityIndicator()
                    self.travelPreferencesViewModel.saveTravelPreferences(preferenceModel: self.travelPreferenceModel, completion: self.handleResponseResult(_:))
                }
            }, secondActionHandler: nil)
        case false:
            delegate?.updatedTravelPreferences(modal: self.travelPreferenceModel)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleResponseResult(_ result: ResponseResult) {
        activityIndicator?.stop()
        switch result {
        case .success:
            delegate?.updatedTravelPreferences(modal: self.travelPreferenceModel)
            self.navigationController?.popViewController(animated: true)
        case .failure(let error, _):
            switch error {
            case .invalidToken:
                self.showAlert(for: .invalidToken)
            default:
                self.showAlert(for: .serverError)
            }
        }
    }
    
    private func hidePicker() {
        self.picker?.removeFromSuperview()
    }
}

extension TravelPreferenceViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return TravelPreferenceConstants.travelPreferencesHeaders.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return TransportMethodPreferences.allCases.count+1
        case 1:
            return RoutePreference.allCases.count
        case 2:
            return 1
        case 3:
            return WalkSpeedPreference.allCases.count
        case 4:
            return 1
        case 5:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case TravelPreferenceConstants.travelPreferencesHeaders.count - 1:
            return 5
        default:
            return 51
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                let cell: TransportMethodSubHeader = tableView.dequeue(cellForRowAt: indexPath)
                return cell
            } else {
                let cell: TransportMethodCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configure(indexPath: indexPath, model: self.travelPreferenceModel)
                return cell
            }
        case 1:
            let cell: FilterRoutesByCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.headerLabel.text = RoutePreference.allCases[indexPath.row].displayName.localized
            cell.tag = indexPath.row
            cell.optionsSelectionButton.tag = indexPath.row
            cell.reloadTableView = self.reloadSortByTableView
            
            if RoutePreference.allCases.count - 1 == indexPath.row {
                cell.seperatorLabel.isHidden = true
                cell.separatorBottomConstraint.constant = 8
            } else {
                cell.seperatorLabel.isHidden = false
                cell.separatorBottomConstraint.constant = 0
            }
            
            if let selectedIndex = RoutePreference.allCases.firstIndex(where: {$0 == travelPreferenceModel.routePreference}), selectedIndex == indexPath.row {
                cell.optionsSelectionButton.isSelected  = true
            } else {
                cell.optionsSelectionButton.isSelected  = false
            }
            
            return cell
        case 2:
            let cell: TravelPreferenceCollectionCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.reloadWalkTimeByTableView = self.reloadWalkTimeByTableView
            cell.selectedWalkMaxTime = self.selectedWalkMaxTime
            return cell
        case 3:
            let cell: SortRoutesByCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.sortRouteByLabel.text = WalkSpeedPreference.allCases[indexPath.row].displayName.localized
            cell.tag = indexPath.row
            cell.optionsSelectionButton.tag = indexPath.row
            cell.reloadSortByTableView = self.reloadSortByTableView
            
            if WalkSpeedPreference.allCases.count - 1 == indexPath.row {
                cell.separatorLabel.isHidden = true
                cell.separatorBottomConstraint.constant = 8
            } else {
                cell.separatorLabel.isHidden = false
                cell.separatorBottomConstraint.constant = 0
            }
            
            if let index = WalkSpeedPreference.allCases.firstIndex(where: {$0 == travelPreferenceModel.walkSpeed}), index == indexPath.row {
                cell.optionsSelectionButton.isSelected = true
            } else {
                cell.optionsSelectionButton.isSelected = false
            }
            
            return cell
        case 4:
            let cell: AlternativeStopCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.sortRouteLabelText.text = TravelPreferenceConstants.alternativeStops[indexPath.row].localized
            cell.tag = indexPath.row
            cell.buttonSwitch.tag = indexPath.row
            cell.reloadTableView = self.reloadSortByTableView
            cell.buttonSwitch.isOn = self.travelPreferenceModel.alternativeStopsPreference ?? false
            return cell
        case 5:
            let cell: ResetButtonCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.resetButtonClicked = { [weak self] travelPreference in
                self?.selectedWalkMaxTime = 2
                self?.travelPreferenceModel = travelPreference
                self?.preferenceTableView.reloadData()
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if section == TravelPreferenceConstants.travelPreferencesHeaders.count - 1 {
            return tableView.tempHeaderView()
        }
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String.className(TravelPreferenceHeaderView.self)) as? TravelPreferenceHeaderView
        headerView?.headerLabel.text = TravelPreferenceConstants.travelPreferencesHeaders[section].localized
        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
            } else {
                let cell = preferenceTableView.cellForRow(at: indexPath) as? TransportMethodCell
                if cell?.isSelected == true {
                    if cell?.tickandUntickCellImageview.image == nil {
                        cell?.tickandUntickCellImageview.image = Images.tickMark
                    } else {
                        cell?.tickandUntickCellImageview.image = nil
                    }
                    
                    if let transportMethodPreference = TransportMethodPreferences.allCases.first(where: {$0.transportMethodName == cell?.transportLabel.text ?? ""}) {
                        switch transportMethodPreference {
                        case .bus:
                            self.travelPreferenceModel.busTransport = !(self.travelPreferenceModel.busTransport ?? false)
                        }
                    }
                    
                }
            }
        case 2:
            if let selectedWalkMaxTimeIndex = MaxWalkTimePreferences.allCases.firstIndex(where: {$0.rawValue == travelPreferenceModel.maxTime?.rawValue}) {
                selectedWalkMaxTime = selectedWalkMaxTimeIndex
            }
            self.picker = PickerWithDoneButton(pickerData: MaxWalkTimePreferences.allCases.map{$0.displayTime}, selected: selectedWalkMaxTime)
            configurePicker()
        default:
            break
        }
    }
    
    private func configurePicker() {
        self.picker?.delegate = self
        self.view.addSubview(self.picker ?? UIView())
        self.picker?.pinEdgesToSuperView()
        self.picker?.viewHeight = self.view.bounds.height - 200
    }
    
    struct TravelPreferenceConstants {
        
//        static let travelPreferencesHeaders = ["Mobility Impaired Friendly Stops".localized, "Methods of Transport".localized, "Route Preference".localized, "Maximum walk time".localized, "Walking speed".localized, "Alternative Stops".localized, ""]
        
        static let travelPreferencesHeaders = [Constants.methodsOfTransport, Constants.routePreference, Constants.maximumWalkTime, Constants.walkingSpeed, Constants.alternativeStops, ""]
        static let alternativeStops = [Constants.nearbyAlternativeStops]
    }

    func reloadSortByTableView(tableViewCell: UITableViewCell) {
        guard let indexPosition = preferenceTableView.indexPath(for: tableViewCell) else { return }
        switch indexPosition.section {
        case 1:
            if let previousSelectedIndex = RoutePreference.allCases.firstIndex(where: {$0 == self.travelPreferenceModel.routePreference}) {
                self.travelPreferenceModel.routePreference = RoutePreference.allCases[indexPosition.row]
                preferenceTableView.reloadRows(at: [indexPosition, IndexPath(row: previousSelectedIndex, section: 1)], with: .none)
            } else {
                self.travelPreferenceModel.routePreference = RoutePreference.allCases[indexPosition.row]
                preferenceTableView.reloadRows(at: [indexPosition], with: .none)
            }
        case 3:
            if let previousSelectedIndex = WalkSpeedPreference.allCases.firstIndex(where: {$0 == self.travelPreferenceModel.walkSpeed}) {
                self.travelPreferenceModel.walkSpeed = WalkSpeedPreference.allCases[indexPosition.row]
                preferenceTableView.reloadRows(at: [indexPosition, IndexPath(row: previousSelectedIndex, section: 3)], with: .none)
            } else {
                self.travelPreferenceModel.walkSpeed = WalkSpeedPreference.allCases[indexPosition.row]
                preferenceTableView.reloadRows(at: [indexPosition], with: .none)
            }
        case 4:
            self.travelPreferenceModel.alternativeStopsPreference = !(self.travelPreferenceModel.alternativeStopsPreference ?? false)
            preferenceTableView.reloadRows(at: [indexPosition], with: .none)
        default:
            break
        }
    }
    
    func reloadWalkTimeByTableView(tableViewCell: UITableViewCell, selectedTime: Int) {
        guard let indexPosition = preferenceTableView.indexPath(for: tableViewCell) else { return }
        switch indexPosition.section {
        case 2:
            selectedWalkMaxTime = selectedTime
            self.travelPreferenceModel.maxTime = MaxWalkTimePreferences.allCases[selectedTime]
            preferenceTableView.reloadSections(IndexSet(integer: indexPosition.section), with: .none)
        default:
            break
        }
    }
}

// MARK: - Picker delegate
extension TravelPreferenceViewController: PickerWithDoneButtonDelegate {

    func doneTapped(at index: Int?, value: String?) {
        if let index = index {
            selectedWalkMaxTime = index
            self.travelPreferenceModel.maxTime = MaxWalkTimePreferences.allCases[index]
        }
        hidePicker()
    }

    func tappedOnShadow() {
        hidePicker()
    }
}
