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
    @IBOutlet weak var gpsSpeedLab: UILabel!
    @IBOutlet weak var navRemindCell: UITableViewCell!
    @IBOutlet weak var gpsRemindTittleLab: UILabel!
    @IBOutlet weak var gpsSwitchButton: UISwitch!
    @IBOutlet weak var navRemindImage: UIImageView!//導航－路標
    @IBOutlet weak var navRemindTIttleLab: UILabel!//導航－路名
    @IBOutlet weak var navRemindContentLab: UILabel!//導航－內容
    @IBOutlet weak var navRemindDistanceLab: UILabel!//導航－下一個提示剩餘距離
    @IBOutlet weak var navStartButton: UIButton!
    @IBOutlet weak var arrowImage: UIImageView!
    private var mapLocationManager = CLLocationManager() // GPS物件
    private var mapViewForUI: GMSMapView!//MapView畫面繼承
    private var GpsLatVal:Double = 0
    private var GpsLngVal:Double = 0
    private var GpsSpeedVal:Double = 0
    private var mapClickAnnLatVal:Double = 0
    private var mapClickAnnLngVal:Double = 0
    private let searchController = UISearchController()
    private var searchResultList:[String] = [] //searchBar返回資料（名稱）
    private var searchResultLatList:[Double] = []//searchBar返回資料（經度）
    private var searchResultLngList:[Double] = []//searchBar返回資料（緯度）
    private var path = GMSPath() //路徑規劃物件
    private var polyline = GMSPolyline() //路徑規劃物件
    private var polylinePoint:[CLLocationCoordinate2D] = []//目的地路徑（畫面）
    private var polylinePointDistanceList:[Double] = [] //polyline所有兩點距離陣列
    private var polylinePointAngleList:[Double] = [] //polyline所有兩點方向角陣列
    private var polylineSmallPointLatList:[Double] = [] //polyline所有座標切成個多點後取出所有經度組成陣列
    private var polylineSmallPointLngList:[Double] = []//polyline所有座標切成個多點後取出所有緯度組成陣列
    private var timerForNav = Timer() //慣性導航排程
    private var speedForAmount = 0.0
    private var navTimeCountForSmallPoint = 0 // 小點次數計算(讓畫面知道現在顯示到第幾個)
    private var navTimeCountForAngle = 0 // 小點次數計算（拿來跟polylinePointDistanceList[navPolylineCount]比，要歸零）
    private var navPolylineCount = 0 // 第幾段距離
    private var newMyLatValFromInertia:Double = 0//慣性位置Lat
    private var newMyLngValFromInertia:Double = 0//慣性位置Lng
    private var navManeuverList:[String] = []//導航提示左轉右轉List
    private var navStepsRemindList:[String] = []//導航提示完整內容List
    private var navStepsTittleList:[String] = []//導航提示路名List
    private var navStepsLatList:[Double] = []//導航提示座標Lat List
    private var navStepsLngList:[Double] = []//導航提示Lng List
    private var navStepCount = 0// 導航提示List專用陣列數
    private var navStepToInertiDistanceVal:Double = 0//到下一導航提示剩餘距離
    private var snapLat:Double = 0//道路Lat
    private var snapLng:Double = 0//道路Lng
    private var viewState = State.gps//畫面控制
    private var polylineWidth = WidthState.router//導航提示路徑紅線控制
    private var myLatList:[Double] = [] //我目前位置的
    private var myLngList:[Double] = []
    private var angleByPoint:Double = 0
    private var gpsSwitch :Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reSetButton.isHidden = true
        gpsRemindTittleLab.layer.masksToBounds = true
        gpsRemindTittleLab.layer.cornerRadius = 10
        gpsSpeedLab.layer.masksToBounds = true
        gpsSpeedLab.layer.cornerRadius = 10
        navRemindCell.isHidden = true
        arrowImage.image = UIImage(named: "arrow")
        searchBarTableViewSet()
        searchControllerSet()
        mapViewSet()
        mapLocationSet()
        switchBtnComponentSt(false)
    }
    override func viewDidAppear(_ animated: Bool) {
        gpsInertiaStart()
    }
    //畫面顯示控制
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
//        mapViewForUI.isMyLocationEnabled = true
        mapView.addSubview(mapViewForUI)
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
    func cameraSet(lat:Double,lng:Double,zoom:Double,angle:Double) {
        let camera = GMSCameraPosition(latitude: lat, longitude: lng, zoom: Float(zoom))
        self.mapViewForUI.camera = camera
        self.mapViewForUI.animate(toViewingAngle: angle)
    }
    func animateCamerSet(lat:Double,lng:Double,zoom:Double,angle:Double ,Bear:Double) {
        if GpsSpeedVal > 0.5 {
            CATransaction.begin()
            CATransaction.setValue(speedForAmount, forKey: kCATransactionAnimationDuration)
        }
        self.mapViewForUI.animate(toLocation: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        self.mapViewForUI.animate(toBearing:Bear)
        self.mapViewForUI.animate(toViewingAngle: angle)
        self.mapViewForUI.animate(toZoom: Float(zoom))
        if GpsSpeedVal > 0.5 {
            CATransaction.commit()
        }
    }
    func marketSet(lat:Double,lng:Double) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.map = self.mapViewForUI
    }
    func mapViewReSet() {
        gpsSwitchButton.isHidden = false
        self.timerForNav.invalidate()
        self.animateCamerSet(lat:GpsLatVal, lng:GpsLngVal, zoom:13, angle:0, Bear:0)
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
    func switchBtnComponentSt(_ state:Bool) {
        deleteButton.isEnabled = state
        routerButton.isEnabled = state
        navStartButton.isEnabled = state
        searchController.searchBar.isUserInteractionEnabled = state
        mapViewForUI.isMyLocationEnabled = state
        arrowImage.isHidden = state
        if state == false {
            searchController.searchBar.alpha = 0.2
        } else {
            searchController.searchBar.alpha = 1
        }
       
    }//switchBtn 畫面狀態控制
    func navBtnComponentSt(_ state:Bool) {
        switch viewState {
        case .gps,.navigation:
            searchController.searchBar.isHidden = state
            navRemindCell.isHidden = !state
            arrowImage.isHidden = !state
            deleteButton.isEnabled = !state
            reSetButton.isHidden = !state
            mapViewForUI.isMyLocationEnabled = !state
            gpsRemindTittleLab.isHidden = state
        case .router:
            gpsSwitchButton.isHidden = state
        }
    }//Btn 畫面狀態控制
    //元件控制
    @IBAction func reSetButton(_ sender: Any) {
        switch viewState {
        case State.navigation:
            viewState = State.gps
            polylineWidth = WidthState.router
            navigationCancel()
            mapViewReSet()
            navBtnComponentSt(false)// searchBar顯示、關閉導航提示、導航icon關閉、deleteButton功能開啟、reSetButton隱藏
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
                viewState = State.router
                navigationCancel()//因為GPS慣性跟Nav慣性是同一變數因此區要清空
                routerAndStepDataGet(myLat:GpsLatVal, myLng:GpsLngVal, annLat:mapClickAnnLatVal ,annLng:mapClickAnnLngVal)
                navBtnComponentSt(true)//gpsSwitchButton隱藏
                marketSet(lat: mapClickAnnLatVal, lng: mapClickAnnLngVal)
            } else {
                UIApplication.shared.keyWindow?.showToast(text:"請選擇目的地")
            }
        }
    }
    @IBAction func navStartButton(_ sender: Any) {
        switch viewState {
        case State.router:
            viewState = State.navigation
            polylineWidth = WidthState.navigation
            routerAndStepDataGet(myLat: GpsLatVal,myLng: GpsLngVal,annLat:mapClickAnnLatVal ,annLng:mapClickAnnLngVal)
            navBtnComponentSt(true)// searchBar隱藏、開啟導航提示、導航icon開啟、deleteButton功能關閉、reSetButton顯示、GPS道路名稱隱藏
        case State.navigation:
            UIApplication.shared.keyWindow?.showToast(text:"導航已經開始")
        case State.gps:
            UIApplication.shared.keyWindow?.showToast(text:"請先規劃路徑")
        }
    }
    @IBAction func deleteButton(_ sender: Any) {
        viewState = State.gps
        navigationCancel()
        mapViewReSet()
    }
    @IBAction func gpsSwitchButton(_ sender: Any) {
        gpsSwitch = !gpsSwitch
        if gpsSwitch == false {
            cameraSet(lat: GpsLatVal, lng: GpsLngVal, zoom: 13, angle: 0)
            self.timerForNav.invalidate()
            switchBtnComponentSt(true)
        } else {
            switchBtnComponentSt(false)
            gpsInertiaStart()
        }
    }
    //慣行導航func
    func navPolyLineProcess() {
        polylinePointAngleList = InertiaPoint().getpolylineListForAngle(polylinePoint: polylinePoint)
        polylinePointDistanceList = InertiaPoint().getPolylineListForDistance(polylinePoint: polylinePoint)
        let polylineSmallPoint = InertiaPoint().getPolylineListForSmallPoint(polylinePoint:polylinePoint)
        polylineSmallPointLatList = polylineSmallPoint.0
        polylineSmallPointLngList = polylineSmallPoint.1
        inertiaStart()
    }
    func inertiaStart() {
        if GpsSpeedVal > 0.5 {
            navigationInertiForStart()
            arrowImage.alpha = 1
        } else { //不動的時候
            arrowImage.alpha = 0.5
            self.timerForNav.invalidate()
            let cameraButton = GoogleMapVM().cameraPositionToBottom(polylinePointAngleList[navPolylineCount],polylineSmallPointLatList[navPolylineCount], polylineSmallPointLngList[navPolylineCount])
            animateCamerSet(lat:cameraButton.0, lng: cameraButton.1, zoom:19.5, angle:80, Bear: polylinePointAngleList[navPolylineCount])
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
            let cameraBottom = GoogleMapVM().cameraPositionToBottom(polylinePointAngleList[navPolylineCount],newMyLatValFromInertia, newMyLngValFromInertia)
            animateCamerSet(lat:cameraBottom.0, lng: cameraBottom.1, zoom:19.5, angle:80, Bear: polylinePointAngleList[navPolylineCount])
        }
    }
    func stepCalculate() {
        navStepToInertiDistanceVal = GoogleMapVM().getDistance(lat1: newMyLatValFromInertia, lng1: newMyLngValFromInertia, lat2: navStepsLatList[navStepCount], lng2: navStepsLngList[navStepCount])
        if navStepToInertiDistanceVal < 1 {
            navStepCount = navStepCount + 1
        }
        navRemindDistanceLab.text = "剩餘:\( String(format: "%.1f", navStepToInertiDistanceVal))公尺"
        if viewState == .navigation {
            getNavManeuverList()
            getNavStepsRemindList()
        }
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
            gpsRemindTittleLab.text = "目前位於:\(navStepsTittleList[navStepCount-1])"
        } else {
            navRemindTIttleLab.text = navStepsTittleList[navStepCount]
            gpsRemindTittleLab.text = "目前位於:\(navStepsTittleList[navStepCount])"
        }
    }
    func yawDecide() { //偏航
        let lat = positionBox().switchBox(GpsLatVal, GpsLngVal).0
        let lng = positionBox().switchBox(GpsLatVal, GpsLngVal).1
        let state = YawAlgorithm().YawAlgorithm1(newMyLatValFromInertia, newMyLngValFromInertia, lat, lng)//GPSLocation 可能要改回 Snap 看測試狀況
         if state == true {
             navigationCancel()
             switch viewState {
             case .gps:gpsInertiaStart()
             case.navigation:navInertiaStart()
             case .router:
                 return
             }
         }
    }
    //慣性GPS func
    func angleByPoint(lat:Double, lng:Double) -> (Double) {
        var angleByPoint:Double = 0
        myLatList.append(lat)
        myLngList.append(lng)
            if myLatList.count > 2 { //陣列長度超過2就清掉[0]避免越來越大，[0]表示上次[1]表示這次
                myLatList.remove(at: 0)
                myLngList.remove(at: 0)
                angleByPoint = GoogleMapVM().getPointsAngle(lat1: myLatList[0], lng1: myLngList[0], lat2: myLatList[1], lng2: myLngList[1])
            }
        return angleByPoint
    }
    func gpsInertiaStart() {
        angleByPoint = angleByPoint(lat: GpsLatVal, lng: GpsLngVal)
        let predictPoint =  GoogleMapVM().getNewPosition(lastAngle: angleByPoint, mylat: GpsLatVal, mylng: GpsLngVal, Distnace: 7000)
        let lat = positionBox().switchBox(GpsLatVal, GpsLngVal).0
        let lng = positionBox().switchBox(GpsLatVal, GpsLngVal).1
        routerAndStepDataGet(myLat:GpsLatVal, myLng:GpsLngVal, annLat:predictPoint.0 ,annLng:predictPoint.1)
        
    }
    func navInertiaStart() {
        routerAndStepDataGet(myLat:GpsLatVal, myLng:GpsLngVal, annLat:mapClickAnnLatVal ,annLng:mapClickAnnLngVal)
    }
    func stopGpsInertia() {
        self.timerForNav.invalidate()
        mapViewForUI.clear()
        arrowImage.isHidden = true
    }
    //Closure 呼叫API
    func textSearchDataGet(keyWord: String, lat: Double, lng: Double) {
        GoogleMapM<TextSearchData>().textSearchDataParser(keyWord: keyWord, lat: lat, lng: lng){
            [weak self] textSearchResult in
            self?.searchResultList = textSearchResult.searchResultList
            self?.searchResultLatList = textSearchResult.searchResultLatList
            self?.searchResultLngList = textSearchResult.searchResultLngList
            self?.tableView.reloadData()
        }
    }
    func snapToRoadsDataGet(myLat:Double,myLng:Double) {
        GoogleMapM<SnapToRoadsData>().snapToRoadsParser(myLat: myLat, myLng: myLng) { [weak self] snapToRoadsDataResult in
            self?.snapLat = snapToRoadsDataResult.latitude
            self?.snapLng = snapToRoadsDataResult.longitude
        }
    }
    func routerAndStepDataGet(myLat: Double,myLng: Double,annLat:Double ,annLng:Double){
        GoogleMapM<RouterAndStepData>().routeAndStepDataParser(myLat: myLat,myLng: myLng,annLat:annLat ,annLng:annLng) {
            [weak self]  routeAndStepDataResult in
            for i in 0...routeAndStepDataResult.points.count-1 {
                switch self?.viewState {
                case .gps:
                    self?.path = GMSPath(fromEncodedPath:routeAndStepDataResult.points[i])!
                    self?.polyline = GMSPolyline(path: self?.path)
                    self?.polylinePoint = decodePolyline(routeAndStepDataResult.polylinePoint)!
                    self?.navStepsLatList = routeAndStepDataResult.navStepsLatList
                    self?.navStepsLngList = routeAndStepDataResult.navStepsLngList
                    self?.navStepsTittleList = routeAndStepDataResult.navStepsTittleList
                case .router:
                    self?.path = GMSPath(fromEncodedPath:routeAndStepDataResult.points[i])!
                    self?.polyline = GMSPolyline(path: self?.path)
                    self?.polyline.strokeWidth = EnumClass().WidthState(value: self!.polylineWidth)
                    self?.polyline.strokeColor = .red
                    self?.polyline.map = self?.mapViewForUI
                    self?.polylinePoint = decodePolyline(routeAndStepDataResult.polylinePoint)!
                    let pathForCamera = GMSPath(fromEncodedPath: routeAndStepDataResult.polylinePoint)!
                    let bounds = GMSCoordinateBounds(path:pathForCamera)
                    let camera = GMSCameraUpdate.fit(bounds, withPadding: 140)
                    self?.mapViewForUI.animate(with: camera)
                case .navigation:
                    self?.path = GMSPath(fromEncodedPath:routeAndStepDataResult.points[i])!
                    self?.polyline = GMSPolyline(path: self?.path)
                    self?.polyline.strokeWidth = EnumClass().WidthState(value: self!.polylineWidth)
                    self?.polyline.strokeColor = .red
                    self?.polyline.map = self?.mapViewForUI
                    self?.polylinePoint = decodePolyline(routeAndStepDataResult.polylinePoint)!
                    self?.navManeuverList = routeAndStepDataResult.navManeuverList
                    self?.navStepsRemindList = routeAndStepDataResult.navStepsRemindList
                    self?.navStepsTittleList = routeAndStepDataResult.navStepsTittleList
                    self?.navStepsLatList = routeAndStepDataResult.navStepsLatList
                    self?.navStepsLngList = routeAndStepDataResult.navStepsLngList
                case .none:
                    break
                }
            }
            if self?.viewState != State.router{
                self?.navPolyLineProcess()
            }
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
            self.stopGpsInertia()
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
        if gpsSwitch == false {
            stopGpsInertia()
            let marker = GMSMarker(position: coordinate)
            mapClickAnnLatVal = coordinate.latitude
            mapClickAnnLngVal = coordinate.longitude
            marker.map = mapView
        }
    }
}
extension ViewController: CLLocationManagerDelegate { // 目前位置與速度
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation: CLLocation = locations[0]
        GpsLatVal = userLocation.coordinate.latitude
        GpsLngVal = userLocation.coordinate.longitude
        var speed: CLLocationSpeedAccuracy = CLLocationSpeed()
        speed = mapLocationManager.location?.speed ?? 0 // 公尺／秒
//        speed = 10
        GpsSpeedVal = speed
        gpsSpeedLab.text = "\(Int(GpsSpeedVal*3.6))km/hr"
        if GpsSpeedVal > 0.5{
            if viewState == State.navigation { //偏航判斷
    //          snapToRoadsDataGet(myLat: GpsLatVal, myLng: GpsLngVal)//snap
                inertiaStart()//速度更新時排成也更新、速度為零0.5以下時相機視角設定
                yawDecide()
            }
            if viewState == State.gps {
                if gpsSwitch == true {
                    inertiaStart()
                    yawDecide()
                }
            }
        }
       
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
