//
//  APIManager.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

import Foundation

enum APIError: Error {
    case dataFailure, decodingFailure, networkUnavailable, invalidResponse, invalidRequest
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

class APIManager: APIClient {
    
    struct Constants {
        static let BASE_API_URL = "https://api.spotify.com/v1"
        static let PROFILE_EP = "/me"
        static let NEW_RELEASES_EP = "/browse/new-releases?limit=10"
        static let FEATURED_PLAYLISTS_EP = "/browse/featured-playlists?limit=10"
        static let CATEGORIES_EP = "/browse/categories"
        static let GENRES_EP = "/recommendations/available-genre-seeds"
        static let TRACKS_EP = "/me/tracks?limit=10"
        static let SAVED_ALBUMS_EP = "/me/albums"
        static let RECOMMENDATIONS_EP = "/recommendations?limit=10&seed-genres=classical"
        static let CURRENT_PLAYLISTS_EP = "/me/playlists?limit=10"
        static let PLAYLIST_DETAILS_EP = "/playlists/{}"
        static let ALBUM_DETAILS_EP = "/albums/{}"
        static let CATEGORY_DETAILS_EP = "/browse/categories/{}"
        static let CATEGORY_PLAYLISTS_EP = "/browse/categories/{}/playlists"
        static let SEARCH_EP = "/search?limit=10&type=album,artist,playlist,track&q={}"
        static let CREATE_PLAYLIST_EP = "/users/{}/playlists"
        static let UPDATE_PLAYLIST_EP = "/playlists/{}/tracks"
    }
    
    static var shared: APIManager!
    
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    static func setupManager(isTesting: Bool = false) {
        let networkManager = NetworkManager.shared
        let config = MockServer().loadMockServerConfiguration()
        let session = isTesting ? URLSession(configuration: config) : URLSession.shared
        let decoder = APIManager.decoder
        let manager = APIManager(networkManager: networkManager, session: session, decoder: decoder)
        
        let cache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024)
        URLCache.shared = cache
        APIManager.shared = manager
    }
    
    private let networkManager: NetworkManager
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(networkManager: NetworkManager, session: URLSession, decoder: JSONDecoder) {
        self.networkManager = networkManager
        self.session = session
        self.decoder = decoder
    }
    
    func createRequest(with url: URL?, type: HTTPMethod, needsCache: Bool = true, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let url else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue.lowercased()
            request.timeoutInterval = 30
            request.cachePolicy = needsCache ? .returnCacheDataElseLoad : .reloadIgnoringLocalCacheData
            completion(request)
        }
    }
    
    private func getModifiedRequest(with baseRequest: URLRequest, postBody: [String: Any]) -> URLRequest {
        var request = baseRequest
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: postBody, options: .fragmentsAllowed)
        } catch {
            print(error.localizedDescription)
        }
        return request
    }
}

extension APIManager {
    
