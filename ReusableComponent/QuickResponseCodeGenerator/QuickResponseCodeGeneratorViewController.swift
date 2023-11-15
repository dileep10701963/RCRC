//
//  QuickResponseCodeGeneratorViewController.swift
//  RCRC
//
//  Created by Errol on 14/12/20.
//

import UIKit

class QuickResponseCodeGeneratorViewController: UIViewController {

    @IBOutlet weak var quickResponseCodeImage: UIImageView!
    @IBOutlet weak var inputLabel: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        inputLabel.delegate = self
    }

    @IBAction func generateButtonTapped(_ sender: UIButton) {

        guard let inputText = inputLabel.text else { return }
        let generatedCodeImage = generateQuickResponseCode(for: inputText)
        quickResponseCodeImage.image = generatedCodeImage
    }

    private func generateQuickResponseCode(for string: String) -> UIImage? {
        let data = dataFromHexString(hex: string)
        if let filter = CIFilter(name: "CIAztecCodeGenerator") {
            filter.setValue(data, forKey: Constants.qrCodeFilterKey)
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }

    private func dataFromHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while hex.count > 0 {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}

extension Data {
    init?(hex: String) {
        guard hex.count.isMultiple(of: 2) else {
            return nil
        }
        let chars = hex.map { $0 }
        let bytes = stride(from: 0, to: chars.count, by: 2)
            .map { String(chars[$0]) + String(chars[$0 + 1]) }
            .compactMap { UInt8($0, radix: 16) }

        guard hex.count / bytes.count == 2 else { return nil }
        self.init(bytes)
    }
}

extension QuickResponseCodeGeneratorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if updatedText.containsEmoji || updatedText.containsAnyEmoji {
                return false
            }
        }
        return true
    }
}
