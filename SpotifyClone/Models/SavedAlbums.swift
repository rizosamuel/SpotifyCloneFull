//
//  SavedAlbums.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 03/01/25.
//

import Foundation

struct SavedAlbums: Codable {
    let href: String
    let items: [AlbumItem]
    let limit: Int
    let offset: Int
    let total: Int
}

struct AlbumItem: Codable {
    let addedAt: Date
    let album: Album
}

struct Album: Codable {
    let albumType: String
    let totalTracks: Int
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let href, id: String
    let images: [AlbumImage]
    let name, releaseDate, releaseDatePrecision: String
    let restrictions: Restrictions?
    let type, uri: String
    let artists: [Artist]
    let isPlayable: Bool?
    let tracks: TracksResponse?
}
