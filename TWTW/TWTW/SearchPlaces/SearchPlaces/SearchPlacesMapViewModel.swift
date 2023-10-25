//
//  SearchPlacesMapViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import RxRelay
import CoreLocation
import Alamofire

final class SearchPlacesMapViewModel: NSObject {
    var selectedCoordinateSubject = PublishRelay<CLLocationCoordinate2D>()
    var filteredPlaces: PublishRelay<[Place]> = PublishRelay()
    
    ///서버에서 장소검색 api받아오기
    func checkSearchPlaceAccess(searchText: String){
        let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        let url = "\(Domain.REST_API)\(SearchPath.placeAndCategory)?query=\(encodedQuery)&page=1&categoryGroupCode=NONE"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: ResponseModel.self) { response in
                switch response.result {
                case .success(let data):
                    let filteredPlaces = data.results.map { $0 }
                    self.filteredPlaces.accept(filteredPlaces)
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    ///선택한 좌표로 coordinator로 전달
    func selectLocation(xCoordinate: Double, yCoordinate: Double) {
        selectedCoordinateSubject.accept(CLLocationCoordinate2D(latitude: yCoordinate, longitude: xCoordinate))
    }
}
