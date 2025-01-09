//
//  CreatePlaylistResponse.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 29/12/24.
//

struct CreatePlaylistResponse: Codable {
    let collaborative: Bool
    let description: String
    let externalUrls: ExternalUrls
//    let followers: Followers
    let href: String
    let id: String
//    let images: [JSONAny]
//    let primaryColor: JSONNull?
    let name, type, uri: String
//    let owner: Owner
//    let isPublic: Bool
    let snapshotId: String
//    let tracks: Tracks
}
