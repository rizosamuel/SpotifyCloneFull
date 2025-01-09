//
//  SearchResults.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 12/12/24.
//

struct SearchResults: Codable {
    let albums: SearchAlbumsResponse
    let artists: SearchArtistsResponse
    let tracks: SearchTracksResponse
    let playlists: SearchPlaylistsResponse
}

struct SearchAlbumsResponse: Codable {
    let items: [Album?]
}

struct SearchArtistsResponse: Codable {
    let items: [Artist?]
}

struct SearchTracksResponse: Codable {
    let items: [Track?]
}

struct SearchPlaylistsResponse: Codable {
    let items: [Playlist?]
}
