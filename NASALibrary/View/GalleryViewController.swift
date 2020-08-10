//
//  GalleryViewController.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 07.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

class GalleryViewController: UICollectionViewController, UISearchBarDelegate {
    
    private let urlFetcher = URLFetcher()
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
    
    override func viewDidAppear(_ animated: Bool) {
        setToolBar()
        super.viewDidAppear(animated)
    }
    
//MARK:- Fetching images URLs
    
    func getImagesURLS() {
        nasaURL += query + "&page=\(pageNumber)&media_type=image"
        print(nasaURL)
        urlFetcher.getImagesURLS(from: nasaURL) { [weak self] (success, reason, imageURL) in
            if success {
                let imageRecord = ImageRecord(url: imageURL!)
                if let index = self?.imageRecords.count {
                    self?.imageRecords.append(imageRecord)
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                    let indexPath = IndexPath(row: index, section: 0)
                    self?.downloadImage(at: indexPath, withPriority: .low, with: nil)
                }
            } else {
                self?.setUpFakeImages()
                DispatchQueue.main.async {
                    self?.present(Alerts(reason: reason!).alertController!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setUpFakeImages() {
        for _ in 0...100 {
            let imageRecord = ImageRecord(url: URL(string: "https://images-api.nasa.gov/search?q=")!)
            imageRecords.append(imageRecord)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
             }
        }
    }
    
//MARK:- Donwloading images
    
    func downloadImage(at indexPath: IndexPath, withPriority priority: Priority, with completion: ((IndexPath)->())?) {
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
        operationManager.suspendBackgroundOperations()
        operationManager.updateDownloadQueueForPriorityItems(at: indexPaths)
        for indexPath in indexPaths {
            downloadImage(at: indexPath, withPriority: .middle) { [weak self] _ in
                if indexPath == indexPaths.last {
                    self?.operationManager.resumeBackgroundOperations()
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
        reloadData(with: searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Typing")
        if operationManager.operationsSuspended == false {
            operationManager.suspendAllOperations()
        }
    }
    
//MARK:- Обнуление 😇
    
    func reloadData(with query: String) {
        guard self.query.lowercased() != query.lowercased() else{return}
        imageRecords = [ImageRecord]()
        collectionView.reloadData()
        operationManager.reset()
        pageNumber = 1
        nasaURL = "https://images-api.nasa.gov/search?q="
        self.query = query
        getImagesURLS()
        operationManager.resumeAllOperations()
        scrollToTop()
    }
}

//MARK:- TO DO

//1. Resize images (on a different operation queue)
//3. Weak self
