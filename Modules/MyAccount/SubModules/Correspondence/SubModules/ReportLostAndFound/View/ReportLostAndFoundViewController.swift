//
//  ReportLostAndFoundViewController.swift
//  RCRC
//
//  Created by Errol on 26/04/21.
//

import UIKit
import MessageUI
import MobileCoreServices
import AVFoundation

class ReportLostAndFoundViewController: UIViewController {

    @IBOutlet weak var lostOrFoundTextField: ReportTextField!
    @IBOutlet weak var category: ReportTextField!
    @IBOutlet weak var subCategory: ReportTextField!
    @IBOutlet weak var location: ReportTextField!
    @IBOutlet weak var date: ReportTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var attachPhotosLabel: UILabel!
    @IBOutlet weak var privacyNoticeLabel: UILabel!
    @IBOutlet weak var multimediaCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    var attachmentFileSize = 0.00
    var activityIndicator: UIActivityIndicatorView?
    let viewModel = ReportIncidenceViewModel()
    var uploadFiles: [UploadProgress] = [] {
        didSet {
            if uploadFiles.count < 3 {
                visibleImagesCount = uploadFiles.count + 1
            } else {
                visibleImagesCount = 3
            }
        }
    }
    var picker: PickerWithDoneButton?
    private var mediaPicker: MediaPickerController!
    private var selectedIndex = -1
    private var selectedTextField: ReportTextField?
    private var datePicker = UIDatePicker()
    private var currentLocationOverlay: CurrentLocationOverlay?
    private var reportData = LostAndFoundModel()
    private var visibleImagesCount = 1
    private var selectedImageIndex = -1
    // 0 - Lost or Found
    // 1 - Category
    // 2 - Sub Category
    private var selected: (Int, Int, Int) = (0, -1, -1)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .reportLostAndFound)
        configureNavigationBar(title: "Report Lost and Found".localized)
        bindUI()
        configureView()
        configureDelegates()
        self.disableLargeNavigationTitleCollapsing()
    }

    private func configureView() {
        lostOrFoundTextField.configure(text: "I have lost an Item".localized, rightImage: Images.downArrow)
        category.configure(text: "Select Item Category".localized, rightImage: Images.downArrow)
        subCategory.configure(text: "Select Item Sub Category".localized, rightImage: Images.downArrow)
        location.configure(text: "Where did this incident happen?".localized, rightImage: Images.currentLocationMarker)
        date.configure(text: "When did this incident happen?".localized, rightImage: Images.calendar)

        descriptionTextView.textColor = Colors.textGray
        descriptionTextView.text = "Description of the lost/found item".localized
        descriptionTextView.delegate = self
        descriptionTextView.tintColor = Colors.green
        descriptionTextView.setAlignment()

        attachPhotosLabel.setAlignment()
        privacyNoticeLabel.setAlignment()

        let attributedString = NSMutableAttributedString(string: "By clicking on ‘Report’, you acknowledge having read our Privacy notice and consent to receive additional information.".localized)
        attributedString.addAttribute(.foregroundColor, value: Colors.green, range: NSRange(location: "By clicking on ‘Report’, you acknowledge having read our ".count, length: "Privacy notice".count))
        privacyNoticeLabel.attributedText = attributedString

        multimediaCollectionView.register(ImageCollectionViewCell.nib, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        multimediaCollectionView.dataSource = self
        multimediaCollectionView.delegate = self
        multimediaCollectionView.allowsSelection = true
        descriptionTextView.addDoneButton(self, selector: #selector(descriptionDoneTapped))
        reportData.type = "I have lost an Item".localized
    }

    private func reset() {
        selectedIndex = -1
        reportData = LostAndFoundModel()
        visibleImagesCount = 1
        uploadFiles.removeAll()
        selectedImageIndex = -1
        selected = (0, -1, -1)
        lostOrFoundTextField.configure(text: "I have lost an Item".localized, rightImage: Images.downArrow)
        category.configure(text: "Select Item Category".localized, rightImage: Images.downArrow)
        subCategory.configure(text: "Select Item Sub Category".localized, rightImage: Images.downArrow)
        location.configure(text: "Where did this incident happen?".localized, rightImage: Images.currentLocationMarker)
        date.configure(text: "When did this incident happen?".localized, rightImage: Images.calendar)
        descriptionTextView.text = "Description of the lost/found item".localized
        reportData.type = "I have lost an Item".localized
        DispatchQueue.main.async {
            self.multimediaCollectionView.reloadData()
        }
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
            print("PROGRESS----------> \(progressDetails?.progress ?? 0.0)")
            guard let progressDetails = progressDetails else {return}
            let indexPath = IndexPath(item: progressDetails.index ?? 0, section: 0)
                guard let cell: ImageCollectionViewCell = self.multimediaCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else {return}
            let val = (progressDetails.progress ?? 0.00)
            DispatchQueue.main.async {
                cell.uploadImageProgressBar.setProgress(Float(val), animated: true)
                var file = self.uploadFiles[safe: progressDetails.index ?? 0]
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
                }
            } else {
                self.uploadFiles.remove(at: (uploadStatus.index ?? 0))
                DispatchQueue.main.async {
                    self.multimediaCollectionView.reloadData()
                }
            }
        }
    }

    @objc private func descriptionDoneTapped() {
        descriptionTextView.resignFirstResponder()
    }

    private func configureDelegates() {
        lostOrFoundTextField.reportDelegate = self
        category.reportDelegate = self
        subCategory.reportDelegate = self
        location.reportDelegate = self
        date.reportDelegate = self
        mediaPicker = MediaPickerController(viewController: self)
    }

    @IBAction func reportTapped(_ sender: UIButton) {
        descriptionTextView.resignFirstResponder()
        if let reportType = reportData.type,
           let category = reportData.category,
           let subCategory = reportData.subCategory,
           let location = reportData.location,
           let date = reportData.date,
           let description = reportData.description {
            let request = SendEmailRequest(from: "testing@gmail.com", to: "noreply.rcrc@gmail.com", subject: "Lost and Found - \(reportType) - \(category)", contentType: "text/html", content: "Sub Category: \(subCategory)\nPlace of Incidence: \(location.address ?? emptyString)\nDate of Incidence: \(date)\nDescription: \(description)", attachmentId: "")
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

    private func showDatePicker() {
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateSelected))
        toolbar.setItems([doneButton], animated: true)
        date.inputAccessoryView = toolbar
        date.inputView = datePicker
    }

    @objc private func dateSelected() {
        let selectedDate = datePicker.date.toString(withFormat: Date.dateTime, timeZone: .AST)
        date.text = selectedDate
        reportData.date = selectedDate
        self.view.endEditing(true)
    }
}

