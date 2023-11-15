//
//  PlacesOfInterestRequest.swift
//  RCRC
//
//  Created by Errol on 25/06/21.
//

import Foundation

enum PlacesOfInterestCategory: String, Encodable, CaseIterable {
    case amusementPark = "amusement_park"
    case aquarium
    case artGallery = "art_gallery"
    case atm
    case bank
    case beautySalon = "beauty_salon"
    case cafe
    case campground
    case casino
    case cemetery
    case cityHall = "city_hall"
    case clothingStore = "clothing_store"
    case courthouse
    case dentist
    case doctor
    case electronicsStore = "electronics_store"
    case gym
    case hairCare = "hair_care"
    case hardwareStore = "hardware_store"
    case homeGoodsStore = "home_goods_store"
    case hospital
    case insuranceAgency = "insurance_agency"
    case jewelryStore = "jewelry_store"
    case lawyer
    case library
    case localGovernmentOffice = "local_government_office"
    case locksmith
    case lodging
    case mosque = "mosque"
    case movieRental = "movie_rental"
    case movieTheatre = "movie_theatre"
    case movieCompany = "movie_company"
    case museum
    case nightClub = "night_club"
    case painter
    case park
    case petStore = "pet_store"
    case pharmacy
    case physiotherapist
    case plumber
    case police
    case postOffice = "post_office"
    case primarySchool = "primary_school"
    case realEstateAgency = "real_estate_agency"
    case restaurant
    case school
    case secondarySchool = "secondary_school"
    case shoppingMall = "shopping_mall"
    case spa
    case stadium
    case storage
    //case synagogue
    case touristAttraction = "tourist_attraction"
    case travelAgency = "travel_agency"
    case university
    case veterinaryCare = "veterinary_care"
    case zoo

    var displayName: String {
        switch self {
        case .amusementPark:
            return "Amusement Park"
        case .aquarium:
            return "Aquarium"
        case .artGallery:
            return "Art Gallery"
        case .atm:
            return "ATM"
        case .bank:
            return "Bank"
        case .beautySalon:
            return "Beauty Salon"
        case .cafe:
            return "Cafe"
        case .campground:
            return "Campground"
        case .casino:
            return "Casino"
        case .cemetery:
            return "Cemetery"
        case .cityHall:
            return "City Hall"
        case .clothingStore:
            return "Clothing Store"
        case .courthouse:
            return "Courthouse"
        case .dentist:
            return "Dentist"
        case .doctor:
            return "Doctor"
        case .electronicsStore:
            return "Electronics Store"
        case .gym:
            return "Gym"
        case .hairCare:
            return "Hair Care"
        case .hardwareStore:
            return "Hardware Store"
        case .homeGoodsStore:
            return "Home Goods Store"
        case .hospital:
            return "Hospital"
        case .insuranceAgency:
            return "Insurance Agency"
        case .jewelryStore:
            return "Jewelry Store"
        case .lawyer:
            return "Lawyer"
        case .library:
            return "Library"
        case .localGovernmentOffice:
            return "Local Government Office"
        case .locksmith:
            return "Locksmith"
        case .lodging:
            return "Lodging"
        case .mosque:
            return "Mosque"
        case .movieRental:
            return "Movie Rental"
        case .movieTheatre:
            return "Movie Theatre"
        case .movieCompany:
            return "Movie Company"
        case .museum:
            return "Museum"
        case .nightClub:
            return "Night Club"
        case .painter:
            return "Painter"
        case .park:
            return "Park"
        case .petStore:
            return "Pet Store"
        case .pharmacy:
            return "Pharmacy"
        case .physiotherapist:
            return "Physiotherapist"
        case .plumber:
            return "Plumber"
        case .police:
            return "Police"
        case .postOffice:
            return "Post Office"
        case .primarySchool:
            return "Primary School"
        case .realEstateAgency:
            return "Real Estate Agency"
        case .restaurant:
            return "Restaurant"
        case .school:
            return "School"
        case .secondarySchool:
            return "Secondary School"
        case .shoppingMall:
            return "Shopping Mall"
        case .spa:
            return "Spa"
        case .stadium:
            return "Stadium"
        case .storage:
            return "Storage"
//        case .synagogue:
//            return "Synagogue"
        case .touristAttraction:
            return "Tourist Attraction"
        case .travelAgency:
            return "Travel Agency"
        case .university:
            return "University"
        case .veterinaryCare:
            return "Veterinary Care"
        case .zoo:
            return "Zoo"
        }
    }
}

struct PlacesOfInterestRequest: Encodable {
    let key: String
    let radius = 500000
    let location: String
    let type: PlacesOfInterestCategory?
    let pagetoken: String?
    let keyword: String?
    let language: String = currentLanguage.rawValue
}
