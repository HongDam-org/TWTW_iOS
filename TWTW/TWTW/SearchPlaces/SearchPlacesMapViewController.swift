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
    let disposeBag = DisposeBag()
    let cellIdentifier = "SearchPlacesTableViewCell"
    
    ///필터링지역들
    var filteredPlaces = [Place]()
    let viewModel: SearchPlacesMapViewModel
    //model로 뺄것mf
    var naviBarHeight :CGFloat =  0.0
    var NaviBarWidth : CGFloat = 0.0
    
    /// MARK: 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.delegate = self
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
        //delegate, dataSource
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(viewModel: SearchPlacesMapViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavi()
        addSubViews()
        backButtonAction()
        subscribeFilteredPlaces()
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
    
    // 필터링 장소 가저오기
    private func subscribeFilteredPlaces(){
        viewModel.filteredPlaces
            .subscribe(onNext: {[weak self] places in
                guard let self = self else {return}
                self.filteredPlaces = places
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Extension
extension SearchPlacesMapViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.filteredPlaces.accept([])
        }
        viewModel.checkSearchPlaceAccess(searchText: searchText)
    }
}

extension SearchPlacesMapViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchPlacesTableViewCell
        let place = filteredPlaces[indexPath.row]
        cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
        return cell
    }
}

extension SearchPlacesMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = filteredPlaces[indexPath.row]
        if let placeX = Double(place.x) , let placeY = Double(place.y){
            ///선택한 좌표이동
            viewModel.selectLocation(xCoordinate: placeX ,yCoordinate: placeY)
        }
    }
}

