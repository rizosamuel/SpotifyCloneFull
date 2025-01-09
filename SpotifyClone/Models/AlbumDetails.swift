//
//  AlbumDetails.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 10/12/24.
//

struct AlbumDetails: Codable {
    let albumType: String
    let totalTracks: Int
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [AlbumImage]
    let name, releaseDate, releaseDatePrecision, type: String
    let uri: String
    let artists: [Artist]
    let tracks: AlbumTracks
    //    let copyrights: [Copyright]
    //    let externalIDS: ExternalIDS
    //    let genres: [JSONAny]
    let label: String
    let popularity: Int
}

struct AlbumTracks: Codable {
    let href: String
    let total: Int
    let limit: Int
    //    let next: JSONNull?
    let offset: Int
    //    let previous: JSONNull?
    let items: [AlbumTrack]
}

struct Tracks: Codable {
    let href: String
    let total: Int
    let limit: Int
    //    let next: JSONNull?
    let offset: Int
    //    let previous: JSONNull?
    let items: [TrackItem]
}

struct AlbumTrack: Codable {
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalUrls: ExternalUrls
    let href: String
    let id: String
//    let linkedFrom: Artist
    let name: String
    let previewURL: String?
    let trackNumber: Int
    let type, uri: String
    let isLocal: Bool
}

struct TrackItem: Codable {
    let addedAt: String?
    let isLocal: Bool?
    let track: Track?
}

struct Track: Codable {
    let album: Album
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber: Int
    let durationMs: Int
    let explicit: Bool
    let externalUrls: ExternalUrls
    let href, id: String
    let isPlayable: Bool?
    let linkedFrom: LinkedFrom?
    let restrictions: Restrictions?
    let name: String
    let popularity: Int
    let previewURL: String?
    let trackNumber: Int
    let type, uri: String
    let isLocal: Bool
}
