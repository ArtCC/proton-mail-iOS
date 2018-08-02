//
//  ImageProcessor.swift
//  ProtonMail
//
//  Created by Anatoly Rosencrantz on 28/06/2018.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import Foundation
import Photos

protocol ImageProcessor {
    func process(original originalImage: UIImage)
    func process(asset: PHAsset)
}
extension ImageProcessor where Self: AttachmentProvider {
    
    private func writeItemToTempDirectory(_ item: Data, filename: String) throws -> URL {
        let tempFileUrl = try FileManager.default.createTempURL(forCopyOfFileNamed: filename)
        try item.write(to: tempFileUrl)
        return tempFileUrl
    }
    
    internal func process(original originalImage: UIImage) {
        let fileName = "\(NSUUID().uuidString).PNG"
        let ext = "image/png"
        var fileData: FileData!

        #if APP_EXTENSION
            guard let data = UIImagePNGRepresentation(originalImage),
                let newUrl = try? self.writeItemToTempDirectory(data, filename: fileName) else
            {
                self.controller.error(NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil).description)
                return
            }
            fileData = ConcreteFileData<URL>(name: fileName, ext: ext, contents: newUrl)
        #else
            fileData = ConcreteFileData<UIImage>(name: fileName, ext: ext, contents: originalImage)
        #endif
        
        self.controller.finish(fileData)
    }
    
    internal func process(asset: PHAsset) {
        switch asset.mediaType {
        case .video:
            let options = PHVideoRequestOptions()
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { asset, audioMix, info in
                if let error = info?[PHImageErrorKey] as? NSError {
                    self.controller.error(error.debugDescription)
                    return
                }
                guard let asset = asset as? AVURLAsset, let image_data = try? Data(contentsOf: asset.url) else {
                    self.controller.error(LocalString._cant_open_the_file)
                    return
                }
                
                let fileName = asset.url.lastPathComponent
                let fileData = ConcreteFileData<Data>(name: fileName, ext: fileName.mimeType(), contents: image_data)
                self.controller.finish(fileData)
            })
            
        default:
            let options = PHImageRequestOptions()
            PHImageManager.default().requestImageData(for: asset, options: options) { imagedata, dataUTI, orientation, info in
                guard var image_data = imagedata, /* let _ = dataUTI,*/ let info = info, image_data.count > 0 else {
                    self.controller.error(LocalString._cant_open_the_file)
                    return
                }
                var fileName = "\(NSUUID().uuidString).jpg"
                if let url = info["PHImageFileURLKey"] as? NSURL, let url_filename = url.lastPathComponent {
                    fileName = url_filename
                }
                
                if fileName.preg_match(".(heif|heic)") {
                    if let rawImage = UIImage(data: image_data) {
                        if let newData = UIImageJPEGRepresentation(rawImage, 1.0), newData.count > 0 {
                            image_data =  newData
                            fileName = fileName.preg_replace(".(heif|heic)", replaceto: ".jpeg")
                        }
                    }
                }
                let fileData = ConcreteFileData<Data>(name: fileName, ext: fileName.mimeType(), contents: image_data)
                self.controller.finish(fileData)
            }
        }
    }
}
