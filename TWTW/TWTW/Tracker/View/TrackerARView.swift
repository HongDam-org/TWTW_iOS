//
//  TrackerARView.swift
//  TWTW
//
//  Created by Sean Hong on 12/10/23.
//


import ARKit
import ARKit_CoreLocation
import MapKit
import SnapKit
import UIKit
import os
class NavigateToViewController: UIViewController {
    let logger = Logger()
    let sceneLocationView = SceneLocationView()
    let mapView = MKMapView()
    let activityView = UIActivityIndicatorView(style: .large)

    var currentLocation: CLLocation? {
        return sceneLocationView.sceneLocationManager.currentLocation
    }

    var action: Action? {
        didSet {
            navigate(to: "대한민국 경기도 시흥시 공단1대로 237, 15079")
            title = action?.title
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard ARConfiguration.isSupported else {
            return showErrorAlert(message: "Your device does not support ARKit") { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        }

        [sceneLocationView, mapView, activityView].forEach { view.addSubview($0) }

        sceneLocationView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        activityView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view)
        }

        mapView.snp.makeConstraints { make in
            make.left.equalTo(view)
            make.top.equalTo(activityView.snp.bottom).offset(120)
            make.right.equalTo(view)
            make.bottom.equalTo(view)
        }
        mapView.layer.cornerRadius = mapView.frame.size.height / 2
        mapView.layer.masksToBounds = true


        showActivityControl()

        mapView.showsUserLocation = true
        mapView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }
}

// MARK: - Implementation

extension NavigateToViewController {

    func showActivityControl() {
        activityView.isHidden = false
        activityView.startAnimating()
    }

    func hideActivityControl() {
        activityView.isHidden = false
        activityView.stopAnimating()
    }

    /// Searches for the provided address and if a MKMapItem comes back
    /// it then gets directions to that location.
    ///
    /// - Parameter address: The address you want to navigate to.
    func navigate(to address: String?) {
        guard let address = address else {
            logger.log("Failed...")
            return
        }
        logger.log("\(address)")
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address

        let search = MKLocalSearch(request: request)
        logger.log("\(request.debugDescription)")
        search.start { [weak self] response, error in
            
            if let error = error {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "Error searching for \(address): \(error.localizedDescription)")
                }
            }
            guard let response = response else {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "No response back searching for \(address), please try again.")
                }
            }
            guard let destination = response.mapItems.first else {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "No routes returned for \(address), please try again.")
                }
            }

            self?.navigate(to: destination)
        }
    }

    /// Finds directions to the provided MKMapItem (location) and then shows
    /// those directions on the map and in ARCL.
    ///
    /// - Parameter mapLocation: The mapLocation to navigate to.
    func navigate(to mapLocation: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = mapLocation
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)

        directions.calculate { response, error in
            if let error = error {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "Error get directions: \(error.localizedDescription)")
                }
            }
            guard let response = response else {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "No directions response received, please try again.")
                }
            }
            guard let route = response.routes.first else {
                return DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(message: "No navigation route received, please try again.")
                }
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.map(route: route)
                self.show(route: route)
            }
        }
    }

    /// Shows the route on the map.
    ///
    /// - Parameter route: The route to show on the map.
    func map(route: MKRoute) {
        mapView.addOverlay(route.polyline)
        mapView.zoom(to: route)
    }

    /// Shows the route in AR.
    ///
    /// - Parameter route: The route to be shown.
    func show(route: MKRoute) {
        guard let location = currentLocation,
            location.horizontalAccuracy < 15 else {
                return DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.show(route: route)
                }
        }

        sceneLocationView.addRoutes(routes: [route])
        if let locationNodes = sceneLocationView.sceneNode?.childNodes.filter({ $0 is LocationNode }), locationNodes.count > 20 {
            for idx in 20..<locationNodes.count {
                locationNodes[idx].isHidden = true
            }
        }
        hideActivityControl()
    }

}

// MKMapViewDelegate

extension NavigateToViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }

        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .blue
        renderer.lineWidth = 5
        return renderer
    }

}
