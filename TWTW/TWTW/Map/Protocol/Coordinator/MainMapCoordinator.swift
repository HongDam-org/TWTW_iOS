//
//  MainMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

protocol MainMapCoordinator : Coordinator {
    func showSearchPlacesMap(output: MainMapViewModel.Output)
}
