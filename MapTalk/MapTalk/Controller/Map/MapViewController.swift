//
//  MapViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/20.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher
import KeychainAccess
import NotificationBannerSwift

//swiftlint:disable all
class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let decoder = JSONDecoder()
    var iconImageArray: [String] = ["white-heart","road-sign","hot-air-balloon"]
    
    //20181028 增加 alert 告訴他我正在使用他的位置
    var flag: Bool = false
    var locationFlag: Bool = false
    var allAnnotations: [UserAnnotation] = []
    
    //20181020 偵測網路
    
    func noInternetAlert() {
        
        let alert = UIAlertController.showAlert(
            title: "無法連接網路！",
            message: "請確認是否連上網路？",
            defaultOption: ["確定"]) { (action) in
                
                print("按下確認鍵 請前往打開網路")
        }
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    var reachability = Reachability(hostName: "www.apple.com")
    
    func checkInternetFunction() -> Bool {
        if reachability?.currentReachabilityStatus().rawValue == 0 {
            print("no internet connected.")
            return false
        }else {
            print("internet connected successfully.")
            return true
        }
    }
    
    func downloadData() {
        if checkInternetFunction() == false {
            noInternetAlert()
        } else {
            print("成功連接網路")
        }
    }
    
    //20181012
    
    @IBOutlet weak var mapBackgroundView: UIView!
    @IBOutlet weak var userInfoDetailView: UserInfoDetailView!
    @IBOutlet weak var userInfoDetailViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var userInfoDetailViewBottomConstraints: NSLayoutConstraint!
    
    //End
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var refference: DatabaseReference!
    var userName: String!
    var locations: [Locations] = []
    var trackLocation: [String: Any] = [ : ]
    
    var userAnnotation: UserAnnotation?
    
    var selfLocation: Locations?
    
    var navigationUserName: String?
    
    //20181003
    var friendUserId: String?
    
    //20181012
    var userInfo = ["暱稱","性別","生日","感情狀態","居住地","體型","我想尋找","專長 興趣","喜歡的國家","自己最近的困擾","想嘗試的事情","自我介紹",]
    var userSelected =  ["男生","1993-06-06","單身","台北","肌肉結實","短暫浪漫","Frank Lin","吃飯，睡覺，看電影","台灣/美國/英國","變胖了想要多運動","高空跳傘，環遊世界","大家好，歡迎使用這個 App，希望大家都可以在這認識新朋友"]
    
    var friendNameForCell = "測試"
    var friendImageURLForCell = "測試"
    //20181009
    var centerDelivery: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.tabBarController?.tabBar.isTranslucent = true
        //偵測網路
        downloadData()
        
        mapView.delegate = self
        //        map.showsUserLocation = true
        
        refference = Database.database().reference()
        
        if let name = Auth.auth().currentUser?.displayName {
            userName = name
            
            locationManager.delegate = self
            //kCLLocationAccuracyKilometer
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            //locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            //locationManager.requestWhenInUseAuthorization()
            //20181028
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            showLocationAlert()
            downloadUserInfo()
            
        } else {
            userName = "User"
        }
        userName = Auth.auth().currentUser?.displayName
        
        dataBaseLocation()
        
        setButtonTemplateImage()
        setIconCorner()
        
        userDataMappingTrack()
        
        userInfoDetailView.userInfoDetailTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        userInfoDetailView.userInfoDetailTableView.dataSource = self
        userInfoDetailView.userInfoDetailTableView.delegate = self
       
        userInfoDetailView.userInfoDetailTableView.register(UINib(nibName: "NewUserDetailTableViewCell", bundle: nil),forCellReuseIdentifier: "UserDetail")
        userInfoDetailView.userInfoDetailTableView.register(UINib(nibName: "UserDataTableViewCell", bundle: nil),forCellReuseIdentifier: "UserData")
        userInfoDetailView.userInfoDetailTableView.register(UINib(nibName: "NewIntroduceTableViewCell", bundle: nil),forCellReuseIdentifier: "UserIntroduce")
        
        // 20181013 感覺沒作用
        addSwipe()
        mapBackgroundView.isHidden = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //匿名檢查
        let keychain = Keychain(service: "com.frank.MapTalk")
        
        if  keychain[FirebaseType.uuid.rawValue] == nil && keychain["anonymous"] == "anonymous" {
            //print("目前為匿名模式 請登出後使用 Facebook 登入")
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式,請使用 Facebook 登入")
            
        } else {
            // 首次使用 向使用者詢問定位自身位置權限
            if CLLocationManager.authorizationStatus()
                == .notDetermined {
                // 取得定位服務授權
                //locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
                // 開始定位自身位置
                locationManager.startUpdatingLocation()
                filterButton.isHidden = false
                location.isHidden = false
                //showLocationAlert()
                if locationFlag == false {
                    showLocationAlert()
                    locationFlag = true
                } else {
                    print("已經顯示過 showLocationAlert MapVC ")
                }
                
            }
                // 使用者已經拒絕定位自身位置權限
            else if CLLocationManager.authorizationStatus()
                == .denied {
                // 提示可至[設定]中開啟權限
                let alertController = UIAlertController(
                    title: "定位權限已關閉",
                    message:
                    "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟。 開啟後我們將存取您目前的地理位置資訊來顯示您的位置及媒合時的距離限制條件，且其他使用者將在地圖上看到您目前的位置。",
                    preferredStyle: .alert)
                let okAction = UIAlertAction(
                    title: "確認", style: .default, handler:nil)
                alertController.addAction(okAction)
                self.present(
                    alertController,
                    animated: true, completion: nil)
                filterButton.isHidden = true
                location.isHidden = true
            }
                // 使用者已經同意定位自身位置權限
            else if CLLocationManager.authorizationStatus()
                == .authorizedWhenInUse || CLLocationManager.authorizationStatus()
                == .authorizedAlways {
                // 開始定位自身位置
                locationManager.startUpdatingLocation()
                filterButton.isHidden = false
                location.isHidden = false
                //showLocationAlert()
                
                if locationFlag == false {
                    showLocationAlert()
                    locationFlag = true
                } else {
                    print("已經顯示過 showLocationAlert MapVC ")
                }
                
            }
        }
        
    }
    
    func showLocationAlert() {
        
        //    defaultOption: ["檢舉用戶", "封鎖用戶"])
        guard let myselfId = Auth.auth().currentUser?.uid else {
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式,請使用 Facebook 登入")
            return }
        let alertController =  UIAlertController.showAlert(
            title: "是否向其他人顯示自己位置？",
            message: "按下『 顯示 』 或是 『 隱藏 』來改變狀態，需要顯示才能正常使用地圖功能。",
            defaultOption: ["顯示","隱藏"]) { [weak self] (action) in
                
                switch action.title {
                    
                case "顯示":
                    
                    let userStatus = ["status": "appear"]
                    
                    let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                    
                    self?.refference.updateChildValues(childUpdatesStatus)
                    print("按下顯示3 MapViewController")
                    
                case "隱藏":
                    
                    let userStatus = ["status": "disappear"]
                    
                    let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                    
                    self?.refference.updateChildValues(childUpdatesStatus)
                    print("按下隱藏2 MapViewController")
                    
                default:
                    break
                    
                }
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MappingPage" {
            
            // swiftlint:disable force_cast
            let controller = segue.destination as! FilterViewController
            // swiftlint:enable force_cast
            controller.centerDeliveryFromMap = centerDelivery
            controller.delegate = self
            controller.flag = self.flag
            //flag = false
            
        }
            
        else {
            print("segue.identifier  錯誤")
        }
    }
    
    func downloadUserInfo() {
        
        print("*********")
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //此時的 userSelected 是 array
        self.refference.child("FilterData").child(userId).observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            //print("找到的資料是\(snapshot)")
            
            guard let value = snapshot.value as? NSDictionary else { return }
            print("*********1")
            
            guard let myselfGender = value["myselfGender"] as? Int else { return }

            //存下 gender
            let userDefaults = UserDefaults.standard
            
            userDefaults.set(myselfGender, forKey: "myselfGender")
            
            print("自己的性別是 \(myselfGender)")
        })
        
    }
    
    func dataBaseLocation() {
        refference.child("location").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            
            //            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
            //
            //            do {
            //                let userlocations = try self.decoder.decode(Locations.self, from: messageJSONData)
            //                print("****codable**** start")
            //                print(userlocations)
            //                print("****codable**** END")
            //            }
            //
            //            catch {
            //                print(error)
            //            }
            
            guard let location = value["location"] as? NSDictionary else { return }
            guard let latitude = location["lat"] as? Double else { return }
            guard let longitude = location["lon"] as? Double else { return }
            guard let userName = location["userName"] as? String else { return }
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            var genderInput = 0
            if let gender = value["gender"] as? NSDictionary {
                
                guard let gender = gender["gender"] as? Int else { return }
                
                genderInput = gender
            }
            //增加是否顯示欄位 20181025
            var statusInput = "appear"
            if let status = value["status"] as? NSDictionary {
                
                guard let status = status["status"] as? String else { return }
                
                statusInput = status
            }
            
            //確認是否被封鎖過 snapshot.key = ID
            //封鎖功能 20181022
            let userDefaults = UserDefaults.standard
            
            guard userDefaults.value(forKey: snapshot.key) == nil else {
                
                print("此用戶被封鎖了MapVC \(snapshot.key)")
                return
                
            }
            let userId = Auth.auth().currentUser?.uid
            
            if statusInput == "disappear" && snapshot.key != userId  {
                print("向其他用戶 隱藏 中1")
                return
            } else {
                print("向其他用戶顯示中1")
            }
            
            //print("***99 目前的 userID\(userId)")
            
            let userlocations = Locations(latitude: latitude, longitude: longitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput, gender: genderInput, status: statusInput)
            
            self.mapView.addAnnotation(userlocations.userAnnotation)
            //self.allAnnotations = self.mapView.annotations
            self.allAnnotations.append(userlocations.userAnnotation)
            
            self.locations.append(userlocations)
            
            //guard let userId = Auth.auth().currentUser?.uid else { return }
            if userlocations.id == userId {
                
                self.selfLocation = userlocations
                
                self.mapView.setRegion(
                    MKCoordinateRegion(
                        center: userlocations.userAnnotation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 1,
                            longitudeDelta: 1
                        )
                    ),
                    animated: false
                )
            }
            
            self.dataBaseTrack()
        }
    }
    
    func dataBaseTrack() {
        refference.child("location").observe(.childChanged) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let location = value["location"] as? NSDictionary else { return }
            guard let latitude = location["lat"] as? Double else { return }
            guard let longtitude = location["lon"] as? Double else { return }
            
            guard let userName = location["userName"] as? String else { return }
            
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            
            var genderInput = 0
            if let gender = value["gender"] as? NSDictionary {
                
                guard let gender = gender["gender"] as? Int else { return }
                
                genderInput = gender
            }
            
            //增加是否顯示欄位 20181025
            var statusInput = "appear"
            if let status = value["status"] as? NSDictionary {
                
                guard let status = status["status"] as? String else { return }
                
                statusInput = status
            }
            
            //封鎖功能 20181022
            let userDefaults = UserDefaults.standard
            
            guard userDefaults.value(forKey: snapshot.key) == nil else {
                
                print("此用戶被封鎖了MapVC \(snapshot.key)")
                return
                
            }
            
            let userId = Auth.auth().currentUser?.uid
            
            if statusInput == "disappear" && snapshot.key != userId  {
                //print("向其他用戶 隱藏 中2")
                self.removeUser(friendUserId: snapshot.key)
                return
            } else {
                //print("向其他用戶顯示中2")
            }
            
            let userLocations = Locations(latitude: latitude, longitude: longtitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput, gender: genderInput, status: statusInput)
            
            for (index, user) in self.locations.enumerated() where user.id == userLocations.id {
                
                self.locations[index].latitude = userLocations.latitude
                
                self.locations[index].longitude = userLocations.longitude
                
                self.locations[index].message = userLocations.message
                
                //OK 註解掉下面兩行 不會跑 annotationfor View  所以無法直接更改到 message content ，位置會跑 但是不會一閃一閃。 不註解 可以即時更新到 messgae 但是會更新
                //self.mapView(self.mapView, viewFor: self.locations[index].userAnnotation)
                self.mapView.removeAnnotation(self.locations[index].userAnnotation)
                self.mapView.addAnnotation(self.locations[index].userAnnotation)
                
                return
            }
        }
    }
    
    @IBAction func locationButtonClick(_ sender: UIButton) {
        
        if let location = selfLocation {
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: location.userAnnotation.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.4,
                        longitudeDelta: 0.4
                    )
                ),
                animated: true
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate {
            
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            //20181009 可以拿掉
            centerDelivery = center
            
            //20181009 準備使用 notification 本身的位置 及更新的位置 打去給 filter 那頁
            //NotificationCenter.default.post(name: .myselfLocation, object: center)
            
            saveSelfLocation(latitude: center.latitude, longitude: center.longitude)
            
            //增加一個 closure 傳值 把目前位置傳過去 filter 讓他 setvalue 的時候 也有值可以上傳
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            // 執行下面這行 why 會 nil?
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        if annotation is MKUserLocation {
    
            return nil
        }
        //新增 20181001
        let userAnnotation = annotation as? UserAnnotation
        
        if annotationView?.viewWithTag(7) != nil {
            
            //print("---已經加過 view")
            //OK
            //(annotationView?.subviews[1] as! UIImageView).isHidden = true
            
            //Label
            (annotationView?.subviews[2] as! UILabel).text = userAnnotation?.message
            //(annotationView?.subviews[1] as! UIImageView). = userAnnotation?.message
            
            if let userImage = userAnnotation?.userImage {
                (annotationView?.subviews[1] as! UIImageView).kf.setImage(with: URL(string: userImage))
            } else {
                (annotationView?.subviews[1] as! UIImageView).image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
            }
            
            if let gender = userAnnotation?.gender {
                if gender == 1 {
                    
                    (annotationView?.subviews[2] as! UILabel).backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.368627451, alpha: 1)
                    (annotationView?.subviews[3] as! UILabel).textColor = #colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.368627451, alpha: 1)
                    
                    
                } else {
                    (annotationView?.subviews[2] as! UILabel).backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                    (annotationView?.subviews[3] as! UILabel).textColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                    
                }
            } else {
                (annotationView?.subviews[2] as! UILabel).backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                (annotationView?.subviews[3] as! UILabel).textColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
            }
            
            return annotationView
        } else {
            print("尚未加過 view")
        }
        
        annotationView?.tag = 7
    
        annotationView?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        //判斷是否增加過 有的話修改 tag 的值
        
        //設定照片陰影
        
        let shadowView = UIView()

        let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 140, height: 30))
        
        shadowView.tag = 6
        shadowView.contentMode = .scaleAspectFit
        shadowView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        shadowView.layer.applySketchShadow(color: UIColor.lightGray, alpha: 1, x: 0, y: 0, blur: 15, spread: 15, corner: 25)
        
        // 設定頭像
        let imageView = UIImageView()
        imageView.tag = 6
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        if let userImage = userAnnotation?.userImage {
            imageView.kf.setImage(with: URL(string: userImage))
        } else {
            imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
        }
        
        //設定照片圓角
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.layer.borderWidth = 4
        
        annotationLabel.tag = 6
        annotationLabel.textAlignment = .center
        annotationLabel.font = UIFont(name: "Monaco", size: 12)
        annotationLabel.font = annotationLabel.font.withSize(14)
        
        annotationLabel.numberOfLines = 1
        annotationLabel.minimumScaleFactor = 0.7 //字體最小時 縮放 0.7 倍
        annotationLabel.adjustsFontSizeToFitWidth = true

        annotationLabel.textColor = UIColor.white
        
        let triangle = UILabel(frame: CGRect(x: -20, y: -10, width: 50, height: 10)) // 50, 10
        triangle.tag = 6
        triangle.text = "▾"
        triangle.font = UIFont.systemFont(ofSize: 24) //24

        triangle.textAlignment = .center
        
        if let message = userAnnotation?.message {
            annotationLabel.text = message
        } else {
            annotationLabel.text = "媽 我上地圖了 Ya"
        }
        
        ///annotationLabel.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        if let gender = userAnnotation?.gender {
            if gender == 1 {
                
                annotationLabel.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.368627451, alpha: 1)
                triangle.textColor = #colorLiteral(red: 0.9607843137, green: 0.2392156863, blue: 0.368627451, alpha: 1)
                
                
            } else {
                annotationLabel.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                triangle.textColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                
            }
        } else {
            annotationLabel.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
            triangle.textColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
        }
        
        //annotationLabel.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
        
        annotationLabel.layer.cornerRadius = 15
        annotationLabel.clipsToBounds = true
        
        annotationView?.addSubview(shadowView)
        annotationView?.addSubview(imageView)
        annotationView?.addSubview(annotationLabel)
        annotationView?.addSubview(triangle)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let userLocation = view.annotation as? UserAnnotation {
            self.userAnnotation = userLocation
        }
        
        if self.userAnnotation != nil {
            
            navigationUserName = userAnnotation?.name!
            friendUserId = userAnnotation?.id
            let firiendImageURL = userAnnotation?.userImage
            //friendImageURLForCell = firiendImageURL!
            
            //            self.showAlert(title: "傳訊息給\(navigationUserName!) 嗎～？", message: "認識一下吧！"
            
            //self.showMessageAlert(title: "傳訊息給\(navigationUserName!) 嗎～？", message: "認識一下吧！")
            print("選取的人的 userID 是 \(friendUserId)")
            
            //搜尋 firebase 20181019
            showUserDetail(friendId: friendUserId, friendName: navigationUserName, friendImageURL: firiendImageURL)
            
            //animateViewUp()
            
        } else {
            navigationUserName = "使用者"
        }
        
        //20181019 可以連點兩次
        mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    @objc func userInfoButtonClicked(sender: UIButton) {
        
        showMessageAlert(title: "傳訊息給\(navigationUserName!) 嗎～？", message: "認識一下吧！")
    }
    
    @objc func showMoreAlert()  {
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        guard let friendId =  friendUserId else { return }
        if myselfId == friendId {
            hideMyselfAlert()
        } else {
            showReportAlert()
        }
        
    }
    
    func showReportAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉及封鎖用戶", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "確定檢舉及封鎖此用戶？", message: "按下確認後，該用戶將立即從您的地圖中移除並封鎖，我們將在 24 小時內對該用戶再次進行審查。", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .destructive) { (action) in
                
                //把封鎖的人加到 userdefault 每次資料回來去問 用 uuid
                guard let blockID = self.friendUserId else { return }
                print("把使用者\(blockID) 加到 封鎖清單")
                let userDefaults = UserDefaults.standard
                self.removeUser(friendUserId: blockID)
                userDefaults.set("block", forKey: blockID)
                
                NotificationCenter.default.post(name: .blockUser, object: blockID)
                
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            reportController.addAction(cancelAction)
            reportController.addAction(okAction)
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        personAlertController.addAction(reportAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
    
    func hideMyselfAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "更改自己在地圖上的狀態嗎？", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "是否向其他人顯示自己位置？", message: "按下『 顯示 』 或是 『 隱藏 』來改變狀態", preferredStyle: .alert)
            
            guard let myselfId = Auth.auth().currentUser?.uid else { return }
            
            let hideAction = UIAlertAction(title: "隱藏", style: .destructive) { (action) in
                
                let userStatus = ["status": "disappear"]
                
                let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                
                self.refference.updateChildValues(childUpdatesStatus)
                
                print("按下隱藏2")
                
            }
            let appearAction = UIAlertAction(title: "顯示", style: .default) { (action) in
                
                let userStatus = ["status": "appear"]
                
                
                let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                
                self.refference.updateChildValues(childUpdatesStatus)
                
                print("按下顯示3")
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            
            reportController.addAction(appearAction)
            reportController.addAction(hideAction)
            reportController.addAction(cancelAction)
            
            self.present(reportController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        personAlertController.addAction(reportAction)
        personAlertController.addAction(cancelAction)
        self.present(personAlertController, animated: true, completion: nil)
    }
    
    func removeUser(friendUserId: String) {
        
        for (index, user) in locations.enumerated() where user.id == friendUserId {
        self.mapView.removeAnnotation(self.locations[index].userAnnotation)
            locations.remove(at: index)
            allAnnotations.remove(at: index)
            print("已從 array 刪除使用者\(friendUserId)")
            animateViewDown()
            return
        }
    }
    
    func showUserDetail(friendId: String?, friendName: String?, friendImageURL: String?) {
        
        guard let friendId = friendId else { return }
        guard let friendName = friendName else { return }
        guard let friendImageURL = friendImageURL else { return }
        
        //要顯示在 cell 上的 傳到全域去
        
        //friendNameForCell = friendName
        
        friendImageURLForCell = friendImageURL
        //reload 看看 delete 20181110
        //userInfoDetailView.userInfoDetailTableView.reloadData()
        
        downloadUserInfo(selectedUserId: friendId)
    }
    
    func downloadUserInfo(selectedUserId: String) {
        
        print("*********")
        //print(userSelected)
        //print("準備上傳的 userSelected 是\(userSelected)")
        
        
        //guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //此時的 userSelected 是 array
        self.refference.child("UserInfo").child(selectedUserId).observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            //print("找到的資料是\(snapshot)")
            
            //NSDictionary
            //var userSelected =  ["男","1993-06-06","單身","台北","臃腫","喝酒"]
            
            //這邊可以試著用 codable
            guard let value = snapshot.value as? NSArray else {
                BaseNotificationBanner.warningBanner(subtitle: "該用戶尚未填寫個人資料")
                return }
            print("*********1")
            
            print(value)
            
            guard let userGender = value[0] as? String else { return }
            guard let userBirthday = value[1] as? String else { return }
            guard let userRelationship = value[2] as? String  else { return }
            guard let userCity = value[3] as? String else { return }
            guard let userBodyType = value[4] as? String  else { return }
            guard let userSearchTarget = value[5] as? String else { return }
            
            guard let userNickName = value[6] as? String else { return }
            guard let userInterested = value[7] as? String else { return }
            guard let userCountry = value[8] as? String  else { return }
            guard let userBotheredThing = value[9] as? String else { return }
            guard let userWantToTry = value[10] as? String  else { return }
            guard let userIntroduce = value[11] as? String else { return }
            
            print("*********2接回來的資料為")
            
            print(userRelationship)
            print(userSearchTarget)
            //可以接到資料
            
            self.userSelected[0] = userGender
            self.userSelected[1] = userBirthday
            self.userSelected[2] = userRelationship
            self.userSelected[3] = userCity
            self.userSelected[4] = userBodyType
            self.userSelected[5] = userSearchTarget
            //上面 OK
            self.userSelected[6] = userNickName
            self.userSelected[7] = userInterested
            self.userSelected[8] = userCountry
            self.userSelected[9] = userBotheredThing
            self.userSelected[10] = userWantToTry
            self.userSelected[11] = userIntroduce
            
            //NEW 20181017
            let photo = self.friendImageURLForCell
            let bigPhotoURL = URL(string: photo + "?height=500")
            self.userInfoDetailView.userImage.kf.setImage(with: bigPhotoURL)
            
            let singleFinger = UITapGestureRecognizer(
                target:self,
                action:#selector(self.animateViewDown))

            self.userInfoDetailView.backgroundTapView.addGestureRecognizer(singleFinger)
            
            // cell.userImage.kf.setImage(with: bigPhotoURL)
            
            //加上 reload
            self.userInfoDetailView.userInfoDetailTableView.reloadData()
            
            //若是 tableView 不會有作用
            self.animateViewUp()
            self.addSwipe()
            
            //self.editTableView.reloadData()
            
        })
        
    }
    
    func addSwipe() {
        
        let singleFinger = UITapGestureRecognizer(
            target:self,
            action:#selector(animateViewDown))
        
        mapBackgroundView.addGestureRecognizer(singleFinger)
    }
    
    
    func animateViewUp() {
        //userInfoDetailViewHeightConstraints.constant = 400
        userInfoDetailViewBottomConstraints.constant = 10 //有 tabbar 高度 tabbar 有隱藏
        //self.tabBarController?.tabBar.layer.zPosition = -1
        
        
        //self.tabBarController?.tabBar.isHidden = true
        
        let animatedTabBar = self.tabBarController as! TabBarViewController
        animatedTabBar.animationTabBarHidden(true)
        //沒用
        //animatedTabBar.bottomLineColor = UIColor.red
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        mapBackgroundView.isHidden = false
        
    }
    
    @objc func animateViewDown() {
        //userInfoDetailViewHeightConstraints.constant = 0
        
        userInfoDetailViewBottomConstraints.constant = 800
        
        //20181016
        //        self.tabBarController?.tabBar.isHidden = false
        let animatedTabBar = self.tabBarController as! TabBarViewController
        animatedTabBar.animationTabBarHidden(false)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        mapBackgroundView.isHidden = true
    }
    
    //END
    
    func saveSelfLocation(latitude: Double, longitude: Double) {
        
        #warning ("TODO: 拿大照片過來")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        refference.child("location").child(userId).child("location").updateChildValues([
            "userId": userId,
            "lat": latitude,
            "lon": longitude,
            "userName": userName,
            "userImage": userImage])
        
        //加一個 update 更新 filter 下面的
        
        let myLocationUpdates = ["/FilterData/\(userId)/location": [
            "lat": latitude,
            "lon": longitude,
            ]]
        
        refference.updateChildValues(myLocationUpdates)
        
    }
    
    func showMessageAlert(title: String, message: String) {
        //讓 hello world 也可以讀 20181111
        
        //新增對方到 firebase 的好友列表
        guard let friendId =  self.friendUserId else { return }
        
        guard let friendName = self.navigationUserName else { return }
        
        guard let myselfName = Auth.auth().currentUser?.displayName else { return }

        //friendUserId = userAnnotation?.id
        //let firiendImageURL = userAnnotation?.userImage
        
        //要直接跳到 chatDetail 頁面
        //可以跳過去 但是返回上一頁會直接跳回 map 主頁
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            
            guard let myselfId = Auth.auth().currentUser?.uid else {
                BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式,請使用 Facebook 登入")
                return }
            
            //collectionView.deselectItem(at: indexPath, animated: true)
            
            // 換頁並且改變 detail頁的 friendUserId 的值
            guard let controller = UIStoryboard.chatStoryboard().instantiateViewController(
                withIdentifier: String(describing: ChatDetailViewController.self)
                ) as? ChatDetailViewController else { return }
            
            controller.friendUserId = self.friendUserId

            self.show(controller, sender: nil)
            print("跳頁成功")
            
            let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(friendId)": ["FriendUID": "\(friendId)","FriendName": "\(friendName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
            
            let friendChildUpdates = ["/UserData/\(friendId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)","FriendName": "\(myselfName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
            
            self.refference.updateChildValues(myChildUpdates)
            self.refference.updateChildValues(friendChildUpdates)
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func userDataMappingTrack() {
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        refference.child("UserData").child(myselfId).child("FriendsList").observe(.childChanged) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            
            print("＊＊＊＊ MappingValue")
            print(value)
            
            guard let accept = value["Accept"] as? String else { return }
            
            guard let friendName = value["FriendName"] as? String else { return }
            
            guard let friendUID = value["FriendUID"] as? String else { return }
            
            guard let friendEmail = value["Friend_Email"] as? String else { return }
            
            print("userDataMappingTrack 有值變更中")
            if accept == "收到邀請中" {
                self.showFriendInvitedAlert(title: "來自 \(friendName) 的邀請～", message: "別害羞 按下確認鍵交個新朋友吧～ ",senderId: friendUID,senderName: friendName)
            } else {
                print("沒有收到邀請")
            }
        }
    }
    
    func showFriendInvitedAlert(title: String, message: String,senderId: String,senderName: String) {
        
        //把全域變數拿掉
        
        //要直接跳到 chatDetail 頁面
        //可以跳過去 但是返回上一頁會直接跳回 map 主頁
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            
            //collectionView.deselectItem(at: indexPath, animated: true)
            
            // 換頁並且改變 detail頁的 friendUserId 的值
            guard let controller = UIStoryboard.chatStoryboard().instantiateViewController(
                withIdentifier: String(describing: ChatDetailViewController.self)
                ) as? ChatDetailViewController else { return }
            
            //controller.article = articles[indexPath.row]
            
            controller.friendUserId = senderId
            
            self.show(controller, sender: nil)
            print("跳頁成功")
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func setIconCorner() {
        
        location.clipsToBounds = true
        location.layer.cornerRadius = 25
        filterButton.clipsToBounds = true
        filterButton.layer.cornerRadius = 25
    }
    
    func setButtonTemplateImage() {
        
        let mappingIcon = #imageLiteral(resourceName: "heart-mapping").withRenderingMode(.alwaysTemplate)
        
        let locationIcon = #imageLiteral(resourceName: "geo_fence").withRenderingMode(.alwaysTemplate)
        
        filterButton.setImage(mappingIcon, for: .normal)
        location.setImage(locationIcon, for: .normal)
        setButtonColor(with: #colorLiteral(red: 0.137254902, green: 0.462745098, blue: 0.8980392157, alpha: 1)) //顏色已經挑選完成 是根據定位的按鈕的藍色 刷色
    }
    
    func setButtonColor(with color: UIColor) {
    
        filterButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // 按鈕的背景
        
        filterButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.1803921569, blue: 0.3333333333, alpha: 1) //刷色 不要 color 改紅色
        location.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        location.imageView?.tintColor = color
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
        if mapView.region.span.latitudeDelta > 3.5 {
            
            self.mapView.removeAnnotations(allAnnotations)
            BaseNotificationBanner.warningBanner(subtitle: "請將地圖放大🙏,才能看到其他使用者喔～")
            //print("超過 2.5")
        } else {
            
            //self.mapView.removeAnnotations(allAnnotations)
            self.mapView.addAnnotations(allAnnotations)
            //print("低於 2.5")
            
        }
        //print(mapView.region.span)
    }
}

extension NSNotification.Name {
    
    //static let myselfLocation = NSNotification.Name("Location")
    static let blockUser = NSNotification.Name("BLOCK_USER")
}

extension MapViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 11
        //return userInfo.count
        if section == 1 {
            return 3
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "UserData", for: indexPath)
                as? UserDataTableViewCell {
                
                cell.userName.text = userSelected[6]
                cell.userBirthday.text = "來到地球的日子：\(userSelected[1])"
                cell.userGender.text = userSelected[0]

                cell.chatButton.addTarget(self, action: #selector(userInfoButtonClicked(sender:)), for: .touchUpInside)
                
                //可以改用 userdefault
                cell.moreButton.addTarget(self, action: #selector(showMoreAlert), for: .touchUpInside)
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if let myselfId = Auth.auth().currentUser?.uid, let friendId = friendUserId {
                    if myselfId == friendId {
                        cell.chatButton.isHidden = true
                    } else {
                        cell.chatButton.isHidden = false
                    }
                }
                return cell
            }
        case 1:
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "UserDetail", for: indexPath)
                as? NewUserDetailTableViewCell {
                //cell.iconImage.image = UIImage.setIconTemplate(iconName: iconImageArray[indexPath.row])
                if indexPath.row == 0 {
                    cell.contentTitleLabel.text = userInfo[3]
                    cell.contentInfoLabel.text = userSelected[2]
                    cell.iconBackground.backgroundColor = #colorLiteral(red: 1, green: 0.4588235294, blue: 0.5176470588, alpha: 1)
                    //cell.iconImage.image = UIImage(named:iconImageArray[indexPath.row] )
                } else if indexPath.row == 1 {
                    cell.contentTitleLabel.text = userInfo[4]
                    cell.contentInfoLabel.text = userSelected[3]
                    cell.iconBackground.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.8235294118, blue: 1, alpha: 1)
                    //cell.iconImage.image = UIImage(named:iconImageArray[indexPath.row] )
                } else if indexPath.row == 2 {
                    cell.contentTitleLabel.text = userInfo[7]
                    cell.contentInfoLabel.text = userSelected[7]
                    cell.iconBackground.backgroundColor = #colorLiteral(red: 0.9647058824, green: 1, blue: 0.4588235294, alpha: 1)
                    //cell.iconImage.image = UIImage(named:iconImageArray[indexPath.row] )
                }
                
                cell.iconImage.image = UIImage(named:iconImageArray[indexPath.row] )
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            }
            
        case 2:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "UserIntroduce", for: indexPath)
                as? NewIntroduceTableViewCell {
                cell.introduceLabel.text = userSelected[11]
                cell.wantToTryLabel.text = userSelected[10]
                cell.introduceTitleBackground.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                return cell
            }
            
        default:
            return  UITableViewCell()
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return 100
    }
    
}

extension MapViewController: UITableViewDelegate {}

extension MapViewController: sendAlertstatus {
    
    func checkBool(flag: Bool) {
        self.flag = flag
    }
}
// swiftlint:disable file_length
//swiftlint:disable all
