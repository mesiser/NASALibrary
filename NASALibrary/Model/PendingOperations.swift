//
//  PendingOperations.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import Foundation

enum Priority {
    case low, middle, high
}

class PendingOperations {
    var backgroundDownloadsInProgress: [IndexPath: Operation] = [:]
    var onScreenDownloadsInProgress: [IndexPath:Operation] = [:]
    var priorityDownloadsInProgress: [IndexPath: Operation] = [:]
    var downloadsInProgress: [IndexPath: Operation] = [:]
    
    lazy var backgroundQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .default
        return queue
    }()
    
    lazy var onScreenQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "On screen queue"
        queue.maxConcurrentOperationCount = 10
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    lazy var priorityQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Priority queue"
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
}
