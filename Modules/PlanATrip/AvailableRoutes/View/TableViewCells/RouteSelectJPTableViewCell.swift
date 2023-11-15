//
//  RouteSelectJPTableViewCell.swift
//  RCRC
//
//  Created by Anjum on 12/11/23.
//

import UIKit

protocol RouteSelectJPHeaderCellDelegate {
    
    func buttonProceedTaped(button:UIButton)
    func buttonSourceTaped(buttn:UIButton)
    func buttonDestinationTaped(button:UIButton)
    func buttonAddToFavourite(buttn:UIButton)
    func buttonSavedFavourite(buttn:UIButton)
    func buttonSwapLocation(buttn:UIButton)
    
    
}
class RouteSelectJPTableViewCell: UITableViewCell {

    @IBOutlet weak var proceedButtonConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var routeSelectionView: RouteSelectionView!
    @IBOutlet weak var availableRoutesTableView: UITableView!
    @IBOutlet weak var numberOfRoutesAvailable: UILabel!
    @IBOutlet weak var labelWhereFrom: UILabel!
    @IBOutlet weak var labelFrom: UILabel!
    @IBOutlet weak var labelBusRoutes: UILabel!
    @IBOutlet weak var labelBusRoutesSuggestedForYou: UILabel!
    @IBOutlet weak var viewRouteSuggested: UIView!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var labelSuggested: UILabel!
    @IBOutlet weak var labelSaveForlater: UILabel!
    @IBOutlet weak var buttonAddFavourite: UIButton!
    @IBOutlet weak var buttonSavedFaouriteRoutes: UIButton!
    
    @IBOutlet weak var viewBusRouteSuggestHeightConstrant: NSLayoutConstraint!
    @IBOutlet weak var buttonDestination: UIButton!
    
    //@IBOutlet weak var proceedButtonView: ProceedButtonView!
    @IBOutlet weak var favoriteRouteButton: UIButton!
    @IBOutlet weak var buttonSource: UIButton!
    @IBOutlet weak var buttonProceed: UIButton!
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var labelDestination: UILabel!
    @IBOutlet weak var labelSource: UILabel!
    
     var delegate:RouteSelectJPHeaderCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleSetup()
    }
//    static var nib: UINib {
//        return UINib(nibName: identifier, bundle: nil)
//    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    static var identifier: String {
//        return String(describing: self)
//    }
    
    
    func titleSetup()  {
        
        labelWhereFrom.text = Constants.whereFrom.localized
        labelWhereFrom.setAlignment()
        labelFrom.text = Constants.from.localized
        //labelFrom.setAlignment()
        labelTo.text = Constants.to.localized
        //labelTo.setAlignment()
        labelSource.text = Constants.enterOrigin.localized
        labelSource.setAlignment()
        labelDestination.text = Constants.selectYourDestination.localized
        labelDestination.setAlignment()
        labelSaveForlater.text = Constants.saveLater.localized
        labelSaveForlater.setAlignment()
        buttonAddFavourite.setTitle(Constants.addFourote.localized, for: .normal)
        //buttonAddFavourite.titleLabel?.setAlignment()
        buttonSavedFaouriteRoutes.setTitle(Constants.favouriteRoutes.localized, for: .normal)
        //buttonAddFavourite.titleLabel?.setAlignment()
        buttonProceed.setTitle(Constants.proceed, for: .normal)
        
        //headerTitleFavoriteRouteView.text = Constants.favoriteRoutes.localized
       // headerTitleFavoriteRouteView.setAlignment()
        labelBusRoutes.text = Constants.busRoutesJP.localized
        labelBusRoutes.setAlignment()
        labelBusRoutesSuggestedForYou.text = Constants.busRoutesSuggested.localized
        labelBusRoutesSuggestedForYou.setAlignment()
        buttonProceed.setTitle(Constants.proceed.localized, for: .normal)
        
    }
    
    @IBAction func buttonSourceTap(_ sender: UIButton) {
//        self.selectRouteOpen()
//        buttonSource.isSelected = true
//        buttonSource.isEnabled = false
        delegate?.buttonSourceTaped(buttn: sender)
    }
    
    @IBAction func buttonDestinationTap(_ sender: UIButton) {
//        self.selectRouteOpen()
//        buttonSource.isSelected = false
//        buttonSource.isEnabled = true
        delegate?.buttonDestinationTaped(button: sender)
    }
    
    @IBAction func buttonAddFaouriteRoutes(_ sender: UIButton) {
        delegate?.buttonAddToFavourite(buttn: sender)
//        guard let origin = self.origin, let destination = self.destination else { return }
//        viewModel.saveRoute(source: origin, destination: destination)
    }
    
    @IBAction func buttonSavedFaouriteRoutes(_ sender: UIButton) {
       
        delegate?.buttonSavedFavourite(buttn: sender)
    }
    
    @IBAction func buttonSwapStaionsTap(_ sender: UIButton) {
        delegate?.buttonSwapLocation(buttn: sender)
        
    }
    @IBAction func buttonProceedTap(_ sender: UIButton) {
        delegate?.buttonProceedTaped(button: sender)
        //didTapProceed()
    }
    
}
