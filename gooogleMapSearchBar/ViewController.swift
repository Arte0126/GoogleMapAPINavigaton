//
//  ViewController.swift
//  gooogleMapSearchBar
//
//  Created by 李晉杰 on 2022/11/16.
//

import UIKit
import GoogleMaps
import Polyline
class ViewController: UIViewController {
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var routerButton: UIButton!
    @IBOutlet weak var reSetButton: UIButton!
    @IBOutlet weak var navRemindCell: UITableViewCell!
    @IBOutlet weak var navRemindImage: UIImageView!//導航－路標
    @IBOutlet weak var navRemindTIttleLab: UILabel!//導航－路名
    @IBOutlet weak var navRemindContentLab: UILabel!//導航－內容
    @IBOutlet weak var navRemindDistanceLab: UILabel!//導航－下一個提示剩餘距離
    @IBOutlet weak var navStartButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    var mapLocationManager = CLLocationManager() // GPS物件
    var mapViewForUI: GMSMapView!//MapView畫面繼承
    var GpsLatVal:Double = 0
    var GpsLngVal:Double = 0
    var GpsSpeedVal:Double = 0
    var mapClickAnnLatVal:Double = 0
    var mapClickAnnLngVal:Double = 0
    let searchController = UISearchController()
    var searchResultList:[String] = [] //searchBar返回資料（名稱）
    var searchResultLatList:[Double] = []//searchBar返回資料（經度）
    var searchResultLngList:[Double] = []//searchBar返回資料（緯度）
    var path = GMSPath() //路徑規劃物件
    var polyline = GMSPolyline() //路徑規劃物件
    var polylinePoint:[CLLocationCoordinate2D] = []//目的地路徑（畫面）
//    var polylinePointDistanceVal:Double = 0 //polyline每兩點距離
    var polylinePointDistanceList:[Double] = [] //polyline所有兩點距離陣列
    var polylinePointAngleList:[Double] = [] //polyline所有兩點方向角陣列
//    var polylinePointDistanceAddList:[Double] = [] // 將polyline每點的距離疊加並裝進陣列
//    var polylinePointLatList:[Double] = [] // polyline所有經度組成陣列
//    var polylinePointLngList:[Double] = []// polyline所有緯度組成陣列
    var polylineSmallPointLatList:[Double] = [] //polyline所有座標切成個多點後取出所有經度組成陣列
    var polylineSmallPointLngList:[Double] = []//polyline所有座標切成個多點後取出所有緯度組成陣列
    var timerForNav = Timer() //慣性導航排程
    var speedForAmount = 0.0
    var navTimeCountForSmallPoint = 0 // 小點次數計算(讓畫面知道現在顯示到第幾個)
    var navTimeCountForAngle = 0 // 小點次數計算（拿來跟polylinePointDistanceList[navPolylineCount]比，要歸零）
    var navPolylineCount = 0 // 第幾段距離
    var newMyLatValFromInertia:Double = 0
    var newMyLngValFromInertia:Double = 0
    var navManeuverList:[String] = []
    var navStepsRemindList:[String] = []
    var navStepsTittleList:[String] = []
    var navStepsLatList:[Double] = []
    var navStepsLngList:[Double] = []
    var navStepCount = 0
    var navStepToInertiDistanceVal:Double = 0
    var snapLat:Double = 0
    var snapLng:Double = 0
    var viewState = State.gps
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewState == State.gps{
            reSetButton.isHidden = true
        }
        navRemindCell.isHidden = true
        arrowImage.image = UIImage(named: "arrow")
        arrowImage.isHidden = true
        searchBarTableViewSet()
        searchControllerSet()
        mapViewSet()
        mapLocationSet()
    }
    func searchControllerSet() {
        searchController.searchBar.sizeToFit()
        navigationItem.titleView = searchController.searchBar
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.backgroundColor = .white
    }
    func searchBarTableViewSet() {
        tableView.isHidden = true
    }
    func mapViewSet() {
        let camera = GMSCameraPosition(latitude: 22.651061, longitude: 120.312894, zoom: 15)
        mapViewForUI = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        mapViewForUI.delegate = self
        mapViewForUI.isMyLocationEnabled = true
        mapView.addSubview(mapViewForUI)
    }
    func cameraSet(lat:Double,lng:Double,zoom:Double,angle:Double) {
        let camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: Float(zoom))
        self.mapViewForUI.camera = camera
        self.mapViewForUI.animate(toViewingAngle: angle)
    }
    func animateCamerSet(lat:Double,lng:Double,zoom:Double,angle:Double ,Bear:Double) {
        CATransaction.begin()
        CATransaction.setValue(speedForAmount, forKey: kCATransactionAnimationDuration)
        self.mapViewForUI.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        self.mapViewForUI.animate(toBearing:Bear)
        self.mapViewForUI.animate(toViewingAngle: angle)
        self.mapViewForUI.animate(toZoom: Float(zoom))
        if speedForAmount != 0 {
            CATransaction.commit()
        }
    }
    func marketSet(lat:Double,lng:Double) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.map = self.mapViewForUI
    }
    func mapLocationSet() {
        if CLLocationManager.headingAvailable() {
            mapLocationManager.headingFilter = 5
            mapLocationManager.startUpdatingHeading()
        }
        mapLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        mapLocationManager.delegate = self
        mapLocationManager.requestWhenInUseAuthorization()
        mapLocationManager.startUpdatingLocation()
    }
    @IBAction func reSetButton(_ sender: Any) {
        switch viewState {
        case State.navigation:
            mapViewReSet()
            searchController.searchBar.isHidden = false // 開啟搜尋ＵＩ
            navRemindCell.isHidden = true //關閉導航提示
            arrowImage.isHidden = true //導航icon關閉
            viewState = State.gps
            deleteButton.isEnabled = true
            reSetButton.isHidden = true
//            navTimeCountForSmallPoint = 0 // 小點次數計算(讓畫面知道現在顯示到第幾個)
//            navTimeCountForAngle = 0 // 小點次數計算（拿來跟polylinePointDistanceList[navPolylineCount]比，要歸零）
//            navPolylineCount = 0 // 第幾段距離
//            navStepCount = 0
            navigationCancel()
        default: break
        }
    }
    @IBAction func routerButton(_ sender: Any) {
        switch viewState {
        case State.router:
            UIApplication.shared.keyWindow?.showToast(text:"路徑已經規劃")
        case State.navigation:
            UIApplication.shared.keyWindow?.showToast(text:"導航已經開始，無法規劃路徑")
        case State.gps:
            if mapClickAnnLatVal != 0 {
                mapRouteDataGet(myLat:GpsLatVal, myLng:GpsLngVal, annLat:mapClickAnnLatVal ,annLng:mapClickAnnLngVal)
                viewState = State.router
            }else {
                UIApplication.shared.keyWindow?.showToast(text:"請選擇目的地")
            }
        }
    }
    @IBAction func navStartButton(_ sender: Any) {
        switch viewState {
        case State.router:
            searchController.searchBar.isHidden = true // 關掉搜尋ＵＩ
            viewState = State.navigation
            deleteButton.isEnabled = false // 刪除座標按鈕失效
            reSetButton.isHidden = false  // 開啟reSet
            navRemindCell.isHidden = false // 開啟導航提示
            arrowImage.isHidden = false //導航icon開啟
            NavigationDataGet(myLat: GpsLatVal,myLng: GpsLngVal,annLat:mapClickAnnLatVal ,annLng:mapClickAnnLngVal)
            navPolyLineProcess()
        case State.navigation:
            UIApplication.shared.keyWindow?.showToast(text:"導航已經開始")
        case State.gps:
            UIApplication.shared.keyWindow?.showToast(text:"請先規劃路徑")
        }
    }
    @IBAction func deleteButton(_ sender: Any) {
        mapViewReSet()
    }
    func mapViewReSet() {
        self.timerForNav.invalidate()
        self.animateCamerSet(lat:GpsLatVal, lng:GpsLngVal, zoom:15, angle:0, Bear:0)
        mapViewForUI.clear()
        mapClickAnnLatVal = 0
        mapClickAnnLngVal = 0
    }
    func navigationCancel() {
        mapViewForUI.clear()
        navTimeCountForSmallPoint = 0 // 小點次數計算(讓畫面知道現在顯示到第幾個)
        navTimeCountForAngle = 0 // 小點次數計算（拿來跟polylinePointDistanceList[navPolylineCount]比，要歸零）
        navPolylineCount = 0 // 第幾段距離
        navStepCount = 0
    }
    func navPolyLineProcess() {
        polylinePointAngleList = InertiaPoint().getpolylineListForAngle(polylinePoint: polylinePoint)
        polylinePointDistanceList = InertiaPoint().getPolylineListForDistance(polylinePoint: polylinePoint)
        let polylineSmallPoint = InertiaPoint().getPolylineListForSmallPoint(polylinePoint:polylinePoint)
        polylineSmallPointLatList = polylineSmallPoint.0
        polylineSmallPointLngList = polylineSmallPoint.1
        navigationInertiForStart()
    }
    func textSearchDataGet(keyWord: String, lat: Double, lng: Double) {
        GoogleMapM<textSearchData>().textSearchDataParser(keyWord: keyWord, lat: lat, lng: lng){
            [weak self] textSearchResult in
            self?.searchResultList = textSearchResult.searchResultList
            self?.searchResultLatList = textSearchResult.searchResultLatList
            self?.searchResultLngList = textSearchResult.searchResultLngList
            self?.tableView.reloadData()
        }
    }
    func snapToRoadsDataGet(myLat:Double,myLng:Double) {
        GoogleMapM<snapToRoadsData>().snapToRoadsParser(myLat: myLat, myLng: myLng) { [weak self] snapToRoadsDataResult in
            self?.snapLat = snapToRoadsDataResult.latitude
            self?.snapLng = snapToRoadsDataResult.longitude
        }
    }
    func mapRouteDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
        GoogleMapM<MapRouteData>().mapRouteDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
            [weak self]  mapRouteDataResult in
            for i in 0...mapRouteDataResult.points.count-1 {
                self?.path = GMSPath(fromEncodedPath:mapRouteDataResult.points[i])!
                self?.polyline = GMSPolyline(path: self?.path)
                self?.polyline.strokeWidth = 15
                self?.polyline.strokeColor = .red
                self?.polyline.map = self?.mapViewForUI
                self?.polylinePoint = decodePolyline(mapRouteDataResult.polylinePoint)!
                let pathForCamera = GMSPath(fromEncodedPath: mapRouteDataResult.polylinePoint)!
                let bounds = GMSCoordinateBounds(path:pathForCamera)
                let camera = GMSCameraUpdate.fit(bounds, withPadding: 140)
                self?.mapViewForUI.animate(with: camera)
            }
        }
    }
    func NavigationDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double) {
        GoogleMapM<NavigationData>().NavigationParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
            [weak self]  navigationDataResult in
            for i in 0...navigationDataResult.navStepsLatList.count-1 {
                self?.navManeuverList = navigationDataResult.navManeuverList
                self?.navStepsRemindList = navigationDataResult.navStepsRemindList
                self?.navStepsTittleList = navigationDataResult.navStepsTittleList
                self?.navStepsLatList = navigationDataResult.navStepsLatList
                self?.navStepsLngList = navigationDataResult.navStepsLngList
            }
        }
    }
    func navigationInertiForStart() {
            self.timerForNav.invalidate()
        var coefficient:Double = 0.9
            speedForAmount = 1 / GpsSpeedVal
            if GpsSpeedVal >= 0 {
            self.timerForNav = Timer.scheduledTimer(timeInterval: speedForAmount * coefficient, target: self, selector: #selector(self.navigationInertiForCountSet), userInfo: nil, repeats: true)
            }
    }
    @objc func navigationInertiForCountSet() {
        if  GpsSpeedVal >= 0 {
            navTimeCountForSmallPoint = navTimeCountForSmallPoint+1
            navTimeCountForAngle = navTimeCountForAngle + 1
            let amount = Int(1 * navTimeCountForSmallPoint)
            if polylinePointDistanceList.count >  0 {
                navigationInertiForNextPoint(amount: amount)
            }
        }
    }
    func navigationInertiForNextPoint(amount:Int){
        stepCalculate()
        if navTimeCountForAngle > Int(polylinePointDistanceList[navPolylineCount]) { //
            navPolylineCount = navPolylineCount+1
            navTimeCountForAngle = 0
        }
        if polylineSmallPointLatList.count > amount {
            newMyLatValFromInertia = polylineSmallPointLatList[amount]
            newMyLngValFromInertia = polylineSmallPointLngList[amount]
            let cameraButton = GoogleMapVM().cameraPositionToBottom(polylinePointAngleList[navPolylineCount],newMyLatValFromInertia, newMyLngValFromInertia)
            animateCamerSet(lat:cameraButton.0, lng: cameraButton.1, zoom:19.5, angle:80, Bear: polylinePointAngleList[navPolylineCount])
        }
    }
    func stepCalculate() {
        navStepToInertiDistanceVal = GoogleMapVM().getDistance(lat1: newMyLatValFromInertia, lng1: newMyLngValFromInertia, lat2: navStepsLatList[navStepCount], lng2: navStepsLngList[navStepCount])
        if navStepToInertiDistanceVal < 1 {
            navStepCount = navStepCount + 1
        }
        navRemindDistanceLab.text = "剩餘:\( String(format: "%.1f", navStepToInertiDistanceVal))公尺"
        getNavManeuverList()
        getNavStepsRemindList()
        getNavStepsTittleList()
    }
    func getNavManeuverList() {
        switch navManeuverList[navStepCount]{
            case "turn-right":
                navRemindImage.image = UIImage(systemName:"arrowshape.turn.up.forward.fill")
            case "keep-right":
                navRemindImage.image = UIImage(systemName:"arrow.up.right")
            case "turn-left":
                navRemindImage.image = UIImage(systemName:"arrowshape.turn.up.backward.fill")
            case "keep-left":
                navRemindImage.image = UIImage(systemName:"arrow.up.left")
            default:
                navRemindImage.image = UIImage(systemName:"location.north.fill")
        }
//        print(navManeuverList[navStepCount])
    }
    func getNavStepsRemindList() {
        if navStepToInertiDistanceVal <= 200 {
            navRemindContentLab.text = navStepsRemindList[navStepCount]
        } else {
            navRemindContentLab.text = "請繼續直行"
            navRemindImage.image = UIImage(systemName:"location.north.fill")
        }
    }
    func getNavStepsTittleList() {
        if navStepCount > 0 {
            navRemindTIttleLab.text = navStepsTittleList[navStepCount-1]
        } else { navRemindTIttleLab.text = navStepsTittleList[navStepCount] }
    }
    func yawDecide() {
        var state = YawAlgorithm().YawAlgorithm1(newMyLatValFromInertia, newMyLngValFromInertia, GpsLatVal, GpsLngVal)
         if state == true {
//             mapViewForUI.clear()
//             navTimeCountForSmallPoint = 0 // 小點次數計算(讓畫面知道現在顯示到第幾個)
//             navTimeCountForAngle = 0 // 小點次數計算（拿來跟polylinePointDistanceList[navPolylineCount]比，要歸零）
//             navPolylineCount = 0 // 第幾段距離
//             navStepCount = 0
             navigationCancel()
//             mapRouteDataGet(myLat: GpsLatVal, myLng: GpsLngVal, annLat: mapClickAnnLatVal, annLng: mapClickAnnLngVal)
             mapRouteDataGet(myLat: GpsLatVal, myLng: GpsLngVal, annLat: mapClickAnnLatVal, annLng: mapClickAnnLngVal)
         }
    }
}
extension ViewController:UITableViewDelegate,UITableViewDataSource { //搜尋後下拉選單畫面
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for:indexPath)as
        UITableViewCell
        cell.imageView?.image=UIImage(systemName: "mappin.and.ellipse")//這裡要改成抓ＵＲＬ
        cell.textLabel?.text = searchResultList[indexPath.row]
        return cell
    }
    internal func tableView(_ tableView:UITableView,trailingSwipeActionsConfigurationForRowAt indexPath:IndexPath)->UISwipeActionsConfiguration?{
        let data = UIContextualAction(style:.normal,title:"新增座標"){(action, view, completionHandler) in
            self.mapClickAnnLatVal = self.searchResultLatList[indexPath.row]
            self.mapClickAnnLngVal = self.searchResultLngList[indexPath.row]
            tableView.isHidden = true
            self.view.endEditing(true)
            self.cameraSet(lat: self.mapClickAnnLatVal, lng: self.mapClickAnnLngVal, zoom: 13, angle: 0)
            self.marketSet(lat: self.mapClickAnnLatVal, lng: self.mapClickAnnLngVal)
            completionHandler(true)
        }
        data.backgroundColor = .gray
        let config = UISwipeActionsConfiguration(actions:[data])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
}
extension ViewController: UISearchResultsUpdating { //搜尋
    func updateSearchResults(for searchController: UISearchController) {
        var searchKeyWord:String = ""
        if let searchText:String = searchController.searchBar.text,searchText.isEmpty == false {
            searchKeyWord = searchText
            var SearchData = textSearchDataGet(keyWord: searchKeyWord, lat: GpsLatVal, lng: GpsLngVal)
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
    }
}
extension ViewController: GMSMapViewDelegate{ //地圖按下觸發
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    }
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        mapClickAnnLatVal = coordinate.latitude
        mapClickAnnLngVal = coordinate.longitude
        marker.map = mapView
    }
}
extension ViewController: CLLocationManagerDelegate { // 目前位置與速度
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        GpsLatVal = userLocation.coordinate.latitude
        GpsLngVal = userLocation.coordinate.longitude
        var speed: CLLocationSpeedAccuracy = CLLocationSpeed()
        speed = mapLocationManager.location?.speed ?? 0 // 公尺／秒
        speed = 10
        GpsSpeedVal = speed
//        snapToRoadsDataGet(myLat: GpsLatVal, myLng: GpsLngVal)
        if viewState == State.navigation {
//            yawDecide()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
