//
//  UITableview+Extension.swift
//  RCRC-UI
//
//  Created by Admin on 19/04/21.
//

import Foundation
import UIKit
import PDFKit

public extension UITableView {

    func register(_ cellClass: AnyClass) {
        let identifier = String.className(cellClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forCellReuseIdentifier: identifier)
    }

    func dequeue<T: UITableViewCell>(cellForRowAt indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T else { fatalError("Cell not registered with Table View") }
        return cell
    }

    func registerHeaderFooterViewNib(_ viewClass: AnyClass) {
        let identifier = String.className(viewClass)
        let nib = UINib(nibName: identifier, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }

    func setEmptyMessage(_ message: String) {
        if !message.isEmpty {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 50, height: self.bounds.size.height))
            messageLabel.text = message
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = Fonts.CodecNews.fourteen
            messageLabel.textColor = Colors.tableErrorTextColor
            messageLabel.sizeToFit()
            
            self.backgroundView = messageLabel
            self.separatorStyle = .none
        } else {
            self.backgroundView = nil
        }

    }
    
    func setEmptyMessageExistingCard(_ message: String) {
            if !message.isEmpty {
                let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width - 50, height: self.bounds.size.height))
                messageLabel.text = message
                messageLabel.textColor = .black
                messageLabel.numberOfLines = 0
                messageLabel.textAlignment = .center
                messageLabel.font = Fonts.CodecNews.fourteen
                messageLabel.textColor = Colors.tableErrorTextColor
                messageLabel.sizeToFit()
                
                self.backgroundView = messageLabel
                self.separatorStyle = .none
            } else {
                self.backgroundView = nil
                self.separatorStyle = .singleLine
            }
        }

    
    func setEmptyMessageWithLink(_ message: String, _ selector: Selector, target: Any, data: Data? = nil, _ tapSelector: Selector,  _ messageAlignment: NSTextAlignment? = .left) {
        
        if self.backgroundView != nil {
            self.backgroundView = nil
        }
        
        let view = UIView()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        paragraphStyle.alignment = messageAlignment ?? .left //NSTextAlignment.center
        let messageAttrString = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.font: Fonts.CodecNews.fourteen, NSAttributedString.Key.foregroundColor: Colors.textColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        let messageLabel = UILabel()
        messageLabel.textAlignment = .center
        messageLabel.attributedText = messageAttrString
        messageLabel.numberOfLines = 0
        messageLabel.sizeToFit()
        
        let buttonAttributedString = NSMutableAttributedString(string: Constants.viewCurrentLine.localized, attributes: [NSAttributedString.Key.font: Fonts.CodecRegular.sixteen, NSAttributedString.Key.foregroundColor: Colors.newGreen, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.underlineColor: Colors.newGreen])
        
        let linkButton = UIButton()
        linkButton.setAttributedTitle(buttonAttributedString, for: .normal)
        linkButton.titleLabel?.font = Fonts.CodecNews.fourteen
        linkButton.addTarget(target, action: selector, for: .touchUpInside)
        linkButton.titleLabel?.textAlignment = .center
        linkButton.sizeToFit()
        
        let containerView = UIView()
        containerView.isHidden = true
        containerView.sizeToFit()
        
        view.addSubview(messageLabel)
        view.addSubview(linkButton)
        view.addSubview(containerView)
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16).isActive = true
        linkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: linkButton.bottomAnchor, constant: 24).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        
        if let data = data {
            containerView.isHidden = false
            let frameHeight = (self.frame.size.height - (32 + messageLabel.frame.size.height + linkButton.frame.size.height + 16 + 24 + 24))
            let pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width - 48, height: frameHeight))
            pdfView.document = PDFDocument(data: data)
            pdfView.displayMode = .singlePage
            pdfView.backgroundColor = .clear
            pdfView.autoScales = true
            pdfView.maxScaleFactor = 4.0
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
            containerView.addSubview(pdfView)
            
            let tap = UITapGestureRecognizer(target: target, action: tapSelector)
            tap.numberOfTapsRequired = 1
            pdfView.addGestureRecognizer(tap)
            pdfView.isUserInteractionEnabled = true
            
        } else {
            containerView.isHidden = true
        }
        
        self.backgroundView = view
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
    
    func tempHeaderView() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
    
    func tempHeaderViewWithLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        
        let headerView = UIView()
        headerView.backgroundColor = Colors.tableDividerColor
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 62).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -42).isActive = true
        headerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 14).isActive = true
        headerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        return view
    }
    
    func headerViewWithSectionText(text: String) -> UIView {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let header = UILabel()
        header.textColor = Colors.textColor
        header.font = Fonts.CodecRegular.sixteen
        header.text = text
        view.addSubview(header)
        
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        header.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
}

extension UITableViewCell {

    static var reuseIdentifier: String {
        return String(describing: type(of: self))
    }

}

extension String {
    static func className(_ aClass: AnyClass) -> String {
          return NSStringFromClass(aClass).components(separatedBy: ".").last!
      }
}
