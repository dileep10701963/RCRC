//
//  MediaPickerController.swift
//  RCRC
//
//  Created by Errol on 26/07/21.
//

import UIKit
import MobileCoreServices
import AVFoundation

enum Media {
    case image(UIImage)
    case video(_ data: NSData, _ thumbnail: UIImage)
}

final class MediaPickerController: NSObject {
    private let imagePicker: UIImagePickerController
    private let viewController: UIViewController
    private var completion: ((Media) -> Void)?

    init(viewController: UIViewController) {
        self.viewController = viewController
        self.imagePicker = UIImagePickerController()
    }

    /// Selection of Media either from Camera or Gallery
    /// - Parameter completion: On selection, returns the selected Media (image/video with thumbnail)
    func loadMedia(completion: @escaping (Media) -> Void) {
        self.completion = completion
        imagePicker.delegate = self
        if #available(iOS 14.0, *) {
            imagePicker.mediaTypes = [UTType.image.identifier, UTType.jpeg.identifier]
            //imagePicker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier, UTType.jpeg.identifier]
        } else {
            imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeJPEG as String]
            //imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String, kUTTypeJPEG as String]
        }

        let alertController = UIAlertController(title: emptyString, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: Constants.camera, style: .default) { [weak self] _ in
            self?.launchCamera()
        }
//        let galleryAction = UIAlertAction(title: Constants.gallery, style: .default) { [weak self] _ in
//            self?.launchGallery()
//        }
        let cancelAction = UIAlertAction(title: cancel.localized, style: .cancel, handler: nil)

        alertController.addAction(cameraAction)
//        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }

    private func launchCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            viewController.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: Constants.cameraErrorAlertTitle, message: Constants.cameraErrorAlertMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: ok.localized, style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    private func launchGallery() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        viewController.present(imagePicker, animated: true, completion: nil)
    }
}

extension MediaPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            completion?(.image(image))
        } else if let videoPath = info[.mediaURL] as? NSURL,
                  let video = NSData(contentsOf: videoPath as URL) {
            let asset = AVURLAsset(url: videoPath as URL, options: nil)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                completion?(.video(video, thumbnail))
            } catch {
                viewController.showCustomAlert(alertTitle: "Error".localized, alertMessage: "Error occured. Unable to attach video".localized, firstActionTitle: ok, firstActionStyle: .default)
            }
        }
        viewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    func compressedData() -> Data? {
        let maxHeight: CGFloat = 568
        let maxWidth: CGFloat = 320

        var actualHeight = size.height
        var actualWidth = size.width

        var imgRatio = actualWidth / actualHeight
        let maxRatio = maxWidth / maxHeight
        var compressionQuality : CGFloat = 0.4

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
                compressionQuality = 1
            }
        }

        guard let cgImage = cgImage else { return nil }

        let mutableData = NSMutableData()
        guard let imageDestinationRef = CGImageDestinationCreateWithData(mutableData as CFMutableData, kUTTypeJPEG, 1, nil) else { return nil }
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImage(imageDestinationRef, cgImage, options)
        guard CGImageDestinationFinalize(imageDestinationRef) else { return nil }
        return mutableData as Data
    }
}
