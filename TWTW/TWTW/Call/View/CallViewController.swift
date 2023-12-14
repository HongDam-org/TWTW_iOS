//
//  CallViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import CallKit
import Foundation
import PushKit
import UIKit

/// 통화하기
final class CallViewController: UIViewController {
    private let cxProvider = CXProvider(configuration: CXProviderConfiguration())
    let callController = CXCallController()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        registry()
        
    }
    
    /// 전화 하기
    private func outgoing() {
        let uuid = UUID()
        let handle = CXHandle(type: .phoneNumber, value: "01041007930")
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        let transaction = CXTransaction(action: startCallAction)
        
        print(#function, uuid, handle)
        callController.request(transaction) { error in
            print(error ?? "")
            print("Start Call")
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 5) {
            self.cxProvider.reportOutgoingCall(with: self.callController.callObserver.calls[0].uuid, connectedAt: nil)
        }
    }
    
    /// registry
    private func registry() {
        let registry = PKPushRegistry(queue: nil)
        registry.delegate = self
        registry.desiredPushTypes = [PKPushType.voIP]
    }
    
}

extension CallViewController: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fulfill()
    }
    
    // 전화 걸기 델리게이트 메소드
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        print(#function, provider, action)
        action.fulfill()
    }
}


extension CallViewController: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceID = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print(#function, deviceID)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let config = CXProviderConfiguration()
        config.includesCallsInRecents = false
        config.supportsVideo = true;
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: "Fomagran")
        update.hasVideo = true
        provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
    }
}
