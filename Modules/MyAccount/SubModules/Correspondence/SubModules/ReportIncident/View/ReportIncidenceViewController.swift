//
//  ReportIncidence.swift
//  RCRC
//
//  Created by anand madhav on 05/08/20.
//

import UIKit
import MessageUI
import MobileCoreServices
import AVFoundation

enum ReportIncidentFields {
    case type, subType
}

enum ReportIncidenceViewControllerNumberConstant {
    static let pickerHeight = 300
    static let toolBarHeight = 50
    static let tagOne = 1
    static let tagTwo = 2
    static let tagFive = 5
    static let tagNine = 9
    static let tagFourteen = 14
}

class ReportIncidenceViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, UITextViewDelegate {
    var uploadFiles: [UploadProgress] = [] {
        didSet {
            if uploadFiles.count < 3 {
                visibleImagesCount = uploadFiles.count + 1
            } else {
                visibleImagesCount = 3
            }
        }
    }
    let imagePickerController = UIImagePickerController()
    private var mediaPicker: MediaPickerController!
    @IBOutlet weak var viewIncidentFirst: UIView!
    @IBOutlet weak var viewIncidentSecond: UIView!
    @IBOutlet weak var viewIncidentThird: UIView!
    @IBOutlet var incidenceTypeButton: UIButton!
    @IBOutlet var incidencePlaceButton: UIButton!
    @IBOutlet var descriptionLabel: LocalizedLabel!
    @IBOutlet var attachmentLabel: LocalizedLabel!
    @IBOutlet var textview: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var incidenceDate: ReportTextField!
    @IBOutlet weak var incidentSubtype: UIView!
    @IBOutlet weak var incidentSubtypeButton: UIButton!
    @IBOutlet var reportButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var selectedTag = 0
    var attachmentID = ""
    var toolBar = UIToolbar()
    let viewModel = ReportIncidenceViewModel()
    var activityIndicator: UIActivityIndicatorView?
    var attachmentFileSize = 0.00
    let reportIncidenceViewModel = ReportIncidenceModel()
    var incidencePicker = UIPickerView()
    var placePicker = UIPickerView()
    var isPlacePickerSelected = true
    private var selectedIndex = -1

    var picker: PickerWithDoneButton?
    var selectedField: ReportIncidentFields?
    private var reportData = IncidentModel()
    private var currentLocationOverlay: CurrentLocationOverlay?
    private var datePicker = UIDatePicker()

