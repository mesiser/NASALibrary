//
//  OperationManager.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import Foundation

class OperationManager {
    
    private let pendingOperations = PendingOperations()
    var downloadsToProcess = Set<Dictionary<IndexPath, Operation>.Keys.Element>()
    
//MARK:- Initiating downloads accoring to priority. From lowest (startBackGroundDownload) to highest (startPriorityDownload)
    
    
    func startDownload(of imageRecord: ImageRecord, at indexPath: IndexPath, with priority: Priority, with completion: @escaping (IndexPath)->()) {

        guard
            pendingOperations.downloadsInProgress[indexPath] == nil,
            imageRecord.state == .new
        else{return}
        let downloader = ImageDownloader(imageRecord)

        downloader.completionBlock = {
            if downloader.isCancelled {
              return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.downloadsToProcess.remove(indexPath)
                completion(indexPath)
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = downloader

        switch priority {
        case .high:
            pendingOperations.priorityQueue.addOperation(downloader)
        case .middle:
            pendingOperations.onScreenQueue.addOperation(downloader)
        default:
            pendingOperations.backgroundQueue.addOperation(downloader)
        }
    }
    
//MARK: - Identifying items for priority download
    
    func updateDownloadQueueForPriorityItems(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
              pendingDownload.cancel()
            }
            pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        }
    }
    
//MARK:- Suspending and resuming background downlaods
    
    func suspendBackgroundOperations() {
        pendingOperations.backgroundQueue.isSuspended = true
    }

    func resumeBackgroundOperations() {
        pendingOperations.backgroundQueue.isSuspended = false
    }
}
