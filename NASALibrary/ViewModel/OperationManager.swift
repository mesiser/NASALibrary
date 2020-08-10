//
//  OperationManager.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class OperationManager {
    
    private let pendingOperations = PendingOperations()
    private let imageCache = NSCache<NSString, UIImage>()
    var operationsSuspended = false
    var downloadsToProcess = Set<Dictionary<IndexPath, Operation>.Keys.Element>()
    
//MARK:- Initiating downloads accoring to priority. From lowest (startBackGroundDownload) to highest (startPriorityDownload)

    
    func startDownload(of imageRecord: ImageRecord, at indexPath: IndexPath, with priority: Priority, with completion: @escaping (IndexPath)->()) {

        guard
            pendingOperations.downloadsInProgress[indexPath] == nil,
            imageRecord.state == .new
        else{return}
        
        if checkIfImageExistsInCache(for: imageRecord) {
            completion(indexPath)
        }
        let downloader = ImageDownloader(imageRecord)

        downloader.completionBlock = {
            if downloader.isCancelled {
              return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.downloadsToProcess.remove(indexPath)
                self.imageCache.setObject(imageRecord.image!, forKey: imageRecord.url.absoluteString as NSString)
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
    
    func checkIfImageExistsInCache(for imageRecord: ImageRecord) -> Bool {
        if let cachedImage = self.imageCache.object(forKey: imageRecord.url.absoluteString as NSString) {
            print("Image was cached before")
            imageRecord.image = cachedImage
            imageRecord.state = .downloaded
            return true
        } else {
            return false
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
    
    func suspendAllOperations() {
        operationsSuspended = true
        pendingOperations.backgroundQueue.isSuspended = true
        pendingOperations.onScreenQueue.isSuspended = true
        pendingOperations.priorityQueue.isSuspended = true

    }
    
    func resumeAllOperations() {
        pendingOperations.backgroundQueue.isSuspended = false
        pendingOperations.onScreenQueue.isSuspended = false
        pendingOperations.priorityQueue.isSuspended = false
        operationsSuspended = false
    }
    
    func reset() {
        pendingOperations.backgroundQueue.cancelAllOperations()
        pendingOperations.onScreenQueue.cancelAllOperations()
        pendingOperations.priorityQueue.cancelAllOperations()
        downloadsToProcess = Set<Dictionary<IndexPath, Operation>.Keys.Element>()
    }
}

/*
 //                switch priority {
 //                case .high:
 //                    print("Priority download completed")
 //                case .middle:
 //                    print("Middle download completed")
 //                    print(self.pendingOperations.backgroundQueue.isSuspended)
 //                default:
 //                    print("Background download completed")
 //                }
 */
