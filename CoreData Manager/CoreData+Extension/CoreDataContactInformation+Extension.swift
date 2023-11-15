//
//  ContactInformation+Extension.swift
//  RCRC
//
//  Created by Admin on 14/08/20.
//

import Foundation

extension CoreDataContactInformation {

    func convertToContactInformation() -> ContactInformation {
        return ContactInformation(address: self.address, phoneNumber: self.mobileNumber, emailId: self.emailId)
    }
}

extension CoreDataUserProfile {

    func convertToProfileInformation() -> ProfileInformation {
        return ProfileInformation(emailAddress: self.emailAddress, mobileNumber: self.mobileNumber, fullName: self.fullName, image: self.image)
    }
}

extension CoreDataTravelPreferences {

    func convertToTravelPreference() -> TravelPreference {
        return TravelPreference(mobilityImpairedFriendly: self.mobilityImpairedFriendly, sortingType: self.sortingType, transportMethod: self.transportMethod)
    }
}
