//
//  Localizer.swift
//  RCRC
//
//  Created by Errol on 27/07/20.
//

import Foundation
import UIKit

class Localizer: NSObject {

    class func swizzle() {
        swizzleBasedOnClass(cls: Bundle.self, originalSelector: #selector(Bundle.localizedString(forKey:value:table:)), overrideSelector: #selector(Bundle.specialLocalizedStringForKey(key:value:table:)))
        swizzleBasedOnClass(cls: UIApplication.self, originalSelector: #selector(getter: UIApplication.userInterfaceLayoutDirection), overrideSelector: #selector(getter: UIApplication.cstmUserInterfaceLayoutDirection))
    }
}

extension Bundle {

    @objc func specialLocalizedStringForKey(key: String, value: String?, table tableName: String?) -> String {
        let currentLanguage = LanguageService.currentAppLanguage()
        var bundle = Bundle()
        if let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj") {
            bundle = Bundle(path: path)!
        } else {
            let path = Bundle.main.path(forResource: "Base", ofType: "lproj")!
            bundle = Bundle(path: path)!
        }
        return (bundle.specialLocalizedStringForKey(key: key, value: value, table: tableName))
    }
}

func swizzleBasedOnClass(cls: AnyClass, originalSelector: Selector, overrideSelector: Selector) {
    let origMethod: Method = class_getInstanceMethod(cls, originalSelector)!
    let overrideMethod: Method = class_getInstanceMethod(cls, overrideSelector)!
    if class_addMethod(cls, originalSelector, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod)) {
        class_replaceMethod(cls, overrideSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod))
    } else {
        method_exchangeImplementations(origMethod, overrideMethod)
    }
}

extension UIApplication {

    @objc var cstmUserInterfaceLayoutDirection: UIUserInterfaceLayoutDirection {
        var direction = UIUserInterfaceLayoutDirection.leftToRight
        if currentLanguage == .arabic || currentLanguage == .urdu {
            direction = .rightToLeft
        }
        return direction
    }
}
