//
//  PlaylistDetails.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

struct PlaylistDetails: Codable {
    let collaborative: Bool
    let description: String
    let externalUrls: ExternalUrls
    let followers: Followers
    let href: String
    let id: String
    let images: [AlbumImage]?
    let name: String
    let owner: Owner
//    let primaryColor: JSONNull?
    let welcomePublic: Bool?
    let snapshotId: String?
    let tracks: Tracks?
    let type, uri: String
}

struct Followers: Codable {
    let href: String?
    let total: Int
}
