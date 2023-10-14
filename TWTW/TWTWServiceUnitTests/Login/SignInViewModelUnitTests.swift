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
    
    /// MARK: - Test Setting
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        
        let mockCoordinator = MockSignInCoordinator(childCoordinators: [], navigationController: UINavigationController())
        mockCoordinator.delegate = self
        viewModel = SignInViewModel(coordinator: mockCoordinator,
                                    signInServices: MockSignInService())
        disposeBag = DisposeBag()
    }

    /// MARK: - finsih test
    override func tearDownWithError() throws {
        disposeBag = nil
        scheduler = nil
        viewModel = nil
    }
    
    func testCheckValidate(){
        viewModel.checkAccessTokenValidation()
        
        
    }
    
    

}

extension SignInViewModelUnitTests: MockSignInCoordinatorDelegate{
    func moveMain(function: String) {
        <#code#>
    }
}
