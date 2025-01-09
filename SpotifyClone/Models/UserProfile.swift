//
//  UserProfile.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

struct UserProfile: Codable {
    let id: String
    let country: String
    let displayName: String
    let email: String
    let explicitContent: [String: Bool]
    let externalUrls: [String: String]
//    let followers: [String: Codable?]
    let product: String
    let images: [UserImage]
}

struct UserImage: Codable {
    let url: String
}
