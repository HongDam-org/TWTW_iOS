//
//  Bundle+Ext.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/05.
//

import Foundation

extension Bundle {
    
    var KAKAO_NATIVE_APP_KEY: String {
        return getSecretKey(key: "KAKAO_NATIVE_APP_KEY")
    }
    
 
    
    // SecretKey.plist에서 값 가져오기
    /// - parameter key : SecretKey.plist에 등록된 Key
    /// - returns : Key에 해당하는 Value
    func getSecretKey(key: String) -> String {
        guard let file = self.path(forResource: "SecretKey", ofType: "plist") else { return "" }
        
        // .plist를 딕셔너리로 받아오기
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        // 딕셔너리에서 값 찾기
        guard let key = resource[key] as? String else {
            fatalError("\(key) error")
        }
        return key
    }
}
