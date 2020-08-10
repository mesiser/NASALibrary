//
//  NASALibrarySlowTests.swift
//  NASALibrarySlowTests
//
//  Created by Vadim Shalugin on 10.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import XCTest
@testable import NASALibrary

class NASALibrarySlowTests: XCTestCase {
    
    var urlSession: URLSession!

    override func setUpWithError() throws {
        super.setUp()
        urlSession = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        urlSession = nil
        super.tearDown()
    }

    func testCallToNASAWithTimeOut() {
        let url = URL(string: "https://images-api.nasa.gov/search?q=&page=1&media_type=image")
        let promise = expectation(description: "Status code: 200")

        let dataTask = urlSession.dataTask(with: url!) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }
      dataTask.resume()
      wait(for: [promise], timeout: 5)
    }
    
    func testCallToNASAStatusCode() {
        let url = URL(string: "https://images-api.nasa.gov/search?q=&page=1&media_type=image")
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?

        let dataTask = urlSession.dataTask(with: url!) { data, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)

        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}
