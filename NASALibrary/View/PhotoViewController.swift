//
//  PhotoViewController.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = image {
            imageView?.image = image
        }
    }
    
    static func instantiate() -> PhotoViewController? {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      return storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController
    }
}