    // Dashboard API Calls
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.PROFILE_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getNewReleases(completion: @escaping ((Result<NewReleases, Error>)) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.NEW_RELEASES_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getCurrentPlaylists(needsCache: Bool = true, completion: @escaping (Result<CurrentPlaylists, Error>) -> Void) {
        let url = URL(string: Constants.BASE_API_URL + Constants.CURRENT_PLAYLISTS_EP)
        createRequest(with: url, type: .GET, needsCache: needsCache) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylists, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.FEATURED_PLAYLISTS_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.CATEGORIES_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getRecommendedGenres(completion: @escaping (Result<Genres, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.RECOMMENDATIONS_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getTracks(completion: @escaping (Result<TracksResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.TRACKS_EP), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getUsersAlbums(completion: @escaping (Result<SavedAlbums, Error>) -> Void) {
        createRequest(with: URL(string: Constants.BASE_API_URL + Constants.SAVED_ALBUMS_EP), type: .GET, needsCache: false) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    // Details API Calls
    func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetails, Error>) -> Void) {
        let endpoint = Constants.ALBUM_DETAILS_EP.replacingOccurrences(of: "{}", with: album.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getCategoryDetails(for category: Category, completion: @escaping (Result<Category, Error>) -> Void) {
        let endpoint = Constants.CATEGORY_DETAILS_EP.replacingOccurrences(of: "{}", with: category.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getCategoryPlaylists(for category: Category, completion: @escaping (Result<CategoryPlaylists, Error>) -> Void) {
        let endpoint = Constants.CATEGORY_PLAYLISTS_EP.replacingOccurrences(of: "{}", with: category.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .GET) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetails, Error>) -> Void) {
        let endpoint = Constants.PLAYLIST_DETAILS_EP.replacingOccurrences(of: "{}", with: playlist.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .GET, needsCache: false) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    // Search API Calls
    func search(with query: String, completion: @escaping (Result<SearchResults, Error>) -> Void) {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let endpoint = Constants.SEARCH_EP.replacingOccurrences(of: "{}", with: formattedQuery)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .GET, needsCache: false) { [weak self] request in
            guard let self else { return }
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    // Create API Calls
    func createPlaylist(with name: String, desc: String, completion: @escaping (Result<CreatePlaylistResponse, Error>) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                guard let self else { return }
                let endpoint = Constants.CREATE_PLAYLIST_EP.replacingOccurrences(of: "{}", with: profile.id)
                let url = URL(string: Constants.BASE_API_URL + endpoint)
                self.createRequest(with: url, type: .POST, needsCache: false) { baseRequest in
                    let postBody = ["name": name, "description": desc, "public": true]
                    let request = self.getModifiedRequest(with: baseRequest, postBody: postBody)
                    self.fetchData(with: request, session: self.session, decoder: self.decoder, networkManager: self.networkManager, completion: completion)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    // Update API Calls
    func addToPlaylist(with uris: [String], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, Error>) -> Void) {
        let endpoint = Constants.UPDATE_PLAYLIST_EP.replacingOccurrences(of: "{}", with: playlist.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .POST, needsCache: false) { [weak self] baseRequest in
            guard let self else { return }
            let postBody = ["uris": uris, "position": 0]
            let request = self.getModifiedRequest(with: baseRequest, postBody: postBody)
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func removeFromPlaylist(with tracks: [ToDeleteTrack], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, Error>) -> Void) {
        let endpoint = Constants.UPDATE_PLAYLIST_EP.replacingOccurrences(of: "{}", with: playlist.id)
        createRequest(with: URL(string: Constants.BASE_API_URL + endpoint), type: .DELETE, needsCache: false) { [weak self] baseRequest in
            guard let self, let snapshotId = playlist.snapshotId else { return }
            let trackObjects = tracks.map { ["uri": $0.uri] }
            let postBody = ["tracks": trackObjects, "snapshot_id": snapshotId]
            let request = self.getModifiedRequest(with: baseRequest, postBody: postBody)
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, completion: completion)
        }
    }
    
    func saveAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let path = Constants.BASE_API_URL + Constants.SAVED_ALBUMS_EP
        createRequest(with: URL(string: path), type: .PUT, needsCache: false) { [weak self] baseRequest in
            guard let self else { return }
            let postBody = ["ids": ids]
            let request = self.getModifiedRequest(with: baseRequest, postBody: postBody)
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, isEmptyResponse: true, completion: completion)
        }
    }
    
    func removeSavedAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let path = Constants.BASE_API_URL + Constants.SAVED_ALBUMS_EP
        createRequest(with: URL(string: path), type: .DELETE, needsCache: false) { [weak self] baseRequest in
            guard let self else { return }
            let postBody = ["ids": ids]
            let request = self.getModifiedRequest(with: baseRequest, postBody: postBody)
            fetchData(with: request, session: session, decoder: decoder, networkManager: networkManager, isEmptyResponse: true, completion: completion)
        }
    }
}
