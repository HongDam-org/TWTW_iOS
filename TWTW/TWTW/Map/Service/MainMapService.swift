//
//  MainMapService.swift
//  TWTW
//
//  Created by 정호진 on 1/17/24.
//

import Alamofire
import RxSwift

final class MainMapService: MainMapProtocol {
    
    func getMyInformation() -> Observable<MyInfo> {
        let url = Domain.RESTAPI + LoginPath.myInfo.rawValue
        let header = Header.header.getHeader()
        
        return Observable.create { observer in
            AF.request(url,
                       method: .get,
                       headers: header)
            .responseDecodable(of: MyInfo.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
}
