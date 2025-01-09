//
//  AuthResponse.swift
//  SpotifyClone
//
//  Created by Rijo Samuel on 02/12/24.
//

struct AuthResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String
    let tokenType: String
}
