//
//  MKMapView+Zoom.swift
//  TWTW
//
//  Created by Sean Hong on 12/10/23.
//

import MapKit

extension MKMapView {

    /// Zooms to the provided route for you.
    ///
    /// - Parameters:
    ///   - route: The route to zoom into.
    ///   - animated: Whether or not to animate (defaults to true).
    func zoom(to route: MKRoute, animated: Bool = true) {
        let mapRect = route.polyline.boundingMapRect
        setVisibleMapRect(mapRect, animated: animated)
    }
}
