//
//  DataFetcher.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 09.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import Foundation

class URLFetcher: Operation {
    let url: String
    let networkHelper = NetworkHelper()

    init(_ url: String) {
        self.url = url
    }

    override func main() {
        if isCancelled {
          return
        }
        
//        func fetchData(with completion: @escaping (Int)->()) {
            networkHelper.fetchImagesURL(at: url) { (success, imageURL) in
                if success {
                    print("Image URL \(imageURL)")
//                    let imageRecord = ImageRecord(url: imageURL!)
//                    if let index = self?.imageRecords.count {
//                        self?.imageRecords.append(imageRecord)
//                        completion(index)
//                    }
                } else {
                    print("Fail")
//                    DispatchQueue.main.async {
//                        self?.present(Alerts(reason: .noConnection).alertController!, animated: true, completion: nil)
//                    }
                }
            }
//        }
        
//        guard let imageData = try? Data(contentsOf: imageRecord.url) else { return }
        
        if isCancelled {
          return
        }
        
//        if !imageData.isEmpty {
//            imageRecord.image = UIImage(data:imageData)!
//            imageRecord.state = .downloaded
//        } else {
//            imageRecord.state = .failed
//        }
    }
    
}
