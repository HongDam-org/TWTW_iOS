//
//  SignUpViewModelUnitTests.swift
//  TWTWUnitTests
//
//  Created by 정호진 on 10/16/23.
//

import XCTest
import RxSwift
import RxTest

@testable import TWTW

final class SignUpViewModelUnitTests: XCTestCase {

    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: SignUpViewModel!
    private var input: SignUpViewModel.Input!
    private var output: SignUpViewModel.Output!
    
    override func setUpWithError() throws {
        scheduler = TestScheduler(initialClock: 0)
        viewModel = SignUpViewModel(coordinator: nil,
                                    signUpServices: MockSignUpService())
        disposeBag = DisposeBag()
        print("Start SignUpViewModelUnitTests Unit Test")
    }

    override func tearDownWithError() throws {
        disposeBag = nil
        scheduler = nil
        viewModel = nil
    }
    
    func testNickNameEdit() {
        let inputTextTestableObservable = self.scheduler.createHotObservable([
            .next(5, "hello"),
            .next(10, "hello1234"),
            .next(20, "h"),
        ])
        
        let filteringObserver = self.scheduler.createObserver(String.self)
        
        self.input = SignUpViewModel.Input(
            doneButtonTapEvents: Observable.just(()),
            keyboardReturnTapEvents: Observable.just(()),
            nickNameEditEvents: inputTextTestableObservable.asObservable(),
            imageButtonTapEvents: Observable.just(())
        )
        self.output = viewModel.bind(input: input)
        
        output.nickNameFilteringRelay.subscribe(filteringObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(filteringObserver.events, [
            .next(0, ""),
            .next(5, "hello"),
            .next(10, "hello123"),
            .next(20, "h"),
        ])
        
    }

}