    @IBOutlet weak var multimediaCollectionView: UICollectionView!
    private var visibleImagesCount = 1
    private var selectedImageIndex = -1
    private var selected: (Int, Int) = (-1, -1)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.reportAnIncident.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .reportIncidence)
        let attributedString = NSMutableAttributedString(string: "By clicking on ‘Report’, you acknowledge having read our Privacy notice and consent to receive additional information.".localized, attributes: [.font: Fonts.RptaSignage.twelve!])
        attributedString.addAttribute(.foregroundColor,
                                      value: Colors.green,
                                      range: NSRange(location: "By clicking on ‘Report’, you acknowledge having read our ".count,
                                                     length: "Privacy notice".count))
        setUpAlignment()
        setUpUI()
        bindUI()
        textview.attributedText = attributedString
        descriptionTextView.delegate = self
        descriptionTextView.addDoneButton(self, selector: #selector(descriptionDoneTapped))
        textview.setAlignment()
        descriptionTextView.setAlignment()
        incidenceTypeButton.setContentHorizontalAlignment()
        incidentSubtypeButton.setContentHorizontalAlignment()
        incidencePlaceButton.setContentHorizontalAlignment()
        incidenceDate.configure(text: "When did this incident happen?".localized, rightImage: Images.calendar)
        incidenceDate.backgroundColor = .white
        incidenceDate.tag = 1
        incidenceDate.reportDelegate = self
        self.disableLargeNavigationTitleCollapsing()
    }

    private func reset() {
        selectedIndex = -1
        reportData = IncidentModel()
        visibleImagesCount = 1
        uploadFiles.removeAll()
        selectedImageIndex = -1
        selected = (-1, -1)
        incidenceTypeButton.setTitle(Constants.incidentCategory.localized, for: .normal)
        incidencePlaceButton.setTitle("Where did the incident happen?".localized, for: .normal)
        incidenceDate.configure(text: "When did this incident happen?".localized, rightImage: Images.calendar)
        incidentSubtypeButton.setTitle("Select Sub Type".localized, for: .normal)
        descriptionLabel.text = Constants.incidentDescription.localized
        DispatchQueue.main.async {
            self.multimediaCollectionView.reloadData()
        }
    }

    @objc private func descriptionDoneTapped() {
        descriptionTextView.resignFirstResponder()
    }

    func setUpAlignment() {
        incidenceTypeButton.setAlignment()
        incidencePlaceButton.setAlignment()
        descriptionLabel.setAlignment()
        attachmentLabel.setAlignment()
        textview.setAlignment()
    }

    func setUpUI() {
        reportIncidenceViewModel.addShadowForView(views: [viewIncidentFirst, viewIncidentSecond, viewIncidentThird, incidentSubtype])
        incidenceTypeButton.setTitle(Constants.incidentCategory.localized, for: .normal)
        descriptionLabel.text = Constants.incidentDescription.localized
        attachmentLabel.text = Constants.incidentAttachmentLabel.localized
        reportButton.setTitle(Constants.report.localized, for: .normal)
        mediaPicker = MediaPickerController(viewController: self)
        incidencePlaceButton.setTitleColor(.black, for: .normal)

        descriptionTextView.textColor = Colors.textGray
        descriptionTextView.text = "Description of the incident".localized
        descriptionTextView.delegate = self
        descriptionTextView.tintColor = Colors.green
        descriptionTextView.setAlignment()

        multimediaCollectionView.backgroundColor = Colors.backgroundGray
        multimediaCollectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        multimediaCollectionView.dataSource = self
        multimediaCollectionView.delegate = self
        multimediaCollectionView.allowsSelection = true
    }

    func bindUI() {
        viewModel.isSentMail.bind { isSent in
            guard let isSent = isSent else {return}
            self.activityIndicator?.stopAnimating()
            self.enableUserInteractionWhenAPICalls()
            self.showCustomAlert(alertTitle: Constants.emailStatus, alertMessage: isSent ? Constants.emailSuccess : Constants.emailFailed, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                self.navigationController?.popViewController(animated: true)
            })
        }
        viewModel.upLoadProgress.bind { progressDetails in
            guard let progressDetails = progressDetails else {return}
            let indexPath = IndexPath(item: progressDetails.index ?? 0, section: 0)
            guard let cell: ImageCollectionViewCell = self.multimediaCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {return}
            let val = (progressDetails.progress ?? 0.00)
            DispatchQueue.main.async {
                cell.uploadImageProgressBar.setProgress(Float(val), animated: true)
                var file = self.uploadFiles[safe :progressDetails.index ?? 0]
                file?.progress = Float(val)
                if let file = file {
                    self.uploadFiles[progressDetails.index ?? 0] = file
                }
            }
        }
        viewModel.uploadStatus.bind { uploadStatus in
            guard let uploadStatus = uploadStatus else {return}
            let indexPath = IndexPath(item: uploadStatus.index ?? 0, section: 0)
            guard let cell: ImageCollectionViewCell = self.multimediaCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {return}
            if uploadStatus.hasUploaded {
                DispatchQueue.main.async {
                    var file = self.uploadFiles[uploadStatus.index ?? 0]
                    file.hasUploaded = true
                    self.uploadFiles[uploadStatus.index ?? 0] = file
                    cell.uploadImageProgressBar.isHidden = true
                    cell.deleteButton.isHidden = false
                }
            } else {
                self.uploadFiles.remove(at: (uploadStatus.index ?? 0))
                DispatchQueue.main.async {
                    self.showToast("Upload file failed")
                    self.multimediaCollectionView.reloadData()
                }
            }
        }
    }

    private func showDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateSelected))
        toolbar.setItems([doneButton], animated: true)
        incidenceDate.inputAccessoryView = toolbar
        incidenceDate.inputView = datePicker
    }

    @objc private func dateSelected() {
        let selectedDate = datePicker.date.toString(withFormat: Date.dateTime, timeZone: .AST)
        incidenceDate.text = selectedDate
        reportData.date = selectedDate
        self.view.endEditing(true)
    }

    @IBAction func sendButtonTapped(_ sender: UIButton) {

        if let type = reportData.type,
           let subType = reportData.subType,
           let location = reportData.location,
           let description = reportData.description {
            let request = SendEmailRequest(from: "testing@gmail.com", to: "noreply.rcrc@gmail.com", subject: "Incidence - \(type) - \(subType)", contentType: "text/html", content: "Place of Incidence: \(location.address ?? emptyString)\nDate: \(reportData.date ?? emptyString)\nDescription: \(description)", attachmentId: "")
            viewModel.emailSendRequest = request
            if viewModel.attachmentIDs.count == self.uploadFiles.count {
                if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                    return
                }
                activityIndicator = self.startActivityIndicator()
                self.disableUserInteractionWhenAPICalls()
                viewModel.performSendEmailRequest()
            } else {
                self.showCustomAlert(alertTitle: Constants.allFieldsRequired.localized, alertMessage:
                                        Constants.uploadingAttachment, firstActionTitle: ok, firstActionStyle: .default)
            }
        } else {
            self.showCustomAlert(alertTitle: "All fields are required".localized, alertMessage: "Please enter all the required information and try again".localized, firstActionTitle: ok, firstActionStyle: .default)
        }
    }

    private func configurePicker() {
        self.picker?.delegate = self
        self.view.addSubview(self.picker ?? UIView())
        self.picker?.pinEdgesToSuperView()
        self.picker?.viewHeight = self.view.bounds.height - 200
    }

    private func hidePicker() {
        self.picker?.removeFromSuperview()
    }

    @IBAction func showPickerView(_ sender: UIButton) {
        switch sender.tag {
        case ReportIncidenceViewControllerNumberConstant.tagOne:
            isPlacePickerSelected = false
            selectedField = .type
            picker = PickerWithDoneButton(pickerData: complaints.map {$0.category}, selected: selected.0)
            configurePicker()
        case ReportIncidenceViewControllerNumberConstant.tagTwo:
            let viewController = StopSelectionViewController(nibName: "StopSelectionViewController", bundle: nil)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        case 5:
            isPlacePickerSelected = false
            guard self.selectedIndex != -1 else { return }
            selectedField = .subType
            picker = PickerWithDoneButton(pickerData: complaints[selectedIndex].subCategory, selected: selected.1)
            configurePicker()
        default:
            break
        }
    }

    @IBAction func locationButtonTapped(_ sender: UIButton) {
        currentLocationOverlay = CurrentLocationOverlay()
        currentLocationOverlay?.delegate = self
        self.view.addSubview(currentLocationOverlay ?? UIView())
        currentLocationOverlay?.pinEdgesToSuperView()
    }

    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        placePicker.removeFromSuperview()
        incidencePicker.removeFromSuperview()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.textGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.textColor == .black, textView.text.isEmpty {
            textView.text = "Description of the incidenct".localized
            textView.textColor = Colors.textGray
        } else {
            reportData.description = textView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let textViewText = textView.text, let textRange = Range(range, in: textViewText) {
            let updatedText = textViewText.replacingCharacters(in: textRange, with: text)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
    
}

extension ReportIncidenceViewController: PickerWithDoneButtonDelegate {

    func doneTapped(at index: Int?, value: String?) {
        hidePicker()
        switch selectedField {
        case .type:
            incidenceTypeButton.setTitle(value?.localized ?? incidenceTypeButton.currentTitle, for: .normal)
            reportData.type = value?.localized
            self.selectedIndex = index ?? -1
            selected.0 = index ?? -1
            selected.1 = -1
        case .subType:
            incidentSubtypeButton.setTitle(value?.localized ?? incidentSubtypeButton.currentTitle, for: .normal)
            reportData.subType = value?.localized
            selected.1 = index ?? -1
        default:
            break
        }
    }

    func tappedOnShadow() {
        hidePicker()
    }
}

extension ReportIncidenceViewController: ReportLocationSelectionDelegate {

    func didSelectLocation(_ stopFinderLocation: Location) {
        incidencePlaceButton.setTitle(stopFinderLocation.name, for: .normal)
        reportData.location = SelectedLocation(address: stopFinderLocation.name,
                                               latitude: stopFinderLocation.coord?[0],
                                               longitude: stopFinderLocation.coord?[1])
    }

    func didSelectLocation(_ mapLocation: MapLocation) {
        incidencePlaceButton.setTitle(mapLocation.address, for: .normal)
        reportData.location = SelectedLocation(address: mapLocation.address,
                                               latitude: mapLocation.latitude,
                                               longitude: mapLocation.longitude)
    }
}

extension ReportIncidenceViewController: CurrentLocationOverlayDelegate {

    func shadowTapped() {
        currentLocationOverlay?.removeFromSuperview()
    }

    func yourCurrentLocationTapped() {
        let locationManager = LocationManager.SharedInstance
        locationManager.startUpdatingLocation()
        locationManager.updateCurrentLocation = { location in
            guard let location = location else { return }
            GoogleApiHelper.SharedInstance.fetchFormattedAddress(from: "\(location.coordinate.latitude),\(location.coordinate.longitude)") { (results) in
                if let result = results?.results?.first {
                    self.incidencePlaceButton.setTitle(result.formattedAddress, for: .normal)
                    self.reportData.location = SelectedLocation(address: result.formattedAddress,
                                                                latitude: location.coordinate.latitude,
                                                                longitude: location.coordinate.longitude)
                }
            }
        }
        currentLocationOverlay?.removeFromSuperview()
    }

    func selectLocationOnMapTapped() {
        let viewController = MapLocationSelectionViewController(nibName: "MapLocationSelectionViewController", bundle: nil)
        viewController.delegate = self
        self.present(viewController, animated: true)
        currentLocationOverlay?.removeFromSuperview()
    }
}

extension ReportIncidenceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if uploadFiles.isEmpty {
            return 1
        } else {
            return uploadFiles.count + 1
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell
        cell?.cellView.borderColor = .darkGray
        if uploadFiles.isEmpty {
            let upload  = UploadProgress(progress: nil, index: nil, image: Images.addNewFile)
            cell?.configure(with: upload)
        } else {
            if indexPath.row == uploadFiles.count {
                let upload  = UploadProgress(progress: nil, index: nil, image: Images.addNewFile)
                cell?.configure(with: upload)
            } else {
                cell?.configure(with: uploadFiles[safe: indexPath.row], delete: {
                    self.deleteImage(at: indexPath.row)
                })
            }
        }
        return cell ?? UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                cell.cellView.borderColor = Colors.green
            } completion: { (_) in
                UIView.animate(withDuration: 0.5) {
                    cell.cellView.borderColor = .darkGray
                }
            }
        }
        mediaPicker.loadMedia(completion: handleMediaSelection)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let totalCellWidth = 90 * (visibleImagesCount)
        let totalSpacingWidth = 20 * (visibleImagesCount - 1)
        let leftInset = (collectionView.bounds.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
    }

    private func deleteImage(at index: Int) {
        self.uploadFiles.remove(at: index)
        self.viewModel.attachmentIDs.remove(at: index)
        multimediaCollectionView.reloadData()
    }

    private func handleMediaSelection(media: Media) {
        switch media {
        case let .image(image):
            handleImageSelection(image: image)
        case let .video(video, thumbnail):
            handleVideoSelection(video: video, thumbnail: thumbnail)
        }
    }

    private func handleImageSelection(image: UIImage) {
        reportData.images.append(image)
        let upload = UploadProgress(progress: 0.0, index: uploadFiles.count, image: image, hasUploaded: false)
        self.uploadFiles.append(upload)
        self.multimediaCollectionView.reloadData()
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let uploadRequest = FileUploadRequest(fileName: "Image-File\(String(describing: (uploadFiles.count - 1)))", fileContent: image.convertToBase64String())
        viewModel.performFileUploadRequest(request: uploadRequest, index: (uploadFiles.count - 1))
    }

    private func handleVideoSelection(video: NSData, thumbnail: UIImage) {
        reportData.videos.append(video)
        let upload = UploadProgress(progress: 0.0, index: uploadFiles.count, image: thumbnail, hasUploaded: false)
        self.uploadFiles.append(upload)
        self.multimediaCollectionView.reloadData()
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let uploadRequest = FileUploadRequest(fileName: "Video-File\(String(describing: uploadFiles.count - 1))", fileContent: video.convertToBase64String() )
        viewModel.performFileUploadRequest(request: uploadRequest, index: uploadFiles.count - 1)
    }
}

extension ReportIncidenceViewController: SuccessViewDelegate {

    func didTapProceed() {
        reset()
    }
}

extension ReportIncidenceViewController: ReportTextFieldDelegate {

    func reportTextField(_ textField: UITextField) {
        if textField == incidenceDate {
            showDatePicker()
        }
    }
}
