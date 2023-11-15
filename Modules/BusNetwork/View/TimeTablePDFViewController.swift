//
//  TimeTablePDFViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 15/02/23.
//

import UIKit
import PDFKit

class TimeTablePDFViewController: ContentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePDF()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    func configurePDF() {
        let pdfView = PDFView(frame: self.view.bounds)
        self.view.addSubview(pdfView)
        let fileURL = Bundle.main.url(forResource: currentLanguage == .english ? "schedules_eng": "schedules_ara", withExtension: "pdf")
        if let fileURL = fileURL {
            pdfView.autoScales = true
            pdfView.document = PDFDocument(url: fileURL)
            pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
