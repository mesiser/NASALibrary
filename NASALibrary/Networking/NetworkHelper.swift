//
//  NetworkHelper.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit
import SystemConfiguration

class NetworkHelper {
    
    func isInternetAvailable() -> Bool {
          var zeroAddress = sockaddr_in()
          zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
          zeroAddress.sin_family = sa_family_t(AF_INET)

          let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
              $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                  SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
              }
          }

          var flags = SCNetworkReachabilityFlags()
          if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
              return false
          }
          let isReachable = flags.contains(.reachable)
          let needsConnection = flags.contains(.connectionRequired)
          return (isReachable && !needsConnection)
      }
    
    func fetchImagesURL(at url: String, with completion: @escaping (Bool, URL?) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpURLResponse = response as? HTTPURLResponse {
                print("Response status code is \(httpURLResponse.statusCode)")
            }
             guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let data = data, error == nil
             else {completion(false, nil); return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data)
                guard
                    let dictionary = jsonResponse as? [String: Any],
                    let collection = dictionary["collection"] as? [String:Any],
                    let items = collection["items"] as? [Any],
                    items.count > 0
                else {completion(false, nil);return}
                for index in 0...items.count - 1 {
                    guard
                        let item = items[index] as? [String: Any],
                        let links = item["links"] as? [Any],
                        let link = links[0] as? [String: Any],
                        var imageURLString = (link["href"] as? String)
                    else {completion(false, nil); return}
                    if imageURLString.contains(" ") {
                        imageURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    }
                    if let imageURL = URL(string: imageURLString) {
                        completion(true, imageURL)
                    }
                }

            } catch {
                completion(false, nil)
            }
        }.resume()
    }
}
