//
//  SearchPlacesMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/22.
//

import Alamofire
import CoreLocation
import Foundation
import RxCocoa
import RxSwift
import UIKit

/// 검색 결과를 표시하는 새로운 View Controller
final class SearchPlacesMapViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    /// 필터링지역들
    var viewModel: SearchPlacesMapViewModel?
    
    /// 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        return searchBar
    }()
    
    /// 검색된 지역테이블
    private lazy var placesTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavi()
        addSubViews()
        hideKeyboard()
        
    }
    
    /// 네비게이션 item보이기
    private func setNavi() {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /// Add  UI - SearchBar
    private func addSubViews() {
        navigationItem.titleView = searchBar
        view.addSubview(placesTableView)
        placesTableView.register(SearchPlacesTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchPlacesTableViewCell.rawValue)
        bindViewModel()
        configureConstraints()
    }
    
    /// keyboard내림
    private func hideKeyboard() {
        placesTableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    /// Configure   Constraints
    private func configureConstraints() {
        placesTableView.snp.makeConstraints { make in
            make.edges.equalTo(additionalSafeAreaInsets)
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        let searchTextRelay = BehaviorRelay<String>(value: searchBar.text ?? "")
        let loadMoreTrigger = PublishRelay<Void>() // 추가 데이터 로드 트리거
        
        // Input 생성
        let input = SearchPlacesMapViewModel.Input(searchText: searchTextRelay, 
                                                   loadMoreTrigger: loadMoreTrigger,
                                                   selectedCoorinate: placesTableView.rx.modelSelected(SearchPlace.self).asObservable())
        let output = viewModel.bind(input: input)
        
        // 검색 텍스트를 업데이트하면 searchTextRelay에 바인딩
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { searchText in
                searchTextRelay.accept(searchText)
            })
            .disposed(by: disposeBag)
        
        // 테이블 뷰
        placesTableView.rx.contentOffset
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }
                
                let scrollViewHeight = self.placesTableView.bounds.size.height
                let contentSizeHeight = self.placesTableView.contentSize.height
                let bottomInset = self.placesTableView.contentInset.bottom
                
                // 테이블뷰의 스크롤이 맨 아래로 내렸을 때
                if contentOffset.y >= contentSizeHeight - scrollViewHeight - bottomInset {
                    loadMoreTrigger.accept(()) // 추가 데이터 로드 트리거
                }
            })
            .disposed(by: disposeBag)
        
        // 결과 데이터를 표시
        output.filteredPlaces
            .bind(to: placesTableView.rx
                .items(cellIdentifier: CellIdentifier.searchPlacesTableViewCell.rawValue,
                       cellType: SearchPlacesTableViewCell.self)) { row, place, cell in
                cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
            }
                       .disposed(by: disposeBag)
        
    }
}
 //   private func bindSearchPlaceFiltering(output: SearchPlacesMapViewModel.Output?) {
        // PlaceResponseModel에서 results 추출하고 다시 Observable감싸기
//        output?.filteredPlaces
//            .map{
//                $0?.results ?? []
//            }
//            .bind(to: placesTableView.rx
//                .items(cellIdentifier: CellIdentifier.searchPlacesTableViewCell.rawValue,
//                       cellType: SearchPlacesTableViewCell.self)) { row, place, cell in
//                cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
//            }
//            .disposed(by: disposeBag)
//
//        placesTableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                if let placeResponseModel = try? output?.filteredPlaces.value(), // filteredPlaces가 옵셔널이라 try? 사용
//                   !placeResponseModel.isEmpty,
//                   indexPath.row < placeResponseModel.first!.results.count,
//                   let selectedPlace = placeResponseModel.first!.results[indexPath.row] as? SearchPlace {
//                    if let placeX = Double(selectedPlace.x), let placeY = Double(selectedPlace.y) {
//                        let coordinate = CLLocationCoordinate2D(latitude: placeY, longitude: placeX)
//                        // print(placeResponseModel.first!)
//                        self?.viewModel?.selectedCoordinate.accept(coordinate)
//                    }
//                }
//            })
//            .disposed(by: disposeBag)}
//}
