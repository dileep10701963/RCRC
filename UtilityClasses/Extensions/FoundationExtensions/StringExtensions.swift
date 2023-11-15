//
//  StringExtensions.swift
//  RCRC
//
//  Created by Errol on 28/10/20.
//

import Foundation
import UIKit

// MARK: - String Extensions
extension String {
    // Conversion of String to Date
    // Default Format is ISO8601
    func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ", timeZone: TimeZones, language: Languages = currentLanguage) -> Date? {
        let dateFormatter = DateFormatter()
        switch language {
        case .english:
            dateFormatter.locale = Locale(identifier: "en_US")
        case .arabic:
            
           dateFormatter.locale = Locale(identifier: "ar_SA")
           
        case .urdu:
            dateFormatter.locale = Locale(identifier: "ur_IN")
        }
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.rawValue)
        dateFormatter.dateFormat = format

        let date = dateFormatter.date(from: self)
        return date
    }

    func toDateLocalEn(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ssZ", timeZone: TimeZones, language: Languages = currentLanguage) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.rawValue)
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func getDateStringFromString(fromDateFormat: String = "dd/MM/yyyy hh:mm:ss", toDateFormat: String = "dd/MM/yyyy hh:mm:ss") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromDateFormat
        let dateFromString : Date = dateFormatter.date(from: self) ?? Date()
        dateFormatter.dateFormat = toDateFormat
        let datenew = dateFormatter.string(from: dateFromString as Date)
        return datenew
    }
    
    // Get filename from string
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    // Get extension of file
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }

    // Convert String to Int
    func toInt() -> Int {
        guard let integer = Int(self) else {
            return 0
        }
        return integer
    }

    func toDouble() -> Double {
        guard let double = Double(self) else {
            return 0
        }
        return double
    }

    var localized: String {
        return NSLocalizedString(self, comment: emptyString)
    }

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    func toDate(withFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self) ?? Date()
    }
    
    var isLowercase: Bool {
        return self == self.lowercased()
    }

    var isUppercase: Bool {
        return self == self.uppercased()
    }
    func hexToUIColor() -> UIColor {
        return UIColor(hexString: self)
    }
    var isAlphanumeric: Bool {
        guard !self.isEmpty else { return false }
        return range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    var isSmallAlphanumeric: Bool {
        guard !self.isEmpty else { return false }
        return range(of: "[^a-z0-9]", options: .regularExpression) == nil
    }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }

    var isSingleEmoji: Bool { count == 1 && containsEmoji }
    var containsAnyEmoji: Bool { contains { $0.isEmoji } }
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
    var emojiString: String { emojis.map { String($0) }.reduce("", +) }
    var emojis: [Character] { filter { $0.isEmoji } }
    var emojiScalars: [UnicodeScalar] { filter { $0.isEmoji }.flatMap { $0.unicodeScalars } }
    
    var textToImage: UIImage {
        let attributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font:Fonts.CodecBold.eighteen, NSAttributedString.Key.foregroundColor: Colors.black]
        let size = (self as NSString).size(withAttributes: attributes)
        let imageRender = UIGraphicsImageRenderer(size: size).image{ _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size), withAttributes: attributes)
        }
        return imageRender
    }
    
    func htmlToAttributedString(font: UIFont?, color: UIColor) -> NSMutableAttributedString? {
        let modifiedFont = NSString(format:"<span style=\"font-family: '\(font?.familyName ?? "CodecPro-Regular")';font-size: \(font?.pointSize ?? 16)\">%@</span>" as NSString, self) as String
        
        guard let data = modifiedFont.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange.init(location: 0, length: attributedString.length ))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 14
            attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            return attributedString
        } catch {
            return nil
        }
    }
    
    func htmlToAttributedStringWithParagraphStyle(font: UIFont?, color: UIColor, spacing: CGFloat = 3) -> NSMutableAttributedString? {
        let modifiedFont = NSString(format:"<span style=\"font-family: '\(font?.familyName ?? "CodecPro-Regular")';font-size: \(font?.pointSize ?? 16)\">%@</span>" as NSString, self) as String
        
        guard let data = modifiedFont.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange.init(location: 0, length: attributedString.length ))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = spacing
            attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            return attributedString
        } catch {
            return nil
        }
    }
    
    func htmlToAttributedStringWithFont(color: UIColor = Colors.textColor) -> NSMutableAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html,NSAttributedString.DocumentReadingOptionKey.characterEncoding:NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: color], range: NSRange.init(location: 0, length: attributedString.length ))
            return attributedString
        } catch {
            return nil
        }
    }
    
    var isValidateSecialPassword : Bool {

//            if(self.count>=8 && self.count<=20){
//            }else{
//                return false
//            }
            let nonUpperCase = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            let letters = self.components(separatedBy: nonUpperCase)
            let strUpper: String = letters.joined()

            let smallLetterRegEx  = ".*[a-z]+.*"
            let samlltest = NSPredicate(format:"SELF MATCHES %@", smallLetterRegEx)
            let smallresult = samlltest.evaluate(with: self)

            let numberRegEx  = ".*[0-9]+.*"
            let numbertest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            let numberresult = numbertest.evaluate(with: self)

            let regex = try! NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: NSRegularExpression.Options())
            var isSpecial :Bool = false
            if regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(), range:NSMakeRange(0, self.count)) != nil {
                print("could not handle special characters")
                isSpecial = true
            }else{
                isSpecial = false
            }
            return (strUpper.count >= 1) && smallresult && numberresult && isSpecial
        }
    
    var minLocalisation: String {
        if currentLanguage == .arabic {
            return String(format: "عدد (%@) دقيقة", self)
        } else {
            return "\(self) \(Constants.minuteRoute.localized)"
        }
    }
    
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
    
}

// MARK: - NSMutableAttributedString Extensions
extension NSMutableAttributedString {

    func trimmedAttributedString() -> NSAttributedString {
        let invertedSet = CharacterSet.whitespacesAndNewlines.inverted
        let startRange = string.rangeOfCharacter(from: invertedSet)
        let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        guard let startLocation = startRange?.upperBound, let endLocation = endRange?.lowerBound else {
            return NSAttributedString(string: string)
        }
        let location = string.distance(from: string.startIndex, to: startLocation) - 1
        
        var length = 0
        if self.length == string.distance(from: startLocation, to: endLocation) {
            length = string.distance(from: startLocation, to: endLocation)
        } else {
            let lengthToAdd = self.length - string.distance(from: startLocation, to: endLocation) - 1
            length = string.distance(from: startLocation, to: endLocation) + lengthToAdd
        }

        let range = NSRange(location: location, length: length)
        return attributedSubstring(from: range)
    }
}

extension String {
    func applyPatternOnNumbers(pattern: String, replacementCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
