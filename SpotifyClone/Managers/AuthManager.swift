//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import Foundation

class AuthManager: FileIdentifier {
    
    static var shared: AuthManager!
    
    struct Constants {
        static let CLIENT_ID = "684b82ce64ad4d779d733d2d20478b12"
        static let CLIENT_SECRET = "ddd50299eaa248d5b33c61f027efc303"
        static let BASE_URL = "https://accounts.spotify.com"
        static let REDIRECT_URI = "https://www.google.co.in/"
        static let AUTHORIZATION_ENDPOINT = "/authorize"
        static let TOKEN_API_ENDPOINT = "/api/token"
        static let ACCESS_TOKEN = "access_token"
        static let REFRESH_TOKEN = "refresh_token"
        static let EXPIRATION_DATE = "expiration_date"
        static let SCOPES = "user-read-private%20playlist-modify-public%20playlist-read-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    static func setupManager(isTesting: Bool = false) {
        let networkManager = NetworkManager.shared
        let config = MockServer().loadMockServerConfiguration()
        let session = isTesting ? URLSession(configuration: config) : URLSession.shared
        let decoder = AuthManager.decoder
        let manager = AuthManager(networkManager: networkManager, session: session, decoder: decoder)
        AuthManager.shared = manager
    }
    
    private let networkManager: NetworkManager
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(networkManager: NetworkManager, session: URLSession, decoder: JSONDecoder) {
        self.networkManager = networkManager
        self.session = session
        self.decoder = decoder
    }
    
    private var isRefreshingToken: Bool = false
    
    var signInURL: URL? {
        let string = "\(Constants.BASE_URL)\(Constants.AUTHORIZATION_ENDPOINT)?response_type=code&client_id=\(Constants.CLIENT_ID)&scope=\(Constants.SCOPES)&redirect_uri=\(Constants.REDIRECT_URI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: Constants.ACCESS_TOKEN)
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: Constants.REFRESH_TOKEN)
    }
    
    private var tokenExpiryDate: Date? {
        return UserDefaults.standard.object(forKey: Constants.EXPIRATION_DATE) as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpiryDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    private func createRequest(with url: URL) -> URLRequest? {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.POST.rawValue
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = Constants.CLIENT_ID + ":" + Constants.CLIENT_SECRET
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("\n[\(fileName)] TROUBLE CONVERTING TO BASE64")
            return nil
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.set(result.accessToken, forKey: Constants.ACCESS_TOKEN)
        if let refreshToken = result.refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: Constants.REFRESH_TOKEN)
        }
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: Constants.EXPIRATION_DATE)
    }
    
    private var onRefreshBlocks = [(String) -> Void]()
    
    func withValidToken(completion: @escaping (String) -> Void) {
        guard !isRefreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshAccessToken { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    func signOut() {
        UserDefaults.standard.set(nil, forKey: Constants.ACCESS_TOKEN)
        UserDefaults.standard.set(nil, forKey: Constants.REFRESH_TOKEN)
        UserDefaults.standard.set(nil, forKey: Constants.EXPIRATION_DATE)
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier ?? "")
        UserDefaults.standard.synchronize()
    }
}

// MARK: - API Calls with completion handlers
extension AuthManager {
    // get the access token
    func exchangeCodeForToken(code: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: Constants.BASE_URL + Constants.TOKEN_API_ENDPOINT),
              var request = createRequest(with: url) else {
            print("\n[\(fileName)] TROUBLE CREATING REQUEST")
            completion(false)
            return
        }
        
        print("\n[\(fileName)] EXCHANGING CODE FOR TOKEN...")
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.REDIRECT_URI)
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, let self = self,
                  let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try decoder.decode(AuthResponse.self, from: data)
                cacheToken(result: result)
                print("\n[\(fileName)] EXCHANGE SUCCESS WITH TOKEN:\n", result)
                completion(true)
            } catch {
                print("\n[\(fileName)] TROUBLE WITH DATA \(error.localizedDescription)")
                completion(false)
            }
        }.resume()
    }
    
    // refresh the access token
    func refreshAccessToken(completion: ((Bool) -> Void)?) {
        guard !isRefreshingToken else {
            return
        }
        
        guard shouldRefreshToken, let refreshToken else {
            completion?(true)
            return
        }
        
        print("\n[\(fileName)] INITIATING REFRESH TOKEN CALL...")
        guard let url = URL(string: Constants.BASE_URL + Constants.TOKEN_API_ENDPOINT),
              var request = createRequest(with: url) else {
            print("\n[\(fileName)] TROUBLE CREATING REQUEST")
            completion?(false)
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: Constants.REFRESH_TOKEN),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        isRefreshingToken = true
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, let self = self,
                  let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  error == nil else {
                completion?(false)
                return
            }
            
            isRefreshingToken = false
            
            do {
                let result = try decoder.decode(AuthResponse.self, from: data)
                onRefreshBlocks.forEach { $0(result.accessToken) }
                onRefreshBlocks.removeAll()
                cacheToken(result: result)
                print("\n[\(fileName)] REFRESH SUCCESS WITH TOKEN:\n", result)
                completion?(true)
            } catch {
                print("\n[\(fileName)] TROUBLE WITH DATA \(error.localizedDescription)")
                completion?(false)
            }
        }.resume()
    }
}

// MARK: - API Calls with async/await
extension AuthManager {
    func exchangeCodeForToken(code: String) async throws -> Bool {
        guard let url = URL(string: Constants.BASE_URL + Constants.TOKEN_API_ENDPOINT),
              var request = createRequest(with: url) else {
            print("\n[\(fileName)] TROUBLE CREATING REQUEST")
            throw APIError.invalidRequest
        }
        
        print("\n[\(fileName)] EXCHANGING CODE FOR TOKEN...")
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.REDIRECT_URI)
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw APIError.invalidResponse
        }
        
        isRefreshingToken = false
        
        let result = try decoder.decode(AuthResponse.self, from: data)
        cacheToken(result: result)
        print("\n[\(fileName)] EXCHANGE SUCCESS WITH TOKEN:\n", result)
        return true
    }
    
    func refreshAccessToken() async throws -> Bool {
        guard !isRefreshingToken else {
            return false
        }
        
        guard shouldRefreshToken, let refreshToken else {
            return true
        }
        
        print("\n[\(fileName)] INITIATING REFRESH TOKEN CALL...")
        guard let url = URL(string: Constants.BASE_URL + Constants.TOKEN_API_ENDPOINT),
              var request = createRequest(with: url) else {
            print("\n[\(fileName)] TROUBLE CREATING REQUEST")
            throw APIError.invalidRequest
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: Constants.REFRESH_TOKEN),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        request.httpBody = components.query?.data(using: .utf8)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        isRefreshingToken = true
        
        let (data, response) = try await session.data(for: request)
        
        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
            throw APIError.invalidResponse
        }
        
        isRefreshingToken = false
        
        let result = try decoder.decode(AuthResponse.self, from: data)
        onRefreshBlocks.forEach { $0(result.accessToken) }
        onRefreshBlocks.removeAll()
        cacheToken(result: result)
        print("\n[\(fileName)] REFRESH SUCCESS WITH TOKEN:\n", result)
        return true
    }
}
