//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import RxSwift

import KakaoSDKCommon
import RxKakaoSDKCommon

import KakaoSDKAuth
import RxKakaoSDKAuth

import KakaoSDKFriend

extension PickerApi: ReactiveCompatible {}

/// 친구 피커 API 호출을 담당하는 클래스입니다.
extension Reactive where Base: PickerApi  {
    
    /// 여러 명의 친구를 선택(멀티 피커)할 수 있는 친구 피커를 화면 전체에 표시합니다.
    /// ## SeeAlso
    /// - ``OpenPickerFriendRequestParams``
    public func selectFriends(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in            
            PickerApi.shared.selectFriends(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 여러 명의 친구를 선택(멀티 피커)할 수 있는 친구 피커를 팝업 형태로 표시합니다.
    /// ## SeeAlso
    /// - ``OpenPickerFriendRequestParams``
    public func selectFriendsPopup(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriendsPopup(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 한 명의 친구만 선택(싱글 피커)할 수 있는 친구 피커를 화면 전체에 표시합니다.
    /// ## SeeAlso
    /// - ``OpenPickerFriendRequestParams``
    public func selectFriend(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriend(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 한 명의 친구만 선택(싱글 피커)할 수 있는 친구 피커를 팝업 형태로 표시합니다.
    /// ## SeeAlso
    /// - ``OpenPickerFriendRequestParams``
    public func selectFriendPopup(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriendPopup(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
}

