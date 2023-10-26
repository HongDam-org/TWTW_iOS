//
//  SearchPlacesMapService.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/26.
//

import Foundation
import Alamofire

final class SearchPlacesMapService {
    static func checkSearchPlaceAccess(searchText: String, completion: @escaping ([Place]?, Error?) -> Void) {
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
                    completion(filteredPlaces, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
            }
    }
}
