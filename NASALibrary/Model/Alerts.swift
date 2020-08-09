//
//  Alerts.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 09.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

enum reason {
    case noConnection, noInternet
}

class Alerts {
    
    var alertController: UIAlertController?
    private let okAction = UIAlertAction(title: "OK", style: .default)
    private let noInternet = "Please check your internet connection"
    private let noConnection = "Can't reach NASA servers"
    
    init(reason: reason) {
        var message: String?
        switch reason {
        case .noConnection:
            message = noConnection
        case .noInternet:
            message = noInternet
        }
        alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alertController?.addAction(okAction)
    }
}
