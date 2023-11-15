//
//  BusDetailsCollectionCell.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 30/01/23.
//

import UIKit

class BusDetailsCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var busImageView: UIImageView!
    let mediaCache = NSCache<AnyObject, AnyObject>()
    var activityIndicator: UIActivityIndicatorView?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
        busImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setBusImage(_ busImageEndpoint: String?) {
        let urlString = URLs.busContentURL + (busImageEndpoint ?? "")
        guard let url = URL(string: "\(urlString)") else { return }
        DispatchQueue.main.async {
            self.busImageView.af.setImage(withURL: url)
        }
        
        /*UIImage.loadFrom(url: url) { image in
         DispatchQueue.main.async {
         self.busImageView.image = image
         }
         }*/
    }
}
