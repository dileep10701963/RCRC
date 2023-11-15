//
//  KAPTInfoContentCell.swift
//  RCRC
//
//  Created by Aashish Singh on 20/12/22.
//

import UIKit

class KAPTInfoContentCell: UITableViewCell {

    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTitleLabel: LocalizedLabel!
    @IBOutlet weak var contentDescriptionLabel: LocalizedLabel!
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentImageView.image = Images.newsPlaceholder
    }
    
    private func configureUI(){
        
        contentTitleLabel.font = Fonts.Regular.twenty
        contentTitleLabel.textColor = Colors.black
        
        contentDescriptionLabel.font = Fonts.Regular.seventeen
        contentDescriptionLabel.textColor = Colors.black
        
        self.selectionStyle = .none
        self.contentImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentImageView.image = Images.newsPlaceholder
    }
    
    func configure(title: String, description: String) {
        self.contentTitleLabel.text = title
        self.contentDescriptionLabel.text = description
    }
    
    func configureImageContent(contentImage: UIImage?) {
        if let contentImage = contentImage {
//            contentImageView.image = resizeImage(image: contentImage, targetSize: CGSize(width: contentImageView.frame.width, height: contentImageView.frame.height))
            
            contentImageView.image = contentImage
            let ratio = contentImage.size.width / contentImage.size.height
            let updatedHeight = contentImageView.frame.width / ratio
            imageViewHeightConstraint.constant = updatedHeight
            imageViewTopConstraint.constant = 12
            contentImageView.layoutIfNeeded()
        }
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
       let size = image.size
       
       let widthRatio  = targetSize.width  / size.width
       let heightRatio = targetSize.height / size.height
       
       // Figure out what our orientation is, and use that to form the rectangle
       var newSize: CGSize
       if(widthRatio > heightRatio) {
           newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
       } else {
           newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
       }
       
       // This is the rect that we've calculated out and this is what is actually used below
       let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
       
       // Actually do the resizing to the rect using the ImageContext stuff
       UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
       image.draw(in: rect)
       let newImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       return newImage!
   }
    
    
}
