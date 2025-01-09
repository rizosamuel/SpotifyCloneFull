//
//  AuthManagerTests.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 16/12/24.
//

import XCTest
@testable import SpotifyClone

class AuthManagerTests: XCTestCase {
    var sut: AuthManager!
    
    override func setUp() {
        super.setUp()
        AuthManager.setupAuthManager(isTesting: true)
        sut = AuthManager.shared
    }
    
    override func tearDown() {
        sut = nil
        AuthManager.shared = nil
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        super.tearDown()
    }
    
    func test_isSignedIn_returnsTrue_whenAccessTokenExists() {
        UserDefaults.standard.set("dummyAccessToken", forKey: AuthManager.Constants.ACCESS_TOKEN)
        XCTAssertTrue(sut.isSignedIn)
    }
    
    func test_isSigned_returnFalse_whenAccessToken_isNil() {
        UserDefaults.standard.removeObject(forKey: AuthManager.Constants.ACCESS_TOKEN)
        XCTAssertFalse(sut.isSignedIn)
    }
    
    func test_exchangeCodeForToken_success() {
        let mockResponseDict: [String: Any] = [
            "access_token": "dummyAccessToken",
            "refresh_token": "dummyRefreshToken",
            "expires_in": 3600,
            "scope": "",
            "token_type": ""
        ]
        let mockResponseData = try! JSONSerialization.data(withJSONObject: mockResponseDict, options: .fragmentsAllowed)
        
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])!
            return (mockResponse, mockResponseData)
        }
        
        let expectation = expectation(description: "Exchange code for token api must success")
        sut.exchangeCodeForToken(code: "dummyCode") { isSuccess in
            XCTAssertTrue(isSuccess, "Code to Token exchange must succeed")
            XCTAssertEqual(UserDefaults.standard.string(forKey: AuthManager.Constants.ACCESS_TOKEN), "dummyAccessToken")
            XCTAssertEqual(UserDefaults.standard.string(forKey: AuthManager.Constants.REFRESH_TOKEN), "dummyRefreshToken")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_exchangeCodeForToken_failure() {
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (mockResponse, Data())
        }
        
        let expectation = expectation(description: "Exchange code for token api must fail")
        sut.exchangeCodeForToken(code: "dummyCode") { isSuccess in
            XCTAssertFalse(isSuccess, "Code to Token exchange must fail")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_refreshToken_success() {
        UserDefaults.standard.set("dummyRefreshToken", forKey: AuthManager.Constants.REFRESH_TOKEN)
        UserDefaults.standard.set(Date(), forKey: AuthManager.Constants.EXPIRATION_DATE)
        let mockResponseData: [String: Any] = [
            "access_token": "newAccessToken",
            "refresh_token": "newRefreshToken",
            "expires_in": 3600,
            "scope": "",
            "token_type": ""
        ]
        
        let mockResponseObject = try! JSONSerialization.data(withJSONObject: mockResponseData, options: .fragmentsAllowed)
        
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (mockResponse, mockResponseObject)
        }
        
        let expectation = expectation(description: "Refresh token api must succeed")
        
        sut.refreshAccessToken { isSuccess in
            XCTAssertTrue(isSuccess, "refresh token api must succeed")
            XCTAssertEqual(UserDefaults.standard.string(forKey: AuthManager.Constants.ACCESS_TOKEN), "newAccessToken")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_refreshToken_failure() {
        UserDefaults.standard.set("dummyRefreshToken", forKey: AuthManager.Constants.REFRESH_TOKEN)
        UserDefaults.standard.set(Date(), forKey: AuthManager.Constants.EXPIRATION_DATE)
        
        MockServer.requestHandler = { request in
            let mockResponse = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: nil)!
            return (mockResponse, Data())
        }
        
        let expectation = expectation(description: "Refresh token api must fail")
        sut.refreshAccessToken { isSuccess in
            XCTAssertFalse(isSuccess, "refresh token api must fail")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
