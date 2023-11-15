//
//  FareMediaBarcodeViewController.swift
//  RCRC
//
//  Created by pcadmin on 29/07/21.
//

import UIKit
import Photos

final class FareMediaBarcodeViewController: ContentViewController {
     @IBOutlet weak var barcode: UIImageView!
     @IBOutlet weak var nameLabel: UILabel!
     @IBOutlet weak var productNameValueLabel: UILabel!
     @IBOutlet weak var costLabel: UILabel!
     @IBOutlet weak var productCostValueLabel: UILabel!
     @IBOutlet weak var validityLabel: UILabel!
     @IBOutlet weak var productValidityValueLabel: UILabel!
     @IBOutlet weak var contentView: UIView!
     @IBOutlet weak var barcodeBackgroundImageView: UIImageView!
     @IBOutlet weak var ticketTypeValueLabel: UILabel!
     @IBOutlet weak var ticketTypeLabel: UILabel!
     @IBOutlet weak var titleLabel: UILabel!
     @IBOutlet weak var scanTicketLabel: UILabel!
     private var viewModel: FareMediaBarcodeViewModel!
     var timerThreshold: Double = 0
     var barcodesArray: [BarcodeTicket] = []
     var currentBarcodeCount: Int {
          set {
               if (newValue >= -1) {
                    if AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
                         UserDefaultService.setBarcodeCounter(value: newValue)
                    } else {
                         UserDefaultService.setBarcodeCounter(value: -1)
                         self.barcodesArray = []
                         UserDefaultService.saveBarcodes(value: Data())
                         UserDefaultService.setBarcodeAvailableForOfflinePurpose(value: false)
                         appDelegate?.mpTimer.invalidate()
                    }
               }
          }
          get {
               return UserDefaultService.getBarcodeCounter()
          }
     }
     
     var timerValue: Double = 30
     @IBOutlet var arrayImageView: [UIImageView]!
     
     @IBOutlet weak var barcodeView: UIView!
     private var barcodeTextField: UITextField = {
          let textField = UITextField()
          textField.isSecureTextEntry = true
          return textField
     }()
     
     private var barcodeSecurityPolicy: UILabel = {
          let label = UILabel()
          label.font = Fonts.RptaSignage.seventeen
          label.textAlignment = .center
          label.numberOfLines = 0
          label.sizeToFit()
          label.textColor = .red
          return label
     }()
     
     static var nibName: String {
          return String(describing: self)
     }
     
     convenience init(product: FareMediaPurchasedProduct) {
          self.init(nibName: FareMediaBarcodeViewController.nibName, bundle: nil)
          self.viewModel = FareMediaBarcodeViewModel(product: product)
     }
     
     override func viewDidLoad() {
          super.viewDidLoad()
          configureNavigationBar(title: viewModel.title.localized)
          //titleLabel.setAlignment()
          titleLabel.text = viewModel.title.localized
          view.addSubview(barcodeSecurityPolicy)
          let bounds = barcode.frame
          barcodeSecurityPolicy.frame = bounds
          if !AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
               currentBarcodeCount = -1
          }
          fetchBarcodes()
          
          displayProductDetails()
          setLabelAlignment()
          self.disableLargeNavigationTitleCollapsing()
          NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: nil) { [weak self] _ in
               self?.showCustomAlert(alertTitle: "", alertMessage: Constants.cantTakeScreenShotTitle.localized, firstActionTitle: proceed.localized, firstActionHandler: {
               })
          }
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          if AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
               self.barcodesArray = fetchTicketsFromUserDefaults()
               updateCurrentCounter()
               displayBarcode()
               startTimer()
          }
          NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
          NotificationCenter.default.addObserver(self, selector: #selector(viewEnterForgroundOnBarcode), name: UIApplication.didBecomeActiveNotification, object: nil)
          UIScreen.main.brightness = 1.0
     }
     
     @objc func viewEnterForgroundOnBarcode() {
          UserDefaultService.setBarcodeView(value: true)
     }
     
     override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          print("WILL DISAPEAR")
          UserDefaultService.setLastVisitTime(value: Date())
          appDelegate?.mpTimer.invalidate()
          UserDefaultService.setBarcodeView(value: false)
          NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
          if UserDefaultService.getBrightness() != "" {
               UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
          }
          NotificationCenter.default.removeObserver(self)
     }
     
     override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)
          makeBarcodeSecure()
          NotificationCenter.default.addObserver(
               self,
               selector: #selector(applicationWillEnterForeground(_:)),
               name: UIApplication.willEnterForegroundNotification,
               object: nil)
     }
     
     func updateCurrentCounter() {
          if AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
               let secondsElapsed = appDelegate?.secondsElapsed ?? 0.0
               let lastDateObserved = UserDefaultService.getLastVisitTime()
               
               var screenNavigationTime: Double = 0
               screenNavigationTime = Date().timeIntervalSince(lastDateObserved ?? Date())
               
               var totalTime: Double = 0
               if secondsElapsed > 0 {
                    totalTime = abs(screenNavigationTime - secondsElapsed)
               } else {
                    totalTime = abs(screenNavigationTime + secondsElapsed)
               }
               
               
               if totalTime > 0 {
                    var threshold = 0
                    threshold = Int(totalTime/30)
                    timerThreshold = totalTime.truncatingRemainder(dividingBy: 30)
                    print("Timer left::::: ", timerThreshold)
                    threshold += currentBarcodeCount
                    let barcodesArray = fetchTicketsFromUserDefaults()
                    if threshold >  barcodesArray.count {
                         currentBarcodeCount = -1
                         self.barcodesArray = []
                    } else {
                         currentBarcodeCount = threshold
                    }
               } else {
                    
               }
          }
          
     }
     
     @objc func applicationWillEnterForeground(_ notification: NSNotification) {
          updateCurrentCounter()
          displayBarcode()
          startTimer()
     }
     
     func handleOfflineScenario() {
          if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
               if fetchTicketsFromUserDefaults().count > 0 {
                    self.barcodesArray = fetchTicketsFromUserDefaults()
                    self.incrementBarcodeCount()
                    self.displayBarcode()
               } else {
                    self.displayBarcode()
               }
          }
     }
     
     private func setLabelAlignment() {
          barcodeView.semanticContentAttribute = .forceLeftToRight
          nameLabel.attributedText = NSMutableAttributedString(string: Constants.name.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.black, .font: Fonts.CodecBold.twelve])
          validityLabel.attributedText = NSMutableAttributedString(string: Constants.validUntil.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.black, .font: Fonts.CodecBold.twelve])
          costLabel.attributedText = NSMutableAttributedString(string: Constants.price.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.black, .font: Fonts.CodecBold.twelve])
          ticketTypeLabel.attributedText = NSMutableAttributedString(string: Constants.ticketType.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.black, .font: Fonts.CodecBold.twelve])
          let paragraphStyle = NSMutableParagraphStyle()
          paragraphStyle.lineSpacing = 5
          scanTicketLabel.attributedText = NSMutableAttributedString(string: Constants.ScanYourTicket.localized, attributes: [NSAttributedString.Key.foregroundColor: Colors.textGray, .font: Fonts.CodecRegular.thirteen, .paragraphStyle: paragraphStyle])
          scanTicketLabel.textAlignment = .center
          
