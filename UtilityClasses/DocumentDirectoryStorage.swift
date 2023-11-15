//
//  LocalStorage.swift
//  RCRC
//
//  Created by Errol on 13/08/20.
//

import Foundation
import UIKit

class DocumentDirectoryStorage {

    static func getPath() -> NSString {

        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        return path as NSString
    }

    // Create new folder in Document directory
    static func createFolder(folderName: String?) -> Bool {

        let fileManager = FileManager.default
        let path = getPath().appendingPathComponent(folderName ?? "New Folder")
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        } else {
            return true
        }
    }

    // Delete a folder from document directory
    static func deleteFolder(folderName: String) -> Bool {

        let fileManager = FileManager.default
        let path = getPath().appendingPathComponent(folderName)
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }

    // Save image in document directory
    static func saveImage(image: UIImage, imageFilename: String) {

        let fileManager = FileManager.default
        let path = getPath().appendingPathComponent(imageFilename)
        let imageType = imageFilename.fileExtension()
        if imageType == "jpg" || imageType == "jpeg" {
            let imageData = image.jpegData(compressionQuality: 0.5)
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        } else {
            let imageData = image.pngData()
            fileManager.createFile(atPath: path as String, contents: imageData, attributes: nil)
        }
    }

    // Delete image from document directory
    static func deleteImage(imageFilename: String) -> Bool {
        let fileManager = FileManager.default
        let path = getPath().appendingPathComponent(imageFilename)
        do {
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
}
