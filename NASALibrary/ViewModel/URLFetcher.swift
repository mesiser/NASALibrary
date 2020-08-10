//
//  DataFetcher.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 09.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import Foundation

class URLFetcher: Operation {
    
    private let networkHelper = NetworkHelper()
    
    func getImagesURLS(from url: String, with completion: @escaping (Bool, Reason?, URL?)->()) {
        guard networkHelper.isInternetAvailable() else {
            DispatchQueue.main.async {
                completion(false, .noInternet, nil)
            }
            return
        }
        networkHelper.fetchImagesURL(at: url) { (success, imageURL) in
            if success {
                completion(true, nil, imageURL)
            } else {
                completion(false, .noConnection, nil)
            }
        }
    }
}
