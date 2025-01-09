//
//  APIManagerTests.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 27/12/24.
//

import XCTest
@testable import SpotifyClone

class APIManagerTests: XCTestCase {
    var sut: APIManager!
    
    override func setUp() {
        super.setUp()
        APIManager.setupAPIManager(isTesting: true)
        sut = APIManager.shared
    }
    
    override func tearDown() {
        sut = nil
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        super.tearDown()
    }
    
    func test_createRequest_success() {
        let url = URL(string: "https://example.com/test")
        let expectation = self.expectation(description: "Request creation called")
        
        UserDefaults.standard.set("dummyAccessToken", forKey: AuthManager.Constants.ACCESS_TOKEN)

        sut.createRequest(with: url, type: .GET) { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, HTTPMethod.GET.rawValue)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer dummyAccessToken")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
