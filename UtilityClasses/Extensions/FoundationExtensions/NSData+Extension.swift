//
//  NSData+Extension.swift
//  RCRC
//
//  Created by Ganesh on 15/07/21.
//

import Foundation

extension NSData {
    func convertToBase64String() -> String {
        let strBase64 = self.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }

    // Get filesize in MB
    func getFileSize() -> Float {
        let fileSize = Float(Double(self.count)/1024/1024)
        return fileSize
    }
}

extension Data {
    func convertToBase64String() -> String {
        let strBase64 = self.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }

    // Get filesize in MB
    func getFileSize() -> Float {
        let fileSize = Float(Double(self.count)/1024/1024)
        return fileSize
    }
    
    func getFileSizeInBytes() -> Float {
        let fileSize = Float(Double(self.count))
        return fileSize
    }
    
    
}
