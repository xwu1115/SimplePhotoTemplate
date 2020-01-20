//
//  PhotoEditViewModel.swift
//  PhotoEditKit
//
//  Created by Shawn Wu on 1/11/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit

enum Option {
    case text
    case background
    case photo
    
    var name: String {
        switch self {
        case .text:
            return "Add Text"
        case .background:
            return "Background"
        case .photo:
            return "Add Photo"
        }
    }
}

protocol PhotoEditViewModelDelegate: AnyObject {
    func savePhotoDidComplete(error: Error?)
}

class PhotoEditViewModel: NSObject {
    let options: [Option] = [.text, .background, .photo]
    var selectedOption: Option?
    
    weak var delegate: PhotoEditViewModelDelegate?
    
    func savePhotoToCameraRoll(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    @objc func image(_: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        delegate?.savePhotoDidComplete(error: error)
    }
}
