//
//  TimeTableContentCell.swift
//  RCRC
//
//  Created by Aashish Singh on 02/11/22.
//

import UIKit

class TimeTableContentCell: UITableViewCell {

    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var leftContainerView: UIView!
    
    @IBOutlet weak var originStopNameLabel: LocalizedLabel!
    @IBOutlet weak var originStopNameEngLabel: LocalizedLabel!
    @IBOutlet weak var originStopNameArbLabel: LocalizedLabel!
    
    @IBOutlet weak var destStopNameLabel: LocalizedLabel!
    @IBOutlet weak var destStopNameEngLabel: LocalizedLabel!
    @IBOutlet weak var destStopNameArbLabel: LocalizedLabel!
    
    @IBOutlet weak var firstBusTimeLabel: LocalizedLabel!
    @IBOutlet weak var firstBusTimeValueLabel: LocalizedLabel!
    
    @IBOutlet weak var lastBusTimeLabel: LocalizedLabel!
    @IBOutlet weak var lastBusTimeValueLabel: LocalizedLabel!
    
    @IBOutlet weak var frequencyLabel: LocalizedLabel!
    @IBOutlet weak var frequencyValueLabel: LocalizedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure(){
        self.mainContainerView.layer.borderWidth = 1.0
        self.mainContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.leftContainerView.layer.borderWidth = 1.0
        self.leftContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        originStopNameLabel.font = Fonts.CodecBold.sixteen //Bold.seventeen
        destStopNameLabel.font = Fonts.CodecBold.sixteen
        firstBusTimeLabel.font = Fonts.CodecBold.sixteen
        lastBusTimeLabel.font = Fonts.CodecBold.sixteen
        frequencyLabel.font = Fonts.CodecBold.sixteen
        
        originStopNameEngLabel.font = Fonts.CodecRegular.sixteen  //Regular.seventeen
        originStopNameArbLabel.font = Fonts.CodecRegular.sixteen
        destStopNameEngLabel.font = Fonts.CodecRegular.sixteen
        destStopNameArbLabel.font = Fonts.CodecRegular.sixteen
        firstBusTimeValueLabel.font = Fonts.CodecRegular.sixteen
        lastBusTimeValueLabel.font = Fonts.CodecRegular.sixteen
        frequencyValueLabel.font = Fonts.CodecRegular.sixteen
        self.selectionStyle = .none
    }
    
    func configureCardContent(contentModel: TimeTableCardContentModel?) {
        
        if let contentModel = contentModel {
            originStopNameEngLabel.text = contentModel.originStartEngName
            originStopNameArbLabel.text = contentModel.originStartArbName
            destStopNameEngLabel.text = contentModel.desStartEngName
            destStopNameArbLabel.text = contentModel.desStartArbName
            firstBusTimeValueLabel.text = contentModel.firstBusTime
            lastBusTimeValueLabel.text = contentModel.lastBusTime
            frequencyValueLabel.text = contentModel.frequency
            
            originStopNameLabel.text = contentModel.originStopNameLabel
            destStopNameLabel.text = contentModel.desStopNameLabel
            firstBusTimeLabel.text = contentModel.firstBusTimeLabel
            lastBusTimeLabel.text = contentModel.lastBusTimeLabel
            frequencyLabel.text = contentModel.frequencyLabel
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
