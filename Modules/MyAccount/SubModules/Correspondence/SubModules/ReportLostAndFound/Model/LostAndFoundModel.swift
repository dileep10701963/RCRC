//
//  LostAndFoundModel.swift
//  RCRC
//
//  Created by Errol on 28/04/21.
//

import UIKit

enum MediaType {
    case image, video, none
}

struct LostAndFoundModel {
    var type: String?
    var category: String?
    var subCategory: String?
    var location: SelectedLocation?
    var date: String?
    var description: String?
    var images: [UIImage] = []
    var videos: [NSData] = []
}

struct SelectedLocation {
    var address: String?
    var latitude: Double?
    var longitude: Double?
}

struct IncidentModel {
    var type: String?
    var subType: String?
    var location: SelectedLocation?
    var date: String?
    var description: String?
    var images: [UIImage] = []
    var videos: [NSData] = []
    var mediaType: MediaType = .none
}

struct IncidentLostFoundData {
    var category: String
    var subCategory: [String]
}

let lostAndFound = [
    IncidentLostFoundData(category: "Smart Cards/Token",
                          subCategory: ["Stored value cards", "Monthly pass", "Personalized Smart Cards", "Other cards"]),
    
    IncidentLostFoundData(category: "Lost Person",
                          subCategory: ["Male", "Female", "Child"]),
    
    IncidentLostFoundData(category: "Personal Baggage",
                          subCategory: ["Briefcase", "Handbag", "Shoulder/ Air bag", "Soft luggage suitcase", "Hard luggage suitcase"]),
    
    IncidentLostFoundData(category: "Valuable Item",
                          subCategory: ["Jewelry", "Cash", "Wallet", "Laptop", "Mobile", "Camera", "Other electronic items", "Mobile tablet", "Others"]),
    
    IncidentLostFoundData(category: "Documents",
                          subCategory: ["Passport", "Driving License", "National Id card", "Debit/Credit Card", "Iqama", "Others"]),
    IncidentLostFoundData(category: "Miscellaneous Item",
                          subCategory: ["Baby/Toddler Items", "Clothing", "Mobile charger", "Medicine", "Books", "Tiffin Box (Empty)", "Spectacles/glasses", "Others"]),
    
    IncidentLostFoundData(category: "Perishable Items",
                          subCategory: ["Food", "Drinks", "Tinned food", "Others"]),
    
    IncidentLostFoundData(category: "Others",
                          subCategory: ["Others"])]

let complaints = [
    IncidentLostFoundData(category: "Passenger Services",
                          subCategory: ["Parking", "Wheelchairs", "Information in braille", "Assistance from personnel", "DRT services", "Others"]),
    IncidentLostFoundData(category: "Faulty equipment",
                          subCategory: ["AFC System", "Information displays", "Bus/ Metro stop", "Bus/ Metro vehicle","Others"]),
    IncidentLostFoundData(category: "Information & signages",
                          subCategory: ["Signage's & Directions","Mobility Portal Website", "Mobility Portal App", "Bus/Metro Schedule", "Public Announcements (content)", "Printed Collateral", "Others"]),
    
    IncidentLostFoundData(category: "House keeping",
                          subCategory: ["Cleanliness", "Water Supply", "Odour", "Others"]),
    
    IncidentLostFoundData(category: "Security",
                          subCategory: [ "Safety", "Unruly Passengers", "Passengers with threatening / suspicious objects", "Suspicious objects", "Others"]),

    
    IncidentLostFoundData(category: "Ticketing",
                          subCategory: ["Fare charges", "Stored value pass", "Monthly pass", "Personalized cards (CSC)", "Smart card balance", "Discounts", "Penalty", "Refunds", "Replacement", "Acceptance of credit/Debit cards", "Others"]),
    
    IncidentLostFoundData(category: "Bus/ Metro operations",
                          subCategory: ["Journey time", "Overcrowding", "Delay in service","Incident / accident", "Journey planner", "Diversion","Dwell time","Opening of service", "Closing of Service", "Frequency of Service"]),
    
    IncidentLostFoundData(category: "Staff related",
                          subCategory: ["Customer service staff", "Ticket Inspectors", "Bus driver", "Security staff", "Lost & found staff", "Call center staff", "House keeping staff", "Maintenance staff", "Other staff"]),
    
    IncidentLostFoundData(category: "Metro Roadworks",
                          subCategory: ["Metro Construction - Jersey Barriers", "Metro Construction - Pollution", "Metro Construction - Public Safety", "Metro Construction - Excavations", "Metro Construction - Utilities/ Electricity", "Metro Diversions - Parking", "Metro Diversions - Pedestrian crossing", "Metro Diversions - Public safety", "Metro Diversions - Speed bumps", "Metro Diversions - Road access (in/out)", "Metro Diversions - Traffic jams", "Others"]),
    
    IncidentLostFoundData(category: "Bus Roadworks",
                          subCategory: ["Bus Construction - Jersey Barriers", "Bus Construction - Pollution", "Bus Construction - Public Safety", "Bus Construction - Excavations", "Bus Construction - Utilities/ Electricity", "Bus Diversions - Parking", "Bus Diversions - Pedestrian crossing", "Bus Diversions - Public safety", "Bus Diversions - Speed bumps", "Bus Diversions - Road access (in/out)", "Bus Diversions - Traffic jams", "Others"])]
