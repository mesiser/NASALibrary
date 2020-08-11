//
//  Alerts.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 09.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

enum Reason {
    case noConnection, noInternet, parsingFailure, noResults
}

class Alerts {
    
    var alertController: UIAlertController?
    private let okAction = UIAlertAction(title: "OK", style: .default)
    private let noInternet = "Please check your internet connection 🙏"
    private let noConnection = "Can't reach NASA servers 🧑‍🚀"
    private let failure = "Problem occured, we're on it already 🦸‍♂️"
    private let noResults = "No results. Please try another search 🔍"
    
    init(reason: Reason) {
        var message: String?
        switch reason {
        case .noConnection:
            message = noConnection
        case .noInternet:
            message = noInternet
        case .parsingFailure :
            message = failure
        case .noResults:
            message = noResults
        }
        alertController = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alertController?.addAction(okAction)
    }
}
