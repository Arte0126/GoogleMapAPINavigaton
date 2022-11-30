//
//  MySearchController.swift
//  GoogleMapAPINavigation
//
//  Created by 李晉杰 on 2022/11/23.
//

import UIKit

class MySearchController: UISearchController {
    let searchController = UISearchController()
    var tableViewState:Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
//        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.backgroundColor = .white
        
    }
}
//extension MySearchController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        print(123)
//        var searchKeyWord:String = ""
//        if let searchText:String = searchController.searchBar.text,searchText.isEmpty == false {
//            searchKeyWord = searchText
//            var SearchData =  GoogleMapM<textSearchData>()
////            SearchData.parserData(keyWord: searchKeyWord, lat: mapMyLatVal, lng: mapMyLngVal) {
////                [weak self] SearchDataMIResult in
////                self?.searchResultList = SearchDataMIResult.searchResultList
////                self?.searchResultLatList = SearchDataMIResult.searchResultLatList
////                self?.searchResultLngList = SearchDataMIResult.searchResultLngList
////                self?.tableView.reloadData()
////            }
//            tableViewState = false
//            ViewController().tableViewState = tableViewState
////        tableView.isHidden = false
//        }
//        else {
//            tableViewState = false
//            ViewController().tableViewState = tableViewState
////            tableView.isHidden = true
//        }
//        }
//}
