//
//  SocketManager.swift
//  TWTW
//
//  Created by 정호진 on 1/15/24.
//

import Foundation
import StompClientLib

final class SocketManager {
    static let shared = SocketManager()
    private var socketClient: StompClientLib
    private init() {
        socketClient = StompClientLib()
    }
    
    func connect() {
        if socketClient.isConnected() {
            print("Socket is already connected!")
            return
        }
        
        let urlString = Domain.SOCKET + SocketPath.connect.rawValue
        let url = NSURL(string: urlString)!
        print("url", url)
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL), delegate: self)
    }
    
    func subscribe() {
        let groupId = KeychainWrapper.loadItem(forKey: "GroupId") ?? ""
        let urlString = SocketPath.subscribe.rawValue
            .replacingOccurrences(of: "GROUPID", with: groupId)
        print(#function, urlString)
        socketClient.subscribe(destination: urlString)
    }
    
    func send(info: SocketRequest) {
        let groupId = KeychainWrapper.loadItem(forKey: "GroupId") ?? ""
        let destination = SocketPath.send.rawValue
            .replacingOccurrences(of: "GROUPID", with: groupId)
        
        guard let object = codableToObject(from: info) else {
            print("Codable To Object is Error")
            return
        }
        
        socketClient.sendJSONForDict(dict: object, toDestination: destination)
    }
    
    /// Codable 타입을 AnyObject 타입으로 변환
    /// - Parameter codableObject: AnyObject로 변환할 Codable 객체
    /// - Returns: AnyObject 타입의 객체
    private func codableToObject<T: Codable>(from codableObject: T) -> AnyObject? {
        do {
            let encoder = JSONEncoder()
            encoder.nonConformingFloatEncodingStrategy = .throw
            let jsonData = try encoder.encode(codableObject)
            
            
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            if let jsonDictionary = jsonObject as? [String: Any] {
                print(jsonDictionary)
                return jsonDictionary as AnyObject
            }
        } catch {
            print("Error converting Codable object to AnyObject: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// AnyObject? 객체 Codable 객체로 변환
    /// - Parameters:
    ///   - object: AnyObject? 객체
    ///   - type: 변환할 Codable.self
    /// - Returns: Codable? 객체
    func decodeFromAnyObject<T: Codable>(_ object: AnyObject?, to type: T.Type) -> T? {
        do {
            // 1. AnyObject?를 JSON 데이터로 변환
            let jsonData = try JSONSerialization.data(withJSONObject: object as Any, options: [])

            // 2. JSON 데이터를 원하는 Codable 객체로 디코딩
            let decoder = JSONDecoder()
            let decodedObject = try decoder.decode(type, from: jsonData)
            
            return decodedObject
        } catch {
            print("Error decoding object: \(error.localizedDescription)")
            return nil
        }
    }
}

extension SocketManager: StompClientLibDelegate {
    func stompClient(client: StompClientLib!,
                     didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?,
                     withHeader header: [String: String]?,
                     withDestination destination: String) {
        print(#function)
        print("jsonBody", jsonBody)
        print("header", header)
        print("destination", destination)
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        client.connection = false
        print("Socket is DisConnected")
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        print("Socket is connected")
        if client.connection {
            self.subscribe()
        }
    }
    
    func serverDidSendReceipt(client: StompClientLib!,
                              withReceiptId receiptId: String) {
        print("Receipt : \(receiptId)")
    }
    
    func serverDidSendError(client: StompClientLib!,
                            withErrorMessage description: String,
                            detailedErrorMessage message: String?) {
        print("Error Send : \(String(describing: message))")
    }
    
    func serverDidSendPing() {
        print("Server ping")
    }
}
