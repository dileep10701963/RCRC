//
//  ImageCollectionViewCell.swift
//  RCRC
//
//  Created by Errol on 29/04/21.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var incidenceImage: UIImageView!
    @IBOutlet weak var uploadImageProgressBar: UIProgressView!
    @IBOutlet weak var deleteButton: UIButton!

    var delete: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.uploadImageProgressBar.tintColor = .blue
    }

    func configure(with file: UploadProgress?, delete: (() -> Void)? = nil) {
        self.incidenceImage.image = file?.image
        if file?.image == Images.addNewFile {
            self.deleteButton.isHidden = true
            self.uploadImageProgressBar.isHidden = true
        } else if  file?.hasUploaded ?? false {
            self.deleteButton.isHidden = false
            self.uploadImageProgressBar.isHidden = true
        } else {
            self.deleteButton.isHidden = true
            self.uploadImageProgressBar.isHidden = false
        }
        if let progress = file?.progress {
            self.uploadImageProgressBar.setProgress(Float(progress), animated: true)
        }
        self.delete = delete
    }

    @IBAction func deleteTapped(_ sender: UIButton) {
        delete?()
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
