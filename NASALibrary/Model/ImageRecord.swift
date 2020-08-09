//
//  ImageRecord.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

enum ImageRecordState {
  case new, downloaded, failed
}

class ImageRecord {
  let url: URL
  var state = ImageRecordState.new
  var image = UIImage(named: "NASA")
  
  init(url:URL) {
    self.url = url
  }
}
