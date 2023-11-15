//
//  DocumentDirectoryStorageTests.swift
//  Riyadh Journey PlannerTests
//
//  Created by Errol on 04/06/21.
//

import XCTest
@testable import Riyadh_Journey_Planner

class DocumentDirectoryStorageTests: XCTestCase {

    func test_getPath_returnsSomePathToDocumentDirectory() {
        XCTAssertNotEqual(DocumentDirectoryStorage.getPath(), "")
    }

    func test_createFolderInDocumentDirectory_returnsTrueOnCreation() {
        XCTAssertTrue(DocumentDirectoryStorage.createFolder(folderName: "Folder Name"))
    }

    func test_deleteFolderInDocumentDirectory_returnsTrueOnDeletion() {
        _ = DocumentDirectoryStorage.createFolder(folderName: "Folder Name")
        XCTAssertTrue(DocumentDirectoryStorage.deleteFolder(folderName: "Folder Name"))
    }

    func test_deleteFolderInDocumentDirectory_returnsFalseIfFolderDoesNotExists() {
        XCTAssertFalse(DocumentDirectoryStorage.deleteFolder(folderName: "Folder"))
    }

    func test_saveAndDeleteJpegImage() {
        let image = UIImage()
        let imageName = "image.jpeg"

        DocumentDirectoryStorage.saveImage(image: image, imageFilename: imageName)

        XCTAssertTrue(DocumentDirectoryStorage.deleteImage(imageFilename: imageName))
    }

    func test_saveAndDeleteJpgImage() {
        let image = UIImage()
        let imageName = "image.jpg"

        DocumentDirectoryStorage.saveImage(image: image, imageFilename: imageName)

        XCTAssertTrue(DocumentDirectoryStorage.deleteImage(imageFilename: imageName))
    }

    func test_saveAndDeletePngImage() {
        let image = UIImage()
        let imageName = "image.png"

        DocumentDirectoryStorage.saveImage(image: image, imageFilename: imageName)

        XCTAssertTrue(DocumentDirectoryStorage.deleteImage(imageFilename: imageName))
    }
}
