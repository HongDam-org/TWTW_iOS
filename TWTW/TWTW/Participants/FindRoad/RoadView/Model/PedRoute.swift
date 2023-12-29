//
//  PedRoute.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/29.
//

import Foundation

/// 보행자 경로 요청 구조체
struct PedRouteRequest: Codable {
    let startX: Double
    let startY: Double
    let endX: Double
    let endY: Double
    let startName: String
    let endName: String
}

/// 보행자 경로 응답 구조체
struct PedRoute: Codable {
    let type: String
    let features: [Feature]
}

/// Feature 구조체
struct Feature: Codable {
    let type: String
    let geometry: Geometry
}

/// Geometry 구조체
struct Geometry: Codable {
    let type: String
    let coordinates: [[Double]]
}
