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
    let cellIdentifier = "SearchPlacesTableViewCell"
    
    ///필터링지역들
    var viewModel: SearchPlacesMapViewModel?
    var naviBarHeight :CGFloat =  0.0
    var NaviBarWidth : CGFloat = 0.0
    
    /// MARK: 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = .white
        return searchBar
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavi()
        addSubViews()
        backButtonAction()
        hideKeyboard()
        
    }
    
    ///mark: - 네비게이션 item보이기
    private func setNavi(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        naviBarHeight = navigationController?.navigationBar.frame.height ?? 10
    }
    
    /// MARK: Add  UI - SearchBar
    private func addSubViews(){
        view.addSubview(searchBar)
        view.addSubview(backButton)
        view.addSubview(tableView)
        tableView.register(SearchPlacesTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        bindViewModel()
        configureConstraints()
    }
    
    ///MARK: - keyboard내림
    private func hideKeyboard() {
        tableView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    /// MARK: Configure   Constraints
    private func configureConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().inset(naviBarHeight)
            make.trailing.equalToSuperview().inset(5)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().inset(5)
            make.width.height.equalTo(searchBar.snp.height)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    ///mark: 커스텀 네비게이션 뒤로가기 버튼
    private func backButtonAction(){
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
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
        output?.filteredPlaces
            .bind(to: tableView.rx.items(cellIdentifier: cellIdentifier, cellType: SearchPlacesTableViewCell.self)) { row, place, cell in
                cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
            }
            .disposed(by: disposeBag)
    }
}
/*
 private func configureTableView() {
 tableView.rx.itemSelected
 .subscribe(onNext: { [weak self] indexPath in
 if let place = self?.viewModel.output.filteredPlaces.value[indexPath.row] {
 if let placeX = Double(place.x), let placeY = Double(place.y) {
 self?.viewModel.selectLocation(xCoordinate: placeX, yCoordinate: placeY)
 }
 
 */
extension SearchPlacesMapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
}
