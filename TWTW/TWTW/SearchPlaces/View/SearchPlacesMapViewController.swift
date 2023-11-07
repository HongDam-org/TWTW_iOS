//
//  SearchPlacesMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire
import CoreLocation

///mark: - 검색 결과를 표시하는 새로운 View Controller
final class SearchPlacesMapViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    ///필터링지역들
    var viewModel: SearchPlacesMapViewModel?
    
    /// MARK: 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        return searchBar
    }()
    ///Mark: - 검색된 지역테이블
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
    ///mark: - 네비게이션 item보이기
    private func setNavi(){
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /// MARK: Add  UI - SearchBar
    private func addSubViews(){
        //view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        view.addSubview(placesTableView)
        placesTableView.register(SearchPlacesTableViewCell.self, forCellReuseIdentifier: CellIdentifier.searchPlacesTableViewCell.rawValue)
        bindViewModel()
        configureConstraints()
    }
    
    ///MARK: - keyboard내림
    private func hideKeyboard() {
        placesTableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    /// MARK: Configure   Constraints
    private func configureConstraints() {
        placesTableView.snp.makeConstraints { make in
            make.edges.equalTo(additionalSafeAreaInsets)
        }
    }
    
    
    private func bindViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        // searchText를 위한 BehaviorRelay 생성
        let searchTextRelay = BehaviorRelay<String>(value: searchBar.text ?? "")
        
        // searchTextRelay를 사용하여 입력을 설정
        let input = SearchPlacesMapViewModel.Input(searchText: searchTextRelay)
        let output = viewModel.bind(input: input)
        
        // searchBar 텍스트를 searchTextRelay에 바인딩
        searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 디바운스를 추가하여 입력 지연 처리
            .distinctUntilChanged() // 이전 값과 동일한 값은 무시
            .subscribe(onNext: { searchText in
                searchTextRelay.accept(searchText) // searchTextRelay에 텍스트를 업데이트
            })
            .disposed(by: disposeBag)
        
        bindSearchPlaceFiltering(output: output)
    }
    
    private func bindSearchPlaceFiltering(output: SearchPlacesMapViewModel.Output?) {
        //PlaceResponseModel에서 results 추출하고 다시 Observable감싸기
        output?.filteredPlaces
            .map{
                $0?.results ?? []
            }
            .bind(to: placesTableView.rx.items(cellIdentifier: CellIdentifier.searchPlacesTableViewCell.rawValue, cellType: SearchPlacesTableViewCell.self)) { row, place, cell in
                cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
            }
            .disposed(by: disposeBag)
        
        placesTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                if let placeResponseModel = try? output?.filteredPlaces.value(), // filteredPlaces가 옵셔널이라 try? 사용
                   !placeResponseModel.isEmpty,
                   indexPath.row < placeResponseModel.first!.results.count,
                   let selectedPlace = placeResponseModel.first!.results[indexPath.row] as? SearchPlace {
                    if let placeX = Double(selectedPlace.x), let placeY = Double(selectedPlace.y) {
                        let coordinate = CLLocationCoordinate2D(latitude: placeY, longitude: placeX)
                        // print(placeResponseModel.first!)
                        self?.viewModel?.selectedCoordinate.accept(coordinate)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

