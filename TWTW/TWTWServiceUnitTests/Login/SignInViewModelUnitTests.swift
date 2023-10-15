//
//  TWTWUnitTests.swift
//  TWTWUnitTests
//
//  Created by 정호진 on 10/12/23.
//

import XCTest
import RxSwift
import RxTest

@testable import TWTW

final class SignInViewModelUnitTests: XCTestCase {
    
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: SignInViewModel!
    private var output: SignInViewModel.Output!
    
    /// MARK: - Test Setting
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        
        let mockCoordinator = MockSignInCoordinator(childCoordinators: [], navigationController: UINavigationController())
        viewModel = SignInViewModel(coordinator: mockCoordinator,
                                    signInServices: MockSignInService())
        disposeBag = DisposeBag()
        self.output = viewModel.createOutput()
        print("Start Unit Test")
    }

    /// MARK: - finsih test
    override func tearDownWithError() throws {
        disposeBag = nil
        scheduler = nil
        viewModel = nil
    }
    
    /// 토큰이 유효한지 테스트
    /// 새로운 토큰 발급받는 테스트까지 진행
    func testCheckValidate(){
        let checkAccessTokenObserver = self.scheduler.createObserver(Bool.self)

        viewModel.checkAccessTokenValidation(output: output)
        
        output.checkAccessTokenValidation
            .subscribe(checkAccessTokenObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(checkAccessTokenObserver.events, [ /*.next(0, true),*/
                                                          .next(0, false), ])

        
    }
    
    /// 회원인지 아닌지 구분하는 테스트..
    func testSignInService(){
        let checkSignInServiceObserver = self.scheduler.createObserver(String?.self)
        
        viewModel.signInService(authType: "SIGNUP", identifier: "12345",output: output)
        
        output.checkSignInService.subscribe(checkSignInServiceObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(checkSignInServiceObserver.events, [ .next(0, LoginStatus.SignIn.rawValue) ])
        
    }

}
