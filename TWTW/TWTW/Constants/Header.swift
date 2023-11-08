//
//  Header.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/07.
//

import Alamofire
import Foundation

enum Header {
    case header
    
    func getHeader() -> HTTPHeaders {
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
        return ["Authorization": "Bearer \(accessToken)"]
    }
}
