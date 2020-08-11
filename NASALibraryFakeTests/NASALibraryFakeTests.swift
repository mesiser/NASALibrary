//
//  NASALibraryFakeTests.swift
//  NASALibraryFakeTests
//
//  Created by Vadim Shalugin on 10.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import XCTest
@testable import NASALibrary

class NASALibraryFakeTests: XCTestCase {
    
    var imageDownloader: ImageDownloader!
    var operationManager: OperationManager!
    var networkHelper: NetworkHelper!
    var gallery: GalleryViewController!
    var urlSession: URLSession!

    override func setUpWithError() throws {
        super.setUp()
        let url = URL(string: "https://www.nasa.gov/sites/default/files/thumbnails/image/44343884472_899f141b0e_k.jpg")
        let imageRecord = ImageRecord(url: url!)
        imageDownloader = ImageDownloader(imageRecord)
        networkHelper = NetworkHelper()
        operationManager = OperationManager()
        gallery = GalleryViewController()
        urlSession = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        imageDownloader = nil
        networkHelper = nil
        urlSession = nil
        operationManager = nil
        gallery = nil
        super.tearDown()
    }
    
    func testSearchResultsProcessing() {
        let promise = expectation(description: "Status code: 200")
        XCTAssertEqual(networkHelper.totalURLs, 0, "Number of search results shall be 0")
        let url = URL(string: "https://images-api.nasa.gov/search?q=&page=1&media_type=image")
        let dataTask = urlSession.dataTask(with: url!) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    self.networkHelper.processSearchResults(with: data!) { (_, _, _, _) in
                    }
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(networkHelper.totalURLs, 100, "Didn't parse 100 items from fake response")
    }
    
    func testSuspendingOperations() {
        let promise = expectation(description: "All operations suspended")
        operationManager.suspendAllOperations()
        promise.fulfill()
        wait(for: [promise], timeout: 5)
        XCTAssertTrue(operationManager.pendingOperations.backgroundQueue.isSuspended)
        XCTAssertTrue(operationManager.pendingOperations.onScreenQueue.isSuspended)
        XCTAssertTrue(operationManager.pendingOperations.priorityQueue.isSuspended)
    }
    
    func testResumingOperations() {
        let promise = expectation(description: "All operations resumed")
        operationManager.resumeAllOperations()
        promise.fulfill()
        XCTAssertFalse(operationManager.pendingOperations.backgroundQueue.isSuspended)
        XCTAssertFalse(operationManager.pendingOperations.onScreenQueue.isSuspended)
        XCTAssertFalse(operationManager.pendingOperations.priorityQueue.isSuspended)
        wait(for: [promise], timeout: 5)
    }
    
    func testReloadingGalleryAfterSearch() {
        let promise = expectation(description: "Gallery successfully reloaded")
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        gallery.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        layout.scrollDirection = UICollectionView.ScrollDirection.vertical
        gallery.collectionView.setCollectionViewLayout(layout, animated: false)
        gallery.reloadData(with: "Gagarin")
        networkHelper.getImagesURLs(from: "https://images-api.nasa.gov/search?q=\(gallery.query)&page=1&media_type=image") { (success, reason, imageURL, totalURLs) in
            if success {
                let imageRecord = ImageRecord(url: imageURL!)
                self.gallery.imageRecords.append(imageRecord)
                if self.gallery.imageRecords.count == totalURLs {
                    promise.fulfill()
                }
            }
        }
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(gallery.imageRecords.count, 100, "Couldn't reload gallery")
    }
    
    func testDownloadPerformance() {
        measure {
          self.imageDownloader.main()
        }
    }
}
