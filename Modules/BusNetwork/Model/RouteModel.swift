//
//  RouteModel.swift
//  RCRC
//
//  Created by Aashish Singh on 01/03/23.
//

import Foundation
import UIKit
//
struct RouteModel: Codable {
    let items: [RouteModelItem]?
    let lastPage, page, pageSize, totalCount: Int?
}

// MARK: - Get
struct RouteModelGet: Codable {
    let method: RouteModelMethod?
    let href: String?
}

enum RouteModelMethod: String, Codable {
    case delete = "DELETE"
    case methodGET = "GET"
    case patch = "PATCH"
    case put = "PUT"
}

// MARK: - Item
struct RouteModelItem: Codable {
    let actions: RouteModelItemActions?
    let availableLanguages: [String]?
    let contentFields: [RouteModelContentField]?
    let contentStructureID: Int?
    let dateCreated, dateModified, datePublished: String?
    let description, friendlyURLPath: String?
    let id: Int?
    let key: String?
    let numberOfComments: Int?
    let renderedContents: [RouteModelRenderedContent]?
    let siteID: Int?
    let subscribed: Bool?
    let title, uuid: String?

    enum CodingKeys: String, CodingKey {
        case actions, availableLanguages, contentFields
        case contentStructureID = "contentStructureId"
        case dateCreated, dateModified, datePublished, description
        case friendlyURLPath = "friendlyUrlPath"
        case id, key, numberOfComments, renderedContents
        case siteID = "siteId"
        case subscribed, title, uuid
    }
}

// MARK: - ItemActions
struct RouteModelItemActions: Codable {
    let getRenderedContent, subscribe, unsubscribe, actionsGet: RouteModelGet?
    let replace, update, delete: RouteModelGet?

    enum CodingKeys: String, CodingKey {
        case getRenderedContent = "get-rendered-content"
        case subscribe, unsubscribe
        case actionsGet = "get"
        case replace, update, delete
    }
}

// MARK: - ContentField
struct RouteModelContentField: Codable {
    let contentFieldValue: RouteModelContentFieldValue?
    let dataType: String?
    let label: String?
    let name: String?
    let repeatable: Bool?
    let inputControl: String?
     
}

// MARK: - ContentFieldValue
struct RouteModelContentFieldValue: Codable {
    let image: RouteModelGetImage?
    let data: String?
}

// MARK: - Image
struct RouteModelGetImage: Codable {
    let contentType: String?
    let contentURL, description: String?
    let encodingFormat: String?
    let fileExtension: String?
    let id, sizeInBytes: Int?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case contentType
        case contentURL = "contentUrl"
        case description, encodingFormat, fileExtension, id, sizeInBytes, title
    }
}

// MARK: - RenderedContent
struct RouteModelRenderedContent: Codable {
    let renderedContentURL: String
}

extension RouteModel{
    
   
   private func getModel(compareValue:String)->RouteModelItem?  {
        
       for routeItemModel in self.items!{
            
            
           for modelContentField in routeItemModel.contentFields! {
               
               if modelContentField.contentFieldValue?.data == compareValue {
                   return routeItemModel
               }
               }
           }
        
        return nil
    }
    
    func getSourceDestination_colorCode(routeNumber:String)->(String,String)  {
        
        var strTitle = ""
        var strColorCode = ""
        guard let model = getModel(compareValue: routeNumber) else{
            return (strTitle,strColorCode)
        }
        
        
        
        if let modelTitle = model.contentFields?.first(where: {$0.label?.lowercased() == "Heading".lowercased()}) {
            strTitle = modelTitle.contentFieldValue?.data ?? emptyString
        }
        if let modelColorCode = model.contentFields?.first(where: {$0.label?.lowercased() == "ColorCode".lowercased()}) {
            
            strColorCode = modelColorCode.contentFieldValue?.data ?? emptyString
        }
        
        return (strTitle,strColorCode)
        
    
    }
    
    
     func getSourceDestination(index: Int) -> String {
        if let model = self.items?[index].contentFields?.first(where: {$0.label?.lowercased() == "Heading".lowercased()}) {
            return model.contentFieldValue?.data ?? emptyString
        } else {
            return emptyString
        }
    }
    
     func getTackColor(index: Int) -> UIColor {
        if let model = self.items?[index].contentFields?.first(where: {$0.label?.lowercased() == "Colorcode".lowercased()}) {
            let strColor:String = model.contentFieldValue?.data ?? emptyString
            return strColor.hexToUIColor()
        } else {
            return UIColor()
        }
    }
    
     func getRouteNumber(index: Int) -> String {
        if let model = self.items?[index].contentFields?.first(where: {$0.label?.lowercased() == "Route Number".lowercased()}) {
            return model.contentFieldValue?.data ?? emptyString
        } else {
            return emptyString
        }
    }
   
}
