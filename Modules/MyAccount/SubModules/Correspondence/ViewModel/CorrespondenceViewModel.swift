//
//  CorrespondenceViewModel.swift
//  RCRC
//
//  Created by anand madhav on 17/11/20.
//

import UIKit

class CorrespondenceViewModel: NSObject {

    public var correspondenceList = [Constants.reportAnIncident,
                                     Constants.reportLostAndFound,
                                    Constants.recentCommunication]
    public var correspondenceImageList = [Images.reportAnIncidentIcon,
                                          Images.reportLostAndFoundIcon,
                                          Images.recentCommunicationIcon]
    
    
}
