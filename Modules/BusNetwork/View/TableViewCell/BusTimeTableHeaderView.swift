//
//  BusTimeTableHeaderView.swift
//  RCRC
//
//  Created by Aashish Singh on 04/11/22.
//

import UIKit

class BusTimeTableHeaderView: UITableViewHeaderFooterView {

    //@IBOutlet weak var busRouteImageView: UIImageView!
    @IBOutlet weak var routeColorLabel: UILabel!
    @IBOutlet weak var routeTitleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var transparentHeaderButton: UIButton!
    
    static let reuseIdentifier = "BusTimeTableHeaderView"
    var sectionTapped: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure() {
        routeTitleLabel.font = Fonts.CodecRegular.sixteen //Regular.eighteen
        routeTitleLabel.textColor = Colors.textColor
    }
    
    func configureHeaderTitle(title: String?, section: Int, selected: Int?,routeColr:UIColor) {
        
       // setBusImage(busRouteImageEndpoint)
        let titleString = attributedText(text: title ?? emptyString, lineSapcing: 4)
        self.routeTitleLabel.attributedText = titleString
        self.transparentHeaderButton.tag = section
        self.routeColorLabel.backgroundColor = routeColr
        self.routeTitleLabel.setAlignment()
        if section == selected {
            //accessoryButton.setImage(Images.busCollapse, for: .normal)
        } else {
           // accessoryButton.setImage(Images.busExpand, for: .normal)
        }
    }
    
    func setBusImage(_ busImageEndpoint: String?) {
        //self.busRouteImageView.image = nil
        let urlString = URLs.busContentURL + (busImageEndpoint ?? "")
        guard let url = URL(string: "\(urlString)") else { return }
        
        
        /*UIImage.loadFrom(url: url) { image in
         DispatchQueue.main.async {
         self.busImageView.image = image
         }
         }*/
    }
    
    @IBAction func accessoryButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func transparentButtonHeaderTapped(_ sender: UIButton) {
        self.sectionTapped?(sender.tag)
    }
    
    
    
}
