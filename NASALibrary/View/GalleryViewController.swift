//
//  GalleryViewController.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class GalleryViewController: UICollectionViewController {
    
    private let networkHelper = NetworkHelper()
    private var nasaURL = "https://images-api.nasa.gov/search?q="
    private var query = ""
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
    
//MARK:- Fetching data from the server
    
    func getImagesURLS() {
        guard networkHelper.isInternetAvailable() else {
            DispatchQueue.main.async {
                self.present(Alerts(reason: .noInternet).alertController!, animated: true, completion: nil)
            }
            return
        }
        fetchData() { (index) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            let indexPath = IndexPath(row: index, section: 0)
            self.downloadImage(at: indexPath, with: .low, with: nil)
        }
    }
    
    func fetchData(with completion: @escaping (Int)->()) {
        nasaURL += query + "&page=\(pageNumber)&media_type=image"
        networkHelper.fetchImagesURL(at: nasaURL) { [weak self] (success, imageURL) in
            if success {
                let imageRecord = ImageRecord(url: imageURL!)
                if let index = self?.imageRecords.count {
                    self?.imageRecords.append(imageRecord)
                    completion(index)
                }
            } else {
                DispatchQueue.main.async {
                    self?.present(Alerts(reason: .noConnection).alertController!, animated: true, completion: nil)
                }
            }
        }
    }
    
//MARK:- Donwloading images
    
    func downloadImage(at indexPath: IndexPath, with priority: Priority, with completion: ((IndexPath)->())?) {
        if operationManager.downloadsToProcess.contains(indexPath) == false {
            operationManager.downloadsToProcess.insert(indexPath)
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
            downloadImage(at: indexPath, with: .middle) { _ in
                self.operationManager.resumeBackgroundOperations()
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
}

//MARK:- TO DO

//1. Resize images (on a different operation queue)
//2. Cache images
//3. Weak self
//4. Search window
//5. Alerts
