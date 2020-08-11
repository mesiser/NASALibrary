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
    var networkHelper: NetworkHelper!
    var urlSession: URLSession!

    override func setUpWithError() throws {
        super.setUp()
        let url = URL(string: "https://www.nasa.gov/sites/default/files/thumbnails/image/44343884472_899f141b0e_k.jpg")
        let imageRecord = ImageRecord(url: url!)
        imageDownloader = ImageDownloader(imageRecord)
        networkHelper = NetworkHelper()
        urlSession = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        imageDownloader = nil
        networkHelper = nil
        urlSession = nil
        super.tearDown()
    }
    
    func testSearchResultsProcessing() {
        let promise = expectation(description: "Status code: 200")
        XCTAssertEqual(networkHelper.processedURLCount, 0, "Number of search results shall be 0")
        let url = URL(string: "https://images-api.nasa.gov/search?q=&page=1&media_type=image")
        let dataTask = urlSession.dataTask(with: url!) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    self.networkHelper.processSearchResults(with: data!) { (_, _, _) in
                    }
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        XCTAssertEqual(networkHelper.totalURLs, 100, "Didn't parse the items from fake response")
    }
    
    func testDownloadPerformance() {
        measure {
          self.imageDownloader.main()
        }
    }
}