// MARK: - TextField delegate
extension ReportLostAndFoundViewController: ReportTextFieldDelegate {

    func reportTextField(_ textField: UITextField) {
        switch textField {
        case lostOrFoundTextField:
            self.selectedTextField = lostOrFoundTextField
            self.picker = PickerWithDoneButton(pickerData: ["I have lost an Item".localized, "I have found an Item".localized], selected: selected.0)
            configurePicker()
        case category:
            self.selectedTextField = category
            self.picker = PickerWithDoneButton(pickerData: lostAndFound.map({$0.category}), selected: selected.1)
            configurePicker()
        case subCategory:
            guard selectedIndex != -1 else { return }
            self.selectedTextField = subCategory
            self.picker = PickerWithDoneButton(pickerData: lostAndFound[selectedIndex].subCategory, selected: selected.2)
            configurePicker()
        case location:
            let viewController = StopSelectionViewController(nibName: "StopSelectionViewController", bundle: nil)
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        case date:
            showDatePicker()
        default:
            break
        }
    }

    func reportTextFieldLocationButtonTapped() {
        currentLocationOverlay = CurrentLocationOverlay()
        currentLocationOverlay?.delegate = self
        self.view.addSubview(currentLocationOverlay ?? UIView())
        currentLocationOverlay?.pinEdgesToSuperView()
    }
}

// MARK: - Picker delegate
extension ReportLostAndFoundViewController: PickerWithDoneButtonDelegate {

    func doneTapped(at index: Int?, value: String?) {
        hidePicker()
        self.selectedTextField?.text = value?.localized ?? selectedTextField?.text
        switch self.selectedTextField {
        case lostOrFoundTextField:
            reportData.type = value?.localized ?? lostOrFoundTextField.text
            selected.0 = index ?? -1
            selected.1 = -1
            selected.2 = -1
        case category:
            reportData.category = value?.localized
            self.selectedIndex = index ?? -1
            selected.1 = index ?? -1
            selected.2 = -1
        case subCategory:
            reportData.subCategory = value?.localized
            selected.2 = index ?? -1
        default:
            break
        }
    }

    func tappedOnShadow() {
        hidePicker()
    }
}

// MARK: - Location selection delegate
extension ReportLostAndFoundViewController: ReportLocationSelectionDelegate {

    func didSelectLocation(_ stopFinderLocation: Location) {
        location.text = stopFinderLocation.name
        reportData.location = SelectedLocation(address: stopFinderLocation.name,
                                               latitude: stopFinderLocation.coord?[0],
                                               longitude: stopFinderLocation.coord?[1])
    }

    func didSelectLocation(_ mapLocation: MapLocation) {
        location.text = mapLocation.address
        reportData.location = SelectedLocation(address: mapLocation.address,
                                               latitude: mapLocation.latitude,
                                               longitude: mapLocation.longitude)
    }
}

// MARK: - TextView Delegate
extension ReportLostAndFoundViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.textGray {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.textColor == .black, textView.text.isEmpty {
            textView.text = "Description of the lost/found item".localized
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

// MARK: - Location overlay delegate
extension ReportLostAndFoundViewController: CurrentLocationOverlayDelegate {

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
                    self.location.text = result.formattedAddress
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

// MARK: - Email Delegate
extension ReportLostAndFoundViewController: MFMailComposeViewControllerDelegate {

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        guard error == nil else {
            self.dismiss(animated: true)
            return
        }
        switch result {
        case .saved:
            self.showToast("Email saved in Drafts".localized)
        case .sent:
            self.showToast("Email sent successfully".localized)
            let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
            viewController.headerText = "Report Submitted".localized
            viewController.descriptionText = "Your report has been submitted. You will receive a notification when a response is received".localized
            viewController.proceedButtonText = done
            viewController.modalPresentationStyle = .fullScreen
            viewController.modalTransitionStyle = .crossDissolve
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        case .failed:
            self.showToast("Unable to send email. Please try again.".localized)
        case .cancelled:
            break
        @unknown default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}

 // MARK: - Multimedia view implementation
 extension ReportLostAndFoundViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
                cell?.configure(with: uploadFiles[indexPath.row], delete: {
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
        uploadFiles.remove(at: index)
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

 extension ReportLostAndFoundViewController: SuccessViewDelegate {

    func didTapProceed() {
        reset()
    }
 }
