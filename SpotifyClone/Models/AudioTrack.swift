//
//  AudioTrack.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

// MARK: - Tracks Response
struct TracksResponse: Codable {
    let href: String
    let items: [TrackItem]
    let limit: Int
    let offset: Int
    let total: Int
}

// MARK: - Categories response
struct CategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let href: String
    let items: [Category]
    let limit: Int
    let next: String
    let offset: Int
    let previous: String?
    let total: Int
}

struct Category: Codable {
    let href: String
    let id: String
    let icons: [AlbumImage]
    let name: String
}

// MARK: - Featured Playlists response

struct FeaturedPlaylists: Codable {
    let message: String
    let playlists: Playlists
}

struct Playlists: Codable {
    let href: String
    let limit: Int
    let next: String
    let offset: Int
    let previous: String
    let total: Int
    let items: [Playlist]
}

// MARK: - New Releases Response
struct NewReleases: Codable {
    let albums: Albums
}

struct Albums: Codable {
    let href: String
    let items: [Album]
    let limit: Int
    let next: String
    let offset: Int
    let previous: String?
    let total: Int
}

struct Artist: Codable {
    let externalUrls: ExternalUrls
    let href: String
    let id, name, type, uri: String
    let images: [AlbumImage]?
}

struct ExternalUrls: Codable {
    let spotify: String
}

struct AlbumImage: Codable {
    let height: Int?
    let url: String
    let width: Int?
}

// MARK: - Recommendations Response

struct Recommendations: Codable {
    let seeds: [Seed]
    let tracks: [Track]
}

struct Seed: Codable {
    let afterFilteringSize, afterRelinkingSize: Int
    let href, id: String
    let initialPoolSize: Int
    let type: String
}

struct Restrictions: Codable {
    let reason: String
}

struct ExternalIDS: Codable {
    let isrc: String
    let ean, upc: String?
}

struct LinkedFrom: Codable {
}
