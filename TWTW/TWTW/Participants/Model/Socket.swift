//
//  Socket.swift
//  TWTW
//
//  Created by 정호진 on 1/16/24.
//

import Foundation

struct SocketRequest: Codable {
    let nickname: String?
    let memberId: String?
    let longitude: Double?
    let latitude: Double?
}


struct SocketResponse: Codable {
    let nickname: String?
    let longitude: Double?
    let latitude: Double?
    let time: String?
    let averageCoordinate: AverageCoordinate?
}

struct AverageCoordinate: Codable {
    let longitude: Double?
    let latitude: Double?
    let distance: Double?
}

struct MyInfo: Codable {
    let memberId: String?
    let nickname: String?
    let profileImage: String?
}
