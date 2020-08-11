//
//  ImageDownloader.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    private let imageRecord: ImageRecord

    init(_ imageRecord: ImageRecord) {
        self.imageRecord = imageRecord
    }

    override func main() {
        if isCancelled {
          return
        }
        
        guard let imageData = try? Data(contentsOf: imageRecord.url) else { return }
        
        if isCancelled {
          return
        }
        
        if !imageData.isEmpty {
            imageRecord.image = UIImage(data:imageData)!
            imageRecord.state = .downloaded
        } else {
            imageRecord.state = .failed
        }
    }
}
