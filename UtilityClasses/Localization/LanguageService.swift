//
//  LanguageService.swift
//  RCRC
//
//  Created by Errol on 27/07/20.
//

import Foundation

var currentLanguage: Languages {
    return Languages(rawValue: LanguageService.currentAppLanguage()) ?? .english
}

class LanguageService {

    // MARK: - Get current application language
    class func currentAppLanguage() -> String {
        let userdef = UserDefaults.standard
        let langArray = (userdef.object(forKey: Keys.appleLanguageKey) as? NSArray) ?? []
        let current = (langArray.firstObject as? String ?? "")
        return current
    }

    // MARK: - Set current application language
    class func setAppLanguageTo(lang: String) {
        let userdef = UserDefaults.standard
        userdef.set([lang, currentAppLanguage()], forKey: Keys.appleLanguageKey)
        userdef.synchronize()
    }
}
