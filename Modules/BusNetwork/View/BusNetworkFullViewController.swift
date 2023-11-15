//
//  BusNetworkFullViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 28/10/22.
//

import UIKit
import WebKit
import PDFKit

class BusNetworkFullViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage?
    var url: URL!
    var busNetworkViewModel = BusNetworkViewModel()
    var activityIndicator: UIActivityIndicatorView?
    var isStaticMapLoading: Bool = false
    var pdfData: Data? = nil
    let heightIs = UIScreen.main.bounds.size.height - 143

    lazy var pdfView: PDFView = {
        let heightIs = UIScreen.main.bounds.size.height - 143
        let view = PDFView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: heightIs))
        view.backgroundColor = UIColor.white
        view.displaysRTL = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.pdfData == nil {
            switch isStaticMapLoading {
            case true:
                configurePDFWithURL(pdfURL: url)
            case false:
                loadPDFData()
            }
        } else {
            configure(pdfData: self.pdfData)
        }
        
        self.disableLargeNavigationTitleCollapsing()
    }
    
    private func loadPDFData() {
        self.activityIndicator = self.startActivityIndicator()
        self.busNetworkViewModel.getPDFData(url: url) { [weak self ]data in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                if let data = data {
                    self?.configure(pdfData: data)
                } else {
                    self?.showAlert(for: .serverError)
                }
            }
        }
    }
    
    func configure(pdfData: Data?) {
        if let pdfData = pdfData {
            self.scrollView.removeFromSuperview()
            pdfView = PDFView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: heightIs))
            containerView.addSubview(pdfView)
            pdfView.document = PDFDocument(data: pdfData)
            pdfView.autoScales = true
            pdfView.backgroundColor = UIColor.white

        } else if let image = image {
            self.imageView.image = image
            self.scrollView.delegate = self
            self.scrollView.minimumZoomScale = 1.0
            self.scrollView.maximumZoomScale = 4
        }
    }
    
    func configurePDFWithURL(pdfURL: URL) {
        if self.scrollView != nil {
            self.scrollView.removeFromSuperview()
        }
        containerView.addSubview(pdfView)
        pdfView.document = PDFDocument(url: pdfURL)
        pdfView.autoScales = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: emptyString)
        let subViews = self.navigationController?.navigationBar.subviews
        self.addProfileButtonOnNavigationBar(subViews: subViews)
    }
    
    func addProfileButtonOnNavigationBar(subViews: [UIView]?) {
        
        let shareButton = UIButton(type: .custom)
        shareButton.setImage(Images.share!, for: .normal)
        shareButton.contentMode = .scaleAspectFill
        shareButton.backgroundColor = .clear
        shareButton.tintColor = Colors.rptNavButtonGreen
        shareButton.tag = 1040
        shareButton.addTarget(self, action: #selector(shareTapped(_:)), for: .touchUpInside)
        
        var maxy = self.navigationController?.navigationBar.frame.height ?? 0
        var navWidth = self.navigationController?.navigationBar.frame.width ?? 0
        maxy = maxy - (35 + 4)
        navWidth = navWidth - (35 + 20)
        
        let englishXForInfo: CGFloat = navWidth
        let arabicXForInfo: CGFloat = 20
        shareButton.frame = CGRect(x: currentLanguage == .arabic ? arabicXForInfo: englishXForInfo, y: maxy, width: 35, height: 35)
        
        if let subviews = subViews {
            if subviews.contains(where: {$0.tag == 1040}) {} else {
                self.navigationController?.navigationBar.addSubview(shareButton)
            }
        } else {
            self.navigationController?.navigationBar.addSubview(shareButton)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let subViews = self.navigationController?.navigationBar.subviews
        if let subviews = subViews {
            for subView in subviews where subView.tag == 1040 {
                subView.removeFromSuperview()
            }
        }
        self.hidesBottomBarWhenPushed = false
    }
    
    @objc func shareTapped(_ sender: UIButton) {
        let documento = NSData(contentsOf: url)
        let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [documento!], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView=self.view
        present(activityViewController, animated: true, completion: nil)
    }
    
}

extension BusNetworkFullViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale > 1 {
            if let image = self.imageView.image {
                let ratioW = imageView.frame.width / image.size.width
                let ratioH = imageView.frame.height / image.size.height
                let ratio = ratioW < ratioH ? ratioW: ratioH
                
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                
                let conditionLeft = newWidth * scrollView.zoomScale > imageView.frame.width
                let left = 0.5 * (conditionLeft ? newWidth - imageView.frame.width: (scrollView.frame.width - scrollView.contentSize.width))
                
                let conditionTop = newHeight * scrollView.zoomScale > imageView.frame.height
                let top = 0.5 * (conditionTop ? newHeight - imageView.frame.height: (scrollView.frame.height - scrollView.contentSize.height))
                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            }
        } else {
            scrollView.contentInset = .zero
        }
    }
}


