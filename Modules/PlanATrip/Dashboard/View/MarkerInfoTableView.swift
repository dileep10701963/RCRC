//
//  MarkerInfoTableView.swift
//  RCRC
//
//  Created by Aashish Singh on 12/06/23.
//

import Foundation
import UIKit

class MarkerInfoTableView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loadingButton: LoadingButton!
    
    private var infoTabularData: [NextBusInfoModel] = []
    
    class func instanceFromNib() -> MarkerInfoTableView {
        return UINib(nibName: "MarkerInfoTableView", bundle: nil).instantiate(withOwner: self, options: nil).first as? MarkerInfoTableView ?? MarkerInfoTableView()
    }
    
    var titleText: String = ""  {
        didSet {
            self.titleLabel.text = "  \(titleText)  "
            self.titleLabel.font = Fonts.CodecBold.twelve
            self.titleLabel.numberOfLines = 0
            //self.titleLabel.textColor = Colors.textColor
            self.titleLabel.textAlignment = .center
        }
    }
    
    func configureView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.register(InfoTableCell.self)
        self.loadingButton.isHidden = true
        infoTabularData = []
    }
    
    var tabularData: [NextBusInfoModel]? = [] {
        didSet {
            if let tabularData = tabularData, tabularData.count > 0 {
                
                containerView.borderColor = Colors.placeHolderGray
                //containerView.borderWidth = 1.0
                containerView.setCorner(radius: 10)
                loadingButton.hideLoading()
                loadingButton.isHidden = true
                
                infoTabularData = tabularData
                tableView.reloadData()
            }
        }
    }
    
}

extension MarkerInfoTableView: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoTabularData.count > 0 ? infoTabularData.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch infoTabularData.count > 0 {
        case true:
            if indexPath.row == 0 {
                let cell: InfoTableCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configureHeader()
                return cell
            } else {
                let cell: InfoTableCell = tableView.dequeue(cellForRowAt: indexPath)
                cell.configureData(model: infoTabularData[indexPath.row - 1])
                return cell
            }
        case false:
            let cell = UITableViewCell()
            return cell
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 28
    }

}