//          for (index, imageView) in arrayImageView.enumerated() {
//               arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
//          }
     }
     
     private func makeBarcodeSecure() {
          
          view.addSubview(barcodeTextField)
          barcodeTextField.delegate = self
          barcodeTextField.frame = barcode.bounds
          barcodeTextField.backgroundColor = .clear
          self.barcodeTextField.layer.sublayers?.first?.addSublayer(self.contentView.layer)
     }
     
     func displayBarcode() {
          if self.currentBarcodeCount >= 0 && self.currentBarcodeCount < barcodesArray.count {
               guard let rawBytes = self.barcodesArray[self.currentBarcodeCount].rawBytes else { return }
               print("RAW BYTE ---> ",self.barcodesArray[self.currentBarcodeCount].rawBytes ?? "",self.currentBarcodeCount )
               DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.barcode.image = self.generateQuickResponseCode(for: rawBytes) ?? UIImage()
               }
          } else {
               if isOffline {
                    DispatchQueue.main.async {
                         //self.barcode.image = self.generateQuickResponseCode(for: "") ?? UIImage()
                    }
               }
          }
     }
     
     func incrementBarcodeCount() {
          currentBarcodeCount = currentBarcodeCount + 1
          UserDefaultService.setBarcodeCounter(value: currentBarcodeCount)
          if currentBarcodeCount >= barcodesArray.count && !isOffline {
               currentBarcodeCount = -1
               UserDefaultService.setBarcodeAvailableForOfflinePurpose(value: false)
               appDelegate?.mpTimer.invalidate()
               barcodesArray = []
               UserDefaultService.saveBarcodes(value: Data())
               fetchBarcodes()
          }
     }
     
     
     private func fetchBarcodes() {
          fetchBarcode { barcodes in
               UserDefaultService.setBarcodeFetchTime(value: Date())
               let fetchDateTime = UserDefaultService.getBarcodeFetchTime()
               
               UserDefaultService.setTimeOfLastBarcode(value: fetchDateTime.adding(seconds: 300))
               
               if self.currentBarcodeCount == -1 {
                    self.incrementBarcodeCount()
                    self.displayBarcode()
               } else {
                    self.updateCurrentCounter()
                    self.displayBarcode()
               }
               self.startTimer()
          }
     }
     
     private func startTimer() {
          if let timer = appDelegate?.mpTimer {
               timer.invalidate()
          }
          
          appDelegate?.mpTimer = Timer.scheduledTimer(withTimeInterval:timerValue - timerThreshold, repeats: true) { _ in
               self.incrementBarcodeCount()
               self.displayBarcode()
               if self.timerThreshold > 0 && !isOffline {
                    self.timerThreshold = 0
                    appDelegate?.secondsElapsed = 0
                    appDelegate?.mpTimer.invalidate()
                    self.startTimer()
               }
          }
     }
     
     private func fetchBarcode(completion: @escaping ([BarcodeTicket]) -> Void) {
          if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
               self.handleOfflineScenario()
               return
          }
          
          if currentBarcodeCount == -1 {
               DispatchQueue.main.async {
                    self.barcode.startShimmering()
               }
               viewModel.getBarcodes { [weak self] (result) in
                    self?.resetAllUserDefaultTimestamps()
                    DispatchQueue.main.async {
                         switch result {
                         case let .success(barcodesModel):
                              self?.convertAndSaveObjectInDataStringFormat(eTicket: barcodesModel)
                              self?.barcodesArray = self?.fetchTicketsFromUserDefaults() ?? []
                              UserDefaultService.setBarcodeAvailableForOfflinePurpose(value: true)
                              
                              DispatchQueue.main.async {
                                   self?.barcode.stopShimmering()
                              }
                              completion(barcodesModel.items ?? []
                              )
                         case .failure:
                              self?.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                                                    alertMessage: Constants.serverErrorAlertMessage.localized,
                                                    firstActionTitle: ok,
                                                    firstActionHandler: {
                                   self?.navigationController?.popViewController(animated: true)
                              })
                         }
                    }
               }
          } else {
               self.barcodesArray = fetchTicketsFromUserDefaults()
               completion(self.barcodesArray)
          }
     }
     
     private func generateQuickResponseCode(for string: String) -> UIImage? {
          if let filter = CIFilter(name: Constants.aztecQRCodeFormat) {
               filter.setValue(Data(string.utf8), forKey: Constants.qrCodeFilterKey)
               let transform = CGAffineTransform(scaleX: 3, y: 3)
               if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
               }
          }
          return nil
     }
     
     private func displayProductDetails() {
          barcodeBackgroundImageView.image = UIImage(named: "barcodeBackground")
          ticketTypeValueLabel.text = viewModel.productTicketType.localized
          productNameValueLabel.text = viewModel.productName.localized
          productCostValueLabel.text = viewModel.productCost.localized
          productValidityValueLabel.text = viewModel.validity.localized
     }
}

extension FareMediaBarcodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension FareMediaBarcodeViewController {
     func convertAndSaveObjectInDataStringFormat(eTicket: ETicket) {
          let encoder = JSONEncoder()
          if let encoded = try? encoder.encode(eTicket) {
               UserDefaultService.saveBarcodes(value: encoded)
          }
     }
     
     func fetchTicketsFromUserDefaults()-> [BarcodeTicket] {
          let decoder = JSONDecoder()
          if let encoded = UserDefaultService.getBarcodes() {
               if let decoded = try? decoder.decode(ETicket.self, from: encoded) {
                    return decoded.items ?? []
               }
          }
          return []
     }
     
     func resetAllUserDefaultTimestamps() {
          UserDefaultService.setBarcodeCounter(value: -1)
          UserDefaultService.setUserWentForeground(value: nil)
          UserDefaultService.setUserWentBackground(value: nil)
          UserDefaultService.setLastVisitTime(value: nil)
     }
     
}

