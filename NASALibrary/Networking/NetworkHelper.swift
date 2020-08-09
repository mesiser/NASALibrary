//
//  NetworkHelper.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class NetworkHelper {
    
    func fetchImagesURL(at url: String, with completion: @escaping (URL) -> ()) {
        guard let url = URL(string: url) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
             guard
                 let httpURLResponse = response as? HTTPURLResponse,
                 httpURLResponse.statusCode == 200,
                 let data = data, error == nil
                 else { return }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data)
                guard
                    let dictionary = jsonResponse as? [String: Any],
                    let collection = dictionary["collection"] as? [String:Any],
                    let items = collection["items"] as? [Any]
                else {return}
                for index in 0...items.count - 1 {
                    guard
                        let item = items[index] as? [String: Any],
                        let links = item["links"] as? [Any],
                        let link = links[0] as? [String: Any],
                        var imageURLString = (link["href"] as? String)
                    else {return}
                    if imageURLString.contains(" ") {
                        imageURLString = imageURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    }
                    if let imageURL = URL(string: imageURLString) {
                        completion(imageURL)
                    }
                }

            } catch {
                print("Error getting images' urls")
            }
        }.resume()
    }
}
