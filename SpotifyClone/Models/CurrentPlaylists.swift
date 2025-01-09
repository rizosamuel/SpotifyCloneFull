//
//  CurrentPlaylists.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

struct CurrentPlaylists: Codable {
    let href: String
    let limit: Int
//    let next: JSONNull?
    let offset: Int
//    let previous: JSONNull?
    let total: Int
    let items: [Playlist]
}

struct Playlist: Codable {
    let href, id: String
    let name: String
    let collaborative: Bool
    let description: String
    let type, uri: String
    let snapshotId: String?
//    let itemPublic: Bool?
    let images: [AlbumImage]?
    let externalUrls: ExternalUrls
    let owner: Owner
}

struct Owner: Codable {
    let externalUrls: ExternalUrls
    let followers: Tracks?
    let href, id, type, uri: String
    let displayName: String
}
