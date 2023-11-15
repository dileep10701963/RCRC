//
//  DateTimePicker.swift
//  RCRC
//
//  Created by anand madhav on 24/08/20.
//

import Foundation
import UIKit

class DateTimePicker: UIDatePicker {

    func showDateTime(viewController: UIViewController, inputView: UITextField, mode: UIDatePicker.Mode) -> UIDatePicker {
        self.datePickerMode = mode
        self.setDate(Date(), animated: true)
        self.setValue(Colors.green, forKey: Constants.textColor)
        UILabel.swizzleSetFont()
        inputView.inputView = self
        return self
    }
}

public extension UILabel {

    @objc func setFontSwizzled(font: UIFont) {
        if self.shouldOverride() {
            self.setFontSwizzled(font: Fonts.RptaSignage.fifteen!)
        } else {
            self.setFontSwizzled(font: Fonts.RptaSignage.fifteen!)
        }
    }

    private func shouldOverride() -> Bool {
        let classes = [Constants.datePickerTitle, Constants.datePickerViewTitle, Constants.datePickerContentViewTitle]
        var view = self.superview
        while view != nil {
            let className = NSStringFromClass(type(of: view!))
            if classes.contains(className) {
                return true
            }
            view = view!.superview
        }
        return false
    }

    private static let swizzledSetFontImplementation: Void = {
        let instance: UILabel = UILabel()
        let aClass: AnyClass! = object_getClass(instance)
        let originalMethod = class_getInstanceMethod(aClass, #selector(setter: font))
        let swizzledMethod = class_getInstanceMethod(aClass, #selector(setFontSwizzled))

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            // switch implementation..
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    static func swizzleSetFont() {
        _ = self.swizzledSetFontImplementation
    }
    
    func onBoardingHeaderAppearence() {
        self.font = Fonts.CodecBold.thirtyEight
        self.textColor = Colors.rptOnBoardingHeaderTitle
    }
    
    func onBoardingHeaderContentAppearence() {
        self.font = Fonts.CodecRegular.twenty
        self.textColor = Colors.black
    }
}
