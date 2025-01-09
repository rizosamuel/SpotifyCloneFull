//
//  MockAPIClient.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 26/12/24.
//

import Foundation

class MockAPIClient: APIClient {
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, any Error>) -> Void) { }
    
    func getNewReleases(completion: @escaping ((Result<NewReleases, any Error>)) -> Void) { }
    
    func getCurrentPlaylists(needsCache: Bool, completion: @escaping (Result<CurrentPlaylists, any Error>) -> Void) { }
    
    func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylists, any Error>) -> Void) { }
    
    func getCategories(completion: @escaping (Result<CategoriesResponse, any Error>) -> Void) { }
    
    func getRecommendedGenres(completion: @escaping (Result<Genres, any Error>) -> Void) { }
    
    func getTracks(completion: @escaping (Result<TracksResponse, any Error>) -> Void) { }
    
    func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetails, any Error>) -> Void) { }
    
    func getCategoryDetails(for category: Category, completion: @escaping (Result<Category, any Error>) -> Void) { }
    
    func getCategoryPlaylists(for category: Category, completion: @escaping (Result<CategoryPlaylists, any Error>) -> Void) { }
    
    func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetails, any Error>) -> Void) { }
    
    func search(with query: String, completion: @escaping (Result<SearchResults, any Error>) -> Void) { }
    
    func createPlaylist(with name: String, desc: String, completion: @escaping (Result<CreatePlaylistResponse, any Error>) -> Void) { }
    
    func addToPlaylist(with uris: [String], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, any Error>) -> Void) { }
    
    func removeFromPlaylist(with tracks: [ToDeleteTrack], playlist: Playlist, completion: @escaping (Result<UpdatePlaylistResponse, any Error>) -> Void) { }
    
    func saveAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, any Error>) -> Void) { }
    
    func removeSavedAlbum(with ids: [String], completion: @escaping (Result<EmptyResponse, any Error>) -> Void) { }
}
