//
//  UITextview+Extension.swift
//  RCRC
//
//  Created by Ganesh Shinde on 20/11/20.
//

import Foundation
import UIKit

extension UITextView {

    private class PlaceholderLabel: LocalizedLabel { }

    private var placeholderLabel: PlaceholderLabel {
        if let label = subviews.compactMap({ $0 as? PlaceholderLabel }).first {
            return label
        } else {
            let label = PlaceholderLabel(frame: .zero)
            label.font = font
            addSubview(label)
            return label
        }
    }

    @IBInspectable
    var placeholder: String {
        get {
            return subviews.compactMap({ $0 as? PlaceholderLabel }).first?.text ?? ""
        }
        set {
            let placeholderLabel = self.placeholderLabel
            placeholderLabel.textColor = .gray
            placeholderLabel.text = newValue.localized
            placeholderLabel.numberOfLines = 0
            let width = frame.width - textContainer.lineFragmentPadding * 2
            let size = placeholderLabel.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            placeholderLabel.frame.size.height = size.height
            placeholderLabel.frame.size.width = width
            placeholderLabel.frame.origin = CGPoint(x: textContainer.lineFragmentPadding, y: textContainerInset.top)

            textStorage.delegate = self
        }
    }

    func setAlignment() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.textAlignment = .right
        } else {
            self.textAlignment = .left
        }
    }

    func addDoneButton(_ target: Any?, selector: Selector) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: selector)
        toolbar.setItems([button], animated: true)
        self.inputAccessoryView = toolbar
    }
}

extension UITextView: NSTextStorageDelegate {

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(.editedCharacters) {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }

}
