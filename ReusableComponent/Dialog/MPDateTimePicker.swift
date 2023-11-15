//
//  MPDateTimePicker.swift
//  RCRC
//
//  Created by Saheba Juneja on 24/04/23.
//

import UIKit

struct MPDateTimePickerSelection: Encodable {
    var availability: String = Constants.now
    var date: Date = Date()
    var hour: String = ""
    var minute: String = ""
}

class MPDateTimePicker: UIViewController {

    let greenLeft = UIImage(named: "greenPointingLeft")
    let greenRight = UIImage(named: "greenPointingRight")
    let greyLeft = UIImage(named: "greyPointingLeft")
    let greyRight = UIImage(named: "greyPointingRight")
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var arriveByOutlet: UIButton!
    @IBOutlet weak var leaveByOutlet: UIButton!
    @IBOutlet weak var resetNowButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var dateTimePickerSelection = MPDateTimePickerSelection()
    var returnValue: ((_ value: MPDateTimePickerSelection) -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.minimumDate = Date()
        leaveByOutlet.isSelected = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arriveByOutlet.setTitle(Constants.arriveBy.localized, for: .normal)
        leaveByOutlet.setTitle(Constants.leaveBy.localized, for: .normal)
        resetNowButton.setTitle(Constants.resetNow.localized, for: .normal)
        okButton.setTitle(ok.localized, for: .normal)
        cancelButton.setTitle(cancel.localized, for: .normal)
    }
    
    public convenience init(title: String = emptyString) {
        self.init()
        self.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        guard let unwrappedView = loadViewFromNib() else { return }
        self.view = unwrappedView
        
        setSelected(button: leaveByOutlet, isSelected: true)
        dateTimePickerSelection.availability = Constants.leave
        dateTimePickerSelection.minute = timePicker.date.minute.string
        dateTimePickerSelection.hour = timePicker.date.hour.string
        
        setSelected(button: arriveByOutlet, isSelected: false)
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.timeZone = TimeZone(secondsFromGMT: TimeZones.AST.rawValue)
        datePicker.minimumDate = Date()
        //datePicker.maximumDate = Date().adding(days: 7)

        timePicker.locale = Locale(identifier: "en_GB")
        //timePicker.timeZone = TimeZone(secondsFromGMT: TimeZones.AST.rawValue)
        timePicker.minimumDate = Date()
    }

    fileprivate func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: self.classForCoder)
        guard let nib = bundle.loadNibNamed("MPDateTimePicker", owner: self, options: nil) as [AnyObject]? else {
            assertionFailure(Constants.loadingError)
            return nil
        }
        return nib[0] as? UIView
    }
    
    @IBAction func timeSelectedAction(_ sender: UIDatePicker) {
//        timePicker.date = sender.date
        dateTimePickerSelection.hour = timePicker.date.hour.string
        dateTimePickerSelection.minute = timePicker.date.minute.string

        print("Hr: MM" ,"\(dateTimePickerSelection.hour): \(dateTimePickerSelection.minute)")
    }
    @IBAction func dateSelectedAction(_ sender: UIDatePicker) {
        
        setMinimumTime()
        datePicker.date = sender.date
        dateTimePickerSelection.date = datePicker.date
        print(dateTimePickerSelection.date)
    }
    
    @IBAction func okButtonAction(_ sender: Any) {
        returnValue?(dateTimePickerSelection)
    }
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func leaveByAction(_ sender: Any) {
        
        setMinimumTime()
        dateTimePickerSelection.availability = Constants.leave
        leaveByOutlet.isSelected = true
        setSelected(button: leaveByOutlet, isSelected: true)
        
        arriveByOutlet.isSelected = false
        setSelected(button: arriveByOutlet, isSelected: false)
    }
    
    @IBAction func arrivrByAction(_ sender: Any) {
        
        setMinimumTime()
        dateTimePickerSelection.availability = Constants.arrive
        arriveByOutlet.isSelected = true
        setSelected(button: arriveByOutlet, isSelected: true)
        
        leaveByOutlet.isSelected = false
        setSelected(button: leaveByOutlet, isSelected: false)
    }
    
    @IBAction func resetNowButtonAction(_ sender: Any) {
        datePicker.date = Date()
        timePicker.date = Date()
        
        dateTimePickerSelection.availability = Constants.now
        dateTimePickerSelection.date = Date()
        dateTimePickerSelection.hour = ""
        dateTimePickerSelection.minute = ""
        
        leaveByOutlet.isSelected = false
        setSelected(button: leaveByOutlet, isSelected: false)
        
        arriveByOutlet.isSelected = false
        setSelected(button: arriveByOutlet, isSelected: false)
    }
    
    private func setSelected(button: UIButton, isSelected: Bool) {
        if isSelected {
            button.isSelected = true
            if button == leaveByOutlet {
                button.setBackgroundImage(greenLeft?.setNewImageAsPerLanguage(), for: .normal)
            } else {
                button.setBackgroundImage(greenRight?.setNewImageAsPerLanguage(), for: .normal)
            }
            
        } else {
            button.isSelected = false
            if button == leaveByOutlet {
                button.setBackgroundImage(greyLeft?.setNewImageAsPerLanguage(), for: .normal)
            } else {
                button.setBackgroundImage(greyRight?.setNewImageAsPerLanguage(), for: .normal)
            }

        }
    }
    
    private func setMinimumTime() {
        if datePicker.date > Date() {
            timePicker.minimumDate = nil
        } else {
            timePicker.minimumDate = Date()
        }
    }
}
