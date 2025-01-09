//
//  APIClientTests.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 26/12/24.
//

import XCTest
@testable import SpotifyClone

class APIClientTests: XCTestCase {
    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        sut = MockAPIClient()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_fetchData_success() {
        let mockResponseDict: [String: Any] = [
            "height": 1,
            "url": "dummy url",
            "width": 1
        ]
        let mockResponseData = try! JSONSerialization.data(withJSONObject: mockResponseDict, options: .fragmentsAllowed)
        
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
            return (mockResponse, mockResponseData)
        }
        
        let expectation = expectation(description: "Fetch data api must succeed")
        sut.fetchData(
            with: URLRequest(url: URL(string: "dummy url")!),
            session: getMockSession(),
            decoder: JSONDecoder(),
            networkManager: getMockNetworkManager(with: true)
        ) { (result: Result<AlbumImage, Error>) in
            switch result {
            case .success(let albumImage):
                XCTAssertEqual(albumImage.height, 1, "Expected height to match")
                XCTAssertEqual(albumImage.width, 1, "Expected width to match")
            case .failure:
                XCTFail("Expected successful result, but got failure.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_fetchData_failure() {
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (mockResponse, Data())
        }
        
        let expectation = expectation(description: "Fetch data api must fail")
        sut.fetchData(
            with: URLRequest(url: URL(string: "dummy url")!),
            session: getMockSession(),
            decoder: JSONDecoder(),
            networkManager: getMockNetworkManager(with: true)
        ) { (result: Result<AlbumImage, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success.")
            case .failure(let error):
                XCTAssertEqual(error as? APIError, APIError.failedToGetData)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_fetchData_networkUnavailable() {
        let expectation = expectation(description: "Fetch data api must fail")
        sut.fetchData(
            with: URLRequest(url: URL(string: "dummy url")!),
            session: getMockSession(),
            decoder: JSONDecoder(),
            networkManager: getMockNetworkManager(with: false)
        ) { (result: Result<AlbumImage, Error>) in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success.")
            case .failure(let error):
                XCTAssertEqual(error as? APIError, APIError.networkUnavailable)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}

extension APIClientTests {
    func getMockSession() -> URLSession {
        let config = MockServer().loadMockServerConfiguration()
        let session = URLSession(configuration: config)
        return session
    }
    
    func getMockNetworkManager(with value: Bool) -> NetworkManager {
        let mockNetworkManager = MockNetworkManager()
        mockNetworkManager.isMockNetworkAvailable = value
        return mockNetworkManager
    }
}
