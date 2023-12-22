//
//  RoadViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/21.
//
import KakaoMapsSDK
import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class RoadViewController: KakaoMapViewController {
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.978365, latitude: 37.566691)
        let roadviewInfo: RoadviewInfo = RoadviewInfo(viewName: "roadview", viewInfoName: "roadview", enabled: true)
        requestRoadview()

        //로드뷰 추가.
        if mapController?.addView(roadviewInfo) == Result.OK {
            print("Roadview OK")
        }
    }
    
    func requestRoadview() {
        let view = mapController?.getView("roadview") as? Roadview
        let defaultPosition: MapPoint = MapPoint(longitude: 126.978365, latitude: 37.566691)
        //좌표로 로드뷰 요청. panoID를 알 경우, panoID를 지정할 수 있다. panoID가 지정되면 해당 panoID로 먼저 검색한 뒤 없으면 좌표로 검색한다.
        view?.requestRoadview(position: defaultPosition, panoID: nil)
    }
}
