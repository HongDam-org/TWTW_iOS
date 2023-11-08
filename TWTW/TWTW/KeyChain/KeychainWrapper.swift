//
//  KeychainWrapper.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/07.
//

import Foundation

/// 키체인
final class KeychainWrapper {
    
    /// 문자열 값을 Keychain에 저장하는 함수
    static func saveString(value: String, forKey key: String) -> Bool {
        
        /// 문자열을 Data로 변환
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword, // Keychain 클래스 (일반적으로 비밀번호)
                kSecAttrAccount as String: key, // 키
                kSecValueData as String: data, // 데이터
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]
            
            SecItemDelete(query as CFDictionary) // 이미 키에 저장된 값이 있다면 삭제
            let status = SecItemAdd(query as CFDictionary, nil) // Keychain에 새로운 값 저장
            return status == errSecSuccess// 저장 성공 여부를 리턴
        }
        return false
    }
    
    /// Keychain에서 문자열 값을 로드하는 함수
    static func loadString(forKey key: String) -> String? {
        guard let kCFBooleanTrue = kCFBooleanTrue else {return nil}
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue, // 데이터 반환 설정
            kSecMatchLimit as String: kSecMatchLimitOne // 로드할 값이 하나라는 것을 설정
        ]
        var result: AnyObject?
        
        // Keychain에서 값 로드
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // 값이 로드되고 변환이 성공 시
        if status == errSecSuccess, let data = result as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        }
        return nil
    }
    
    static func delete(key: String) -> Bool {
        let deleteQuery: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                            kSecAttrAccount: key]
        let status = SecItemDelete(deleteQuery as CFDictionary)
        if status == errSecSuccess { return true }
        
        print("deleteItem Error : \(status.description)")
        return false
    }
}
