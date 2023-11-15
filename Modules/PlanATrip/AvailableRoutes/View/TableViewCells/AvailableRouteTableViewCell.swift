//
//  AvailableRouteTableViewCell.swift
//  RCRC
//
//  Created by Errol on 21/07/20.
//

import UIKit

class AvailableRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var travelTimeLabel: UILabel!
    @IBOutlet weak var originAddressLabel: UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var bottomGrayView: UIView!
    @IBOutlet weak var travelCostLabel: UILabel!
    @IBOutlet weak var travelOriginDesTimeLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var buttonInfo: UIButton!
    
    @IBOutlet weak var ticketView: UIView!
    @IBOutlet weak var ticketLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var buttonBuy: UIButton!
    
    @IBOutlet weak var stackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var backgroundViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var backGroundImageView: UIImageView!
    
    
    weak var delegate: MapTableViewCellDelegate?
    var fare: Fare?
    var buttonBuyTapped: (() -> Void)?
    private var finalWidth: CGFloat = 177

    override func awakeFromNib() {
        super.awakeFromNib()
        /*self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderColor = Colors.rptGrey.cgColor*/
        
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 20.0
        self.borderView.clipsToBounds = true
        self.borderView.layer.cornerRadius = 20.0
        
        self.travelTimeLabel.setAlignment()
        self.originAddressLabel.setAlignment()
        self.destinationAddressLabel.setAlignment()
        self.travelCostLabel.setAlignment()
        
        self.buttonBuy.setTitle(Constants.ticket.localized, for: .normal)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomGrayView.translatesAutoresizingMaskIntoConstraints = false
        
    }

    func configure(with viewModel: TripCellViewModel) {
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.travelTimeLabel.text = viewModel.travelTime
        self.travelTimeLabel.textColor = Colors.textGray
        self.travelTimeLabel.font = Fonts.CodecRegular.twelve
        self.originAddressLabel.attributedText = viewModel.originAddress
        self.destinationAddressLabel.attributedText = viewModel.destinationAddress
        
        finalWidth = self.backGroundImageView.frame.width - 130
        var stackWidthArray: [CGFloat] = []
        var stackSubViews: [[UIView]] = []
        
        if let transportModes = viewModel.transportModes {
            var width: CGFloat = 0
            var subViews: [UIView] = []
            var viewCount = 0
            
            for (_, transportModeView) in transportModes.enumerated() {
                if let transportMode = transportModeView as? UIImageView {
                    
                    if transportMode.image ?? UIImage() == Images.routeBusTransportMode! {
                        width += 19
                        viewCount += 1
                    } else {
                        width += 11
                        viewCount += 1
                    }
                    
                    if viewCount > 1 {
                        width += 3
                    }
                    
                    subViews.append(transportModeView)
                    
                    if width >= finalWidth {
                        stackWidthArray.append(width)
                        if stackSubViews.count > 0 {
                            stackSubViews.append(subViews)
                        } else {
                            stackSubViews = [subViews]
                        }
                        width = 0
                        viewCount = 0
                        subViews = []
                    }
                }
            }
            
            if width > 0 {
                stackWidthArray.append(CGFloat(width))
                if stackSubViews.count > 0 {
                    stackSubViews.append(subViews)
                } else {
                    stackSubViews = [subViews]
                }
                width = 0
                subViews = []
            }
            
        }
        
        self.backgroundViewHeightConstraint.constant = 35
        if stackWidthArray.count > 0 {
            if stackWidthArray.count > 1 {
                let stackViewTotalHeight = (stackWidthArray.count * 20) + ((stackWidthArray.count - 1) * 4 )
                let backgroundViewHeight = 7.5 + Double(stackViewTotalHeight) + 7.5
                self.backgroundViewHeightConstraint.constant = CGFloat(backgroundViewHeight)
                
                configureStackViewForVertical()
                self.stackViewWidth.constant = stackWidthArray[0]
                self.stackViewHeightConstraint.constant = CGFloat(stackViewTotalHeight)
                
                for (index, subViews) in stackSubViews.enumerated() {
                    self.stackView.addArrangedSubview(createAndAddStackView(subViews: subViews, width: stackWidthArray[index]))
                }
            } else {
                self.backgroundViewHeightConstraint.constant = 35
                configureStackViewForHorizontal()
                self.stackViewWidth.constant = stackWidthArray[0]
                self.stackViewHeightConstraint.constant = 20
                viewModel.transportModes?.forEach({ self.stackView.addArrangedSubview($0) })
            }
        }
        
        self.travelOriginDesTimeLabel.attributedText = viewModel.originDestinalTime
        self.fare = viewModel.mapCellViewModel?.fare
        
        if viewModel.travelCost == nil || viewModel.travelCost == emptyString {
            self.buttonInfo.isHidden = true
        } else {
            self.buttonInfo.isHidden = false
        }
        self.travelCostLabel.text = viewModel.travelCost
        self.ticketView.isHidden = true
    }
    
    private func configureStackViewForHorizontal() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3
    }
    
    private func configureStackViewForVertical() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 4
    }
    
    private func createAndAddStackView(subViews: [UIView], width: CGFloat) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        
        let stackView = UIStackView(arrangedSubviews: subViews)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 3

        view.addSubview(stackView)
        stackView.frame = view.bounds
        
        return view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    @IBAction func buttonInfoTapped(_ sender: UIButton) {
        
        if ticketView.isHidden == false { return }
        
        if let fare = fare, let tickets = fare.tickets, tickets.count > 0 {
            self.ticketView.isHidden = false
            self.ticketLabel.text = tickets[0]?.name ?? emptyString
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.ticketView.isHidden = true
            }
        }
        //delegate?.infoButtonClicked(cell: self, fare: self.fare)
    }
    
    @IBAction func ticketAction(_ sender: Any) {
        buttonBuyTapped?()
    }
}

extension UIStackView {

    func addArrangedSubviews(_ subviews: [UIView]) {
        guard self.arrangedSubviews.isEmpty else { return }
        subviews.forEach { self.addArrangedSubview($0) }
    }
}
