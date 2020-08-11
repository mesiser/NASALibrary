//
//  GalleryViewController.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class GalleryViewController: UICollectionViewController, UISearchBarDelegate {
    
    private let networkHelper = NetworkHelper()
    private var nasaURL = "https://images-api.nasa.gov/search?q="
    var query = ""
    let operationManager = OperationManager()
    var imageRecords = [ImageRecord]()
    var pageNumber = 1
    let cellSpacing: CGFloat = 1
    let columns: CGFloat = 2
    var cellSize: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "NASA Photos"
        getImagesURLS()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setToolBar()
        super.viewDidAppear(animated)
    }
    
//MARK:- Fetching images URLs
    
    func getImagesURLS() {
        nasaURL += query + "&page=\(pageNumber)&media_type=image"
        networkHelper.getImagesURLs(from: nasaURL) { [weak self] (success, reason, imageURL, totalURLs) in
            if success {
                let imageRecord = ImageRecord(url: imageURL!)
                self?.imageRecords.append(imageRecord)
                if self?.imageRecords.count == totalURLs {
                    print("All urls downloaded successfully 🥳")
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                        for index in 0...(self?.imageRecords.count)! - 1 {
                            let indexPath = IndexPath(row: index, section: 0)
                            self?.downloadImage(at: indexPath, withPriority: .low, with: nil)
                        }
                    }
            } else {
                DispatchQueue.main.async {
                    self?.present(Alerts(reason: reason!).alertController!, animated: true, completion: nil)
                }
            }
        }
    }
    
//MARK:- Donwloading images
    
    func downloadImage(at indexPath: IndexPath, withPriority priority: Priority, with completion: ((IndexPath)->())?) {
        if operationManager.operationsSuspended {
            operationManager.resumeAllOperations()
        }
        let imageRecord = imageRecords[indexPath.row]
        operationManager.startDownload(of: imageRecord, at: indexPath, with: priority) { [weak self] (downloadedImageIndexPath) in
            self?.insertImageInCollection(at: downloadedImageIndexPath)
            completion?(downloadedImageIndexPath)
        }
    }
    
    func downloadImagesForVisibleCells() {
        let indexPaths = collectionView.indexPathsForVisibleItems
        operationManager.updateDownloadQueueForPriorityItems(at: indexPaths)
        for indexPath in indexPaths {
            if imageRecords[indexPath.row].state == .new {
                if operationManager.pendingOperations.backgroundQueue.isSuspended == false {
                    operationManager.suspendBackgroundOperations()
                }
                downloadImage(at: indexPath, withPriority: .middle) { [weak self] _ in
                    if indexPath == indexPaths.last {
                        self?.operationManager.resumeBackgroundOperations()
                    }
                }
            }
        }
    }
    
//MARK:- Updating collection view with downloaded images
    
    func insertImageInCollection(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
//MARK:- Navigation
    
    func showFullSizePhoto(for image: UIImage) {
        guard let photoViewController = PhotoViewController.instantiate() else {
          return
        }
        photoViewController.image = image
        collectionView.allowsSelection = true
        navigationController?.pushViewController(photoViewController, animated: true)
    }
    
//MARK:- Search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let query = searchBar.text, self.query.lowercased() != query {
            reloadData(with: query)
            getImagesURLS()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if operationManager.operationsSuspended == false {
            operationManager.suspendAllOperations()
        }
    }
    
//MARK:- Обнуление 😇
    
    func reloadData(with query: String) {
        operationManager.suspendAllOperations()
        operationManager.reset()
        imageRecords = [ImageRecord]()
        networkHelper.totalURLs = 0
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        pageNumber = 1
        nasaURL = "https://images-api.nasa.gov/search?q="
        self.query = query
    }
}

//MARK:- TO DO

//1. Resize images (on a different operation queue)
//3. Weak self

//Remove toolbar when scrooled to top and show toolbar after coming back from the will image view

