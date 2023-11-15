//
//  MPDatePickerViewController.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 18/05/23.
//

import UIKit

struct MPDatePickerSelection: Decodable {
    var date: Date = Date()
}

class MPDatePickerViewController: UIViewController {
    let greenLeft = UIImage(named: "greenPointingLeft")
    let greenRight = UIImage(named: "greenPointingRight")
    let greyLeft = UIImage(named: "greyPointingLeft")
    let greyRight = UIImage(named: "greyPointingRight")
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var cancelButton: UIButton!
    var datePickerSelection = MPDatePickerSelection()
    var returnValue: ((_ value: MPDatePickerSelection) -> ())?
    var startDate = Date()
    
    public convenience init(title: String = emptyString, startDate:Date) {
        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.timeZone = TimeZone(secondsFromGMT: TimeZones.AST.rawValue)
        datePicker.minimumDate = self.startDate
        datePicker.maximumDate = Date()
        self.startDate = startDate
    }
    
    fileprivate func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed("MPDatePickerViewController", owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.minimumDate = self.startDate
        datePicker.maximumDate = Date()
        datePicker.timeZone = TimeZone(secondsFromGMT: TimeZones.AST.rawValue)
        okButton.setTitle(ok.localized, for: .normal)
        cancelButton.setTitle(cancel.localized, for: .normal)
    }
    
    @IBAction func dateSelectedAction(_ sender: UIDatePicker) {
        /*print("datePicker: \(sender.date)")
        print("startDate datePicker: \(self.startDate)")*/

        /*let dateValue = sender.date
        let timeIntval = self.startDate.timeIntervalSince(dateValue)
        print("timeIntval : \(timeIntval)")
        let latestDate = sender.date.addingTimeInterval(timeIntval)
        print("latestD : \(latestDate)")*/
        
        datePicker.date = sender.date//
        datePickerSelection.date = datePicker.date
        print("datePickerSelection d: \(datePickerSelection.date)")
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        returnValue?(datePickerSelection)
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
