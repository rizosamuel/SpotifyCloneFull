//
//  APIClient.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 16/12/24.
//

import Foundation

protocol APIClient: FileIdentifier {
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void)
    func getNewReleases(completion: @escaping ((Result<NewReleases, Error>)) -> Void)
    func getCurrentPlaylists(needsCache: Bool, completion: @escaping (Result<CurrentPlaylists, Error>) -> Void)
    func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylists, Error>) -> Void)
    func getCategories(completion: @escaping (Result<CategoriesResponse, Error>) -> Void)
    func getRecommendedGenres(completion: @escaping (Result<Genres, Error>) -> Void)
    func getTracks(completion: @escaping (Result<TracksResponse, Error>) -> Void)
    func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetails, Error>) -> Void)
    func getCategoryDetails(for category: Category, completion: @escaping (Result<Category, Error>) -> Void)
    func getCategoryPlaylists(for category: Category, completion: @escaping (Result<CategoryPlaylists, Error>) -> Void)
    func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetails, Error>) -> Void)
    func search(with query: String, completion: @escaping (Result<SearchResults, Error>) -> Void)
    func createPlaylist(with name: String, desc: String, completion: @escaping (Result<CreatePlaylistResponse, Error>) -> Void)
    func addToPlaylist(with uris: [String], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, Error>) -> Void)
    func removeFromPlaylist(with tracks: [ToDeleteTrack], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, Error>) -> Void)
    func saveAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, Error>) -> Void)
    func removeSavedAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, Error>) -> Void)
}

extension APIClient {
    func fetchData<T: Codable>(
        with request: URLRequest,
        session: URLSession,
        decoder: JSONDecoder,
        networkManager: NetworkManager,
        needsLog: Bool = false,
        isEmptyResponse: Bool = false,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard networkManager.isNetworkAvailable else {
            print("\n[\(fileName)] NETWORK UNAVAILABLE")
            completion(.failure(APIError.networkUnavailable))
            return
        }
        
        let urlString = request.url?.absoluteString ?? ""
        print("\n[\(fileName)] INITIATING CALL FOR URL:", urlString)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            print("\n[\(fileName)] USING CACHED RESPONSE FOR URL: \(urlString)")
            decodeData(with: cachedResponse.data, url: request.url, decoder: decoder, needsLog: needsLog, completion: completion)
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  error == nil else {
                print("\n[\(fileName)] RESPONSE ERROR FOR URL: \(urlString)")
                completion(.failure(APIError.invalidResponse))
                return
            }
                        
            guard let data, !data.isEmpty else {
                if isEmptyResponse, response.statusCode == 200, let emptyResponse = EmptyResponse() as? T {
                    print("\n[\(fileName)] RECEIVED SUCCESS WITH NO CONTENT FOR URL: \(urlString)")
                    completion(.success(emptyResponse))
                } else {
                    print("\n[\(fileName)] DATA ERROR FOR URL: \(urlString)")
                    completion(.failure(APIError.dataFailure))
                }
                return
            }
            
            decodeData(with: data, url: request.url, decoder: decoder, needsLog: needsLog, completion: completion)
        }.resume()
    }
    
    func decodeData<T: Codable>(
        with data: Data,
        url: URL?,
        decoder: JSONDecoder,
        needsLog: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let urlString = url?.absoluteString ?? ""
        
        if needsLog, let JSONString = String(data: data, encoding: String.Encoding.utf8) {
            print("\nRECEIVED RESPONSE DATA FOR URL \(urlString):", JSONString)
        }
        
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            // print("\nSUCCESSFULLY DECODED RESPONSE DATA for \(urlString): \n", decodedData)
            print("\n[\(fileName)] SUCCESSFULLY DECODED RESPONSE DATA FOR URL: \(urlString)")
            completion(.success(decodedData))
        } catch {
            print("\n[\(fileName)] ERROR DECODING DATA FOR URL \(urlString): \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
}
