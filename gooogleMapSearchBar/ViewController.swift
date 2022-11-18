//
//  ViewController.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//

import UIKit
import GoogleMaps
class ViewController: UIViewController, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {
    let list_ = ["為愛往前飛", "我愛你這樣深", "難以抗拒你容顏", "流言", "你那麼愛她", "我還是愛你到老", "我是多麼認真對你", "體會", "怎麼開始忘了", "藏經閣", "白天不懂夜的黑"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list_.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for:indexPath)as
            UITableViewCell
            cell.imageView?.image=UIImage(systemName: "play.square.fill")//這裡要改成抓ＵＲＬ
            cell.textLabel?.text = list_[indexPath.row]
            return cell
    }
    
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GoogleMapV().mapView(mapView: mapView)
        tableView.isHidden = true
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.backgroundColor = .white
//
        
        
    }
}
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        var searchKeyWord:String = ""
        if let searchText:String = searchController.searchBar.text,searchText.isEmpty == false {
            searchKeyWord = searchText
        tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        }
}


