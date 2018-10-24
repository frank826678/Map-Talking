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

//swiftlint:disable all
class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
     var iconImageArray: [String] = ["white-heart","road-sign","hot-air-balloon"]
    //20181020 偵測網路
    
    func noInternetAlert() {
        let alert = UIAlertController(title: "無法連接網路", message: "請確認是否連上網路？", preferredStyle: UIAlertController.Style.alert)
        
        let action = UIAlertAction(title: "確認", style: .default) { (_) in
            print("按下確認鍵 請前往打開網路")
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(cancel)
        
        alert.addAction(action)
        
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
            
            //            internetLabel1.isHidden = false
            //            internetLabel2.isHidden = false
            //hintLabel.text = "請打開行動網路或 WI-FI"
            //hintLabel.isHidden = false
            noInternetAlert()
            
        }else {
            
            print("成功連接網路")
            //hintLabel.isHidden = true
            //            internetLabel1.isHidden = true
            //            internetLabel2.isHidden = true
            
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
        } else {
            userName = "User"
        }
        userName = Auth.auth().currentUser?.displayName
        
        locationManager.delegate = self
        //kCLLocationAccuracyKilometer
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        //locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        dataBaseLocation()
        
        setButtonTemplateImage()
        setIconCorner()
        
        //20181003
        //        saveSelfLocation(latitude: (selfLocation?.latitude)!, longitude: (selfLocation?.longitude)!)
        
        //20181008
        userDataMappingTrack()
        
        //20181012
        //userInfoDetailView.userName.text = "大頭大頭"
        //profileTableView.delegate = self
        //profileTableView.dataSource = self
        
        //取消 tableView 虛線
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MappingPage" {
            
            // swiftlint:disable force_cast
            let controller = segue.destination as! FilterViewController
            // swiftlint:enable force_cast
            controller.centerDeliveryFromMap = centerDelivery
            //            let tag = sender as! Int
            //            nowIndex = tag //把目前選到的ＥＤＩＴ 放到全域去準備使用
            //            let controller = segue.destination as! TextInputViewController
            //
            //            //print("壞", ObjectIdentifier(controller))
            //
            //            //controller.textInput.text = contentArray[tag]
            //            controller.textFromHomePage = contentArray[tag]
            //
            //            controller.completionHandler = { dataFromVC2 in
            //
            //                self.saveData(passData: dataFromVC2)
            
        }
            
        else {
            
            //            let controller = segue.destination as! TextInputViewController
            //            //controller.addObserver(self, forKeyPath: "infoInput", options: .new, context: nil)
            //            controller.completionHandler = { dataFromVC2 in
            //
            //                self.saveData(passData: dataFromVC2)
            
        }
    }
    
    
    func dataBaseLocation() {
        refference.child("location").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
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
            //確認是否被封鎖過 snapshot.key = ID
            //封鎖功能 20181022
            let userDefaults = UserDefaults.standard
            
            guard userDefaults.value(forKey: snapshot.key) == nil else {
                
                print("此用戶被封鎖了MapVC \(snapshot.key)")
                return
                
            }

            let userlocations = Locations(latitude: latitude, longitude: longitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput, gender: genderInput)
            
            self.mapView.addAnnotation(userlocations.userAnnotation)
            
            self.locations.append(userlocations)
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            if userlocations.id == userId {
                
                self.selfLocation = userlocations
                
                self.mapView.setRegion(
                    MKCoordinateRegion(
                        center: userlocations.userAnnotation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.1,
                            longitudeDelta: 0.1
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
            
            //確認是否被封鎖過 snapshot.key = ID
            //封鎖功能 20181022
            let userDefaults = UserDefaults.standard
            
            guard userDefaults.value(forKey: snapshot.key) == nil else {
                
                print("此用戶被封鎖了MapVC \(snapshot.key)")
                return
                
            }
            
            let userLocations = Locations(latitude: latitude, longitude: longtitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput, gender: genderInput)
            
            for (index, user) in self.locations.enumerated() where user.id == userLocations.id {
                
                self.locations[index].latitude = userLocations.latitude
                
                self.locations[index].longitude = userLocations.longitude
                
                self.locations[index].message = userLocations.message
                
                self.mapView.removeAnnotation(self.locations[index].userAnnotation)
                self.mapView.addAnnotation(self.locations[index].userAnnotation)
                
//                for index in 0..<self.locations.count {
//                    self.mapView.removeAnnotation(self.locations[index].userAnnotation)
//                    self.mapView.addAnnotation(self.locations[index].userAnnotation)
//                }
                
//                for index in 0..<self.locations.count {
//                    self.mapView.removeAnnotation(self.locations[index].userAnnotation)
//                    self.mapView.addAnnotation(self.locations[index].userAnnotation)
//                }

                
                return
            }
            
            self.mapView.addAnnotation(userLocations.userAnnotation)
            
            
            self.locations.append(userLocations)
        }
    }
    
    @IBAction func locationButtonClick(_ sender: UIButton) {
        
        if let location = selfLocation {
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: location.userAnnotation.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.1,
                        longitudeDelta: 0.1
                    )
                ),
                animated: false
            )
        }
    }
    
    //    func fetchCenter(center: CLLocationCoordinate2D) {
    //
    //
    //    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate {
            
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            //20181009 可以拿掉
            centerDelivery = center
            
            //20181009 準備使用 notification 本身的位置 及更新的位置 打去給 filter 那頁
            NotificationCenter.default.post(name: .myselfLocation, object: center)
            
            
            //fetchCenter(center: center)
            
            //            let region = MKCoordinateRegion(center: center,
            //                                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
            
            saveSelfLocation(latitude: center.latitude, longitude: center.longitude)
            
            //增加一個 closure 傳值 把目前位置傳過去 filter 讓他 setvalue 的時候 也有值可以上傳
        }
        
    }
    
    //新寫法 不會有白色的點擋住 但是點擊後不會觸發任何事件 不能做任何動作
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            // 執行下面這行 why 會 nil?
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        // if is 在幹嘛？
        if annotation is MKUserLocation {
            // 直接跳開
            return nil
        }
        //新增 20181001
        let userAnnotation = annotation as? UserAnnotation
        
        //新增 20181002 重要 點擊後可以執行 didselect
        annotationView?.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        //annotationView?.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        
        //設定照片陰影
        
        let shadowView = UIView()
        
        shadowView.contentMode = .scaleAspectFit
        //let blurEffect = UIBlurEffect(style: .light)
        //let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        shadowView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        //shadowView.layer.applySketchShadow(color: UIColor.red, alpha: 1, x: 0, y: 0, blur: 10, spread: 40, corner: 30,center: (annotationView?.center)!)
        //角度修正
        //shadowView.layer.applySketchShadow(color: UIColor.red, alpha: 1, x: -5, y: -5, blur: 10, spread: 40, corner: 30)
        //B7B7B7 改透明度 0.6
        shadowView.layer.applySketchShadow(color: #colorLiteral(red: 0.7176470588, green: 0.7176470588, blue: 0.7176470588, alpha: 0.5980040668), alpha: 0.3, x: 0, y: 0, blur: 10, spread: 10, corner: 25)
        
        //userImageShadowView.layer.applySketchShadow(color: #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1), alpha: 0.5, x: 0, y: 0, blur: 15, spread: 15,corner: 60)
        
        
        //shadowView.clipsToBounds = true
        //shadowView.layer.cornerRadius = 27.5
        //shadowView.layer.borderColor = #colorLiteral(red: 0.7176470588, green: 0.7176470588, blue: 0.7176470588, alpha: 0.5)
        //shadowView.layer.borderWidth = 4
        
        annotationView?.addSubview(shadowView)

        
        // 設定頭像
        let imageView = UIImageView()
        
        //imageView.contentMode = .scaleAspectFill
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
        
        annotationView?.addSubview(imageView)
        
        //20181020 沒用 要加 view
        //imageView.layer.applySketchShadow(color: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1), alpha: 0.5, x: 0, y: 0, blur: 15, spread: 20,corner: 25)
        
        
        //END

        //triangle.textColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        //annotationView?.image = imageView.image
        
        //annotationView?.annotation?.subtitle = "Test"
        
        let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 140, height: 30))
        annotationLabel.numberOfLines = 1
        annotationLabel.textAlignment = .center
        annotationLabel.font = UIFont(name: "Monaco", size: 12)
        annotationLabel.font = annotationLabel.font.withSize(14)
        annotationLabel.textColor = UIColor.white
        
        //        增加三角形圖案
        //        OK
        //
        let triangle = UILabel(frame: CGRect(x: -20, y: -10, width: 50, height: 10)) // 50, 10
        triangle.text = "▾"
        triangle.font = UIFont.systemFont(ofSize: 24) //24
        //triangle.textColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
        
        triangle.textAlignment = .center

        
        //annotationLabel.font = UIFont(name: "Rockwell", size: 12)
        
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
        
        annotationView?.addSubview(annotationLabel)
        annotationView?.addSubview(triangle)
        

        //OK
        /*
        let annotationName = UILabel(frame: CGRect(x: -20, y: 65, width: 95, height: 25))
        annotationName.numberOfLines = 3
        annotationName.textAlignment = .center
        annotationName.font = UIFont(name: "Rockwell", size: 12)
        
        if let name = userAnnotation?.name {
            annotationName.text = name
            annotationName.isHidden = false
        } else {
            annotationName.isHidden = true
        }
        
        annotationName.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.631372549, blue: 0.7921568627, alpha: 1)
        annotationName.textColor = .white
        
        annotationName.layer.cornerRadius = 15
        annotationName.clipsToBounds = true
        annotationView?.addSubview(annotationName)
        */
        //END 20181017
        
        // 下面這行改了 白點消失 變成純愛心
        //annotationView?.image = #imageLiteral(resourceName: "btn_like_normal")
        
        //有這行也不 call didselect
        //userAnnotation?.title = userAnnotation?.name
        
        //https://stackoverflow.com/questions/26713582/didselectannotationview-not-called
        
        //        annotationView?.canShowCallout = true
        
        //annotationView?.annotation?.title = userAnnotation?.name
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //新增下面這行 20181001
        //           self.showAlert(title: "新增\(navigationUserName!) 為好友？", message: "認識一下吧！")
        
        //第一次進來 userAnnotation 點擊進來是 nil
        
        //print("QQQQQQQQ")
        
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
        //20181012
        //addTap(taskCoordinate: coordinate)
        
        //        animateViewUp()
        //        addSwipe()
        
    }
    
    //20181012
    
    
    @objc func userInfoButtonClicked(sender: UIButton) {
        
        showMessageAlert(title: "傳訊息給\(navigationUserName!) 嗎～？", message: "認識一下吧！")
        
    }
    
    @objc func showReportAlert() {
        let personAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "檢舉用戶", style: .destructive) { (void) in
            
            let reportController = UIAlertController(title: "確定檢舉？", message: "我們確認後會在 24 小時內進行處理", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "確定", style: .destructive) { (action) in
            
                //把封鎖的人加到 userdefault 每次資料回來去問 用 uuid
                guard let blockID = self.friendUserId else { return }
                print("把使用者\(blockID) 加到 封鎖清單")
                let userDefaults = UserDefaults.standard
                
                userDefaults.set("block", forKey: blockID)
                
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

    
    func showUserDetail(friendId: String?, friendName: String?, friendImageURL: String?) {
        
        guard let friendId = friendId else { return }
        guard let friendName = friendName else { return }
        guard let friendImageURL = friendImageURL else { return }
        
        //要顯示在 cell 上的 傳到全域去
        
        //friendNameForCell = friendName
        
        friendImageURLForCell = friendImageURL
        //reload 看看
        userInfoDetailView.userInfoDetailTableView.reloadData()
        
        //let bigPhotoURL = URL(string: friendImageURL + "?height=500")
        
        
        //friendImageURLForCell = bigPhotoURL
        
//20181019
//        let mapTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
//        mapView.addGestureRecognizer(mapTap)
        
        
        //let bigPhotoURL = URL(string: friendImageURL + "?height=500")
        
        //friendImageURLForCell = bigPhotoURL
       
        //self.userInfoDetailView.reloadInputViews()
        
        //self.userInfoDetailView.userName.text = friendName
         //let bigPhotoURL = URL(string: friendImageURL + "?height=500")
        //self.userInfoDetailView.userImage.kf.setImage(with: bigPhotoURL)
       
        
        //self.userInfoDetailView.userInfoDetailTableView.dataSource = self
        //self.userInfoDetailView.userInfoDetailTableView.delegate = self
        
        downloadUserInfo(selectedUserId: friendId)
        
        //        guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        
        //userImage.kf.setImage(with: URL(string: photoSmallURL))
        //userImage.kf.setImage(with: bigPhotoURL)
        //self.addSwipe()
    }
    
    func downloadUserInfo(selectedUserId: String) {
        
        print("*********")
        //print(userSelected)
        //print("準備上傳的 userSelected 是\(userSelected)")
        
        
        //guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //此時的 userSelected 是 array
        self.refference.child("UserInfo").child(selectedUserId).observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            print("找到的資料是\(snapshot)")
            
            //NSDictionary
            //var userSelected =  ["男","1993-06-06","單身","台北","臃腫","喝酒"]
            
            //這邊可以試著用 codable
            guard let value = snapshot.value as? NSArray else { return }
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
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        userInfoDetailView.addGestureRecognizer(swipe)
        
        let singleFinger = UITapGestureRecognizer(
            target:self,
            action:#selector(animateViewDown))
        //singleFinger.numberOfTapsRequired = 1
        
        mapBackgroundView.addGestureRecognizer(singleFinger)
        
        //20181013
        userInfoDetailView.userInfoDetailTableView.addGestureRecognizer(swipe)
        
//        let viewBackgroundTap = UITapGestureRecognizer(target: self, action: #selector(animateViewDown))
//        mapBackgroundView.addGestureRecognizer(viewBackgroundTap)
       
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
    
    
    //    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
    //        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
    //        test.title = "Emojis"
    //        test.subtitle = nil
    //        return test
    //    }
    //
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
    //        annotationView.clusteringIdentifier = "identifier"
    //        return annotationView
    //    }
    
    
    
    func saveSelfLocation(latitude: Double, longitude: Double) {
        
        #warning ("TODO: 拿大照片過來")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        refference.child("location").child(userId).child("location").setValue([
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
        
        
        //        let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(friendId)": ["FriendUID": "\(friendId)","FriendName": "\(friendName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
        //
        //        let friendChildUpdates = ["/UserData/\(friendId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)","FriendName": "\(myselfName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
        //
        //
        //        //            self.refference.child.updateChildValues(["/UserData/\(myselfId)/FriendsList/\(friendId)": ["accept": "發送邀請中","friend_email": "emailTest"]])
        //        //
        //        self.refference.updateChildValues(myChildUpdates)
        
        //        self.ref.child("FilterData").child(userId).setValue([
        //            "senderId": userId,
        //            "senderName": userName,
        //            "senderPhoto": userImage,
        //            "time": createdTime,
        //            "gender": filterAllData.gender,
        //            "age": filterAllData.age,
        //            "location": filterAllData.location,
        //            "dating": filterAllData.dating,
        //            "datingTime": filterAllData.time
        //        ]) { (error, _) in
        //
        //            if let error = error {
        //
        //                print("Data could not be saved: \(error).")
        //
        //            } else {
        //
        //                print("Data saved successfully!")
        //
        //            }
        //        }
        
    }
    
    @IBAction func test(_ sender: Any) {
        if self.userAnnotation != nil {
            navigationUserName = userAnnotation?.name!
            self.showAlert(title: "即將導航到\(navigationUserName!)", message: "系好安全帶")
        } else {
            navigationUserName = "使用者"
        }
        
    }
    
    func giveDirections(coordinate: CLLocationCoordinate2D, userName: String) {
        let requestCllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCllocation) { (placemarks, _) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = userName
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        
        //跳到導航用
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            self.giveDirections(coordinate: (self.userAnnotation?.coordinate)!, userName: self.navigationUserName!)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showMessageAlert(title: String, message: String) {
        
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
            controller.friendUserId = self.friendUserId
            self.show(controller, sender: nil)
            print("跳頁成功")
            
            //新增對方到 firebase 的好友列表
            guard let friendId =  self.friendUserId else { return }
            guard let myselfId = Auth.auth().currentUser?.uid else { return }
            guard let friendName = self.navigationUserName else { return }
            
            guard let myselfName = Auth.auth().currentUser?.displayName else { return }
            
            
            //refference.child("UserFriendList").child(myselfId).child(friendId).setValue([])
            let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(friendId)": ["FriendUID": "\(friendId)","FriendName": "\(friendName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
            
            let friendChildUpdates = ["/UserData/\(friendId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)","FriendName": "\(myselfName)","Accept": "已是好友中","Friend_Email": "emailTest"]]
            
            
            //            self.refference.child.updateChildValues(["/UserData/\(myselfId)/FriendsList/\(friendId)": ["accept": "發送邀請中","friend_email": "emailTest"]])
            //
            self.refference.updateChildValues(myChildUpdates)
            self.refference.updateChildValues(friendChildUpdates)
            
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        //增加 alert的約束條件 調整高度
        //        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view,
        //                                                           attribute: NSLayoutConstraint.Attribute.height,
        //                                                           relatedBy: NSLayoutConstraint.Relation.equal,
        //                                                           toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
        //                                                           multiplier: 1, constant: self.view.frame.height * 0.80)
        
        //        let topConstraint : NSLayoutConstraint =  NSLayoutConstraint(item: alertController.view,
        //                                      attribute: NSLayoutConstraint.Attribute.top,
        //                                      relatedBy: NSLayoutConstraint.Relation.equal,
        //                                      toItem: self.view, attribute: NSLayoutConstraint.Attribute.top,
        //                                      multiplier: 1, constant: 140)
        
        //        let topConstraint : NSLayoutConstraint =  NSLayoutConstraint(item: alertController.view,
        //                                                                    attribute: .top,
        //                                                                    relatedBy: .equal,
        //                                                                    toItem: self.view, attribute: .top,
        //                                                                    multiplier: 1, constant: 140)
        
        //         let topConstraint : NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: sueperView, attribute: .top, multiplier: 1.0, constant: 50)
        
        //alertController.view.frame.origin.y += 200
        //  alertController.view.frame.origin.y = alertController.view.frame.origin.y + 50
        //                alertController.view.alpha = 0
        //                alertController.view.frame.origin.y += 200
        //            UIView.animate(withDuration: 0.4, animations: { () -> Void in
        //                    alertController.view.alpha = 1.0;
        //                    alertController.view.frame.origin.y -= 50
        //                })
        
        
        //alertController.view.addConstraint(topConstraint)
        //增加 alert的約束條件 調整高度 END
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    //    func animateView() {
    //        alertView.alpha = 0;
    //        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
    //        UIView.animate(withDuration: 0.4, animations: { () -> Void in
    //            self.alertView.alpha = 1.0;
    //            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
    //        })
    //    }
    
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
            
            //做一個 alert
            
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
            
            
            //            //新增對方到 firebase 的好友列表
            //
            //            //guard let friendId =  self.friendUserId else { return }
            //
            //            guard let myselfId = Auth.auth().currentUser?.uid else { return }
            //            //guard let friendName = self.friendUserName else { return }
            //
            //            guard let myselfName = Auth.auth().currentUser?.displayName else { return }
            //
            //
            //            //refference.child("UserFriendList").child(myselfId).child(friendId).setValue([])
            //
            //            // 我媒合到 friend 在我自己的節點下 存朋友的 ID 並且 朋友的狀態為 發出邀請中
            //            // 被我媒合的到的朋友 在朋友的節點下 存下自己的 ID 並且 朋友的狀態為 收到邀請中
            //            // 朋友應該監控自己下方的節點 邀請中 如果有 要跳出 alert 提醒有人要跟你當朋友
            //
            //            let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(senderId)": ["FriendUID": "\(senderId)",
            //"FriendName": "\(senderName)","Accept": "發出邀請中","Friend_Email": "emailTest"]]
            //
            //            let friendChildUpdates = ["/UserData/\(senderId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)",
            //"FriendName": "\(myselfName)","Accept": "收到邀請中","Friend_Email": "emailTest"]]
            //
            //
            //            //            self.refference.child.updateChildValues(["/UserData/\(myselfId)/FriendsList/\(friendId)": ["accept": "發送邀請中","friend_email": "emailTest"]])
            //            //
            //            self.refference.updateChildValues(myChildUpdates)
            //            self.refference.updateChildValues(friendChildUpdates)
            
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func changeMessage(_ sender: UIButton) {
        
        let editAlert = UIAlertController(title: "Message:", message: nil, preferredStyle: .alert)
        
        editAlert.addTextField()
        
        let submitAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
            
            if let alertTextField = editAlert.textFields?.first?.text {
                
                print("alertTextField: \(alertTextField)")
                
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                let userStatus = ["text": alertTextField]
                
                let childUpdates = ["/location/\(userId)/message": userStatus]
                
                self.refference.updateChildValues(childUpdates)
                
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        editAlert.addAction(submitAction)
        editAlert.addAction(cancel)
        
        self.present(editAlert, animated: true)
    }
    
    func setIconCorner() {
        
        location.clipsToBounds = true
        location.layer.cornerRadius = 25
        filterButton.clipsToBounds = true
        filterButton.layer.cornerRadius = 25
        
    }
    
    func setButtonTemplateImage() {
//        var templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
//        filterButton.setImage(templateImage, for: .normal)
//
//        templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
//        filterButton.setImage(templateImage, for: .selected)
        //20191021 新 icon
        
        var mappingIcon = #imageLiteral(resourceName: "heart-mapping").withRenderingMode(.alwaysTemplate)
        
        var locationIcon = #imageLiteral(resourceName: "geo_fence").withRenderingMode(.alwaysTemplate)
        
        filterButton.setImage(mappingIcon, for: .normal)
        location.setImage(locationIcon, for: .normal)
        setButtonColor(with: #colorLiteral(red: 0.137254902, green: 0.462745098, blue: 0.8980392157, alpha: 1)) //顏色已經挑選完成 是根據定位的按鈕的藍色 刷色
        
    }
    
    func setButtonColor(with color: UIColor) {
        //filterButton.imageView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //按鈕的圖案的背景 顏色已經挑選完成 是根據定位的按鈕的白色
        
        filterButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // 按鈕的背景
        
        filterButton.imageView?.tintColor = #colorLiteral(red: 1, green: 0.1803921569, blue: 0.3333333333, alpha: 1) //刷色 不要 color 改紅色
        location.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        location.imageView?.tintColor = color
        //        playButton.imageView?.tintColor = color
        //
        //        rewindButton.imageView?.tintColor = color
        //
        //        forwardButton.imageView?.tintColor = color
        //
        //        muteButton.imageView?.tintColor = color
        //
        //        fullScreenButton.imageView?.tintColor = color
    }
    
}

//extension MapViewController: ClusterDelegate {
//
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> ClusterAnnotation {
//        let annotation = ClusterAnnotation(memberAnnotations: memberAnnotations)
//        annotation.title = "Emojis"
//        return annotation
//    }
//
//}

//extension MapViewController: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
//        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//        test.title = "Emojis"
//        test.subtitle = nil
//        return test
//    }
//}

extension NSNotification.Name {
    
    static let myselfLocation = NSNotification.Name("Location")
    
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
                
//                friendNameForCell = friendName
//                friendImageURLForCell = friendImageURL
                
                //照片需要重改
                //let photo = friendImageURLForCell
                //let bigPhotoURL = URL(string: photo + "?height=500")
                
               // cell.userImage.kf.setImage(with: bigPhotoURL)
                
                cell.userName.text = userSelected[6]
                cell.userBirthday.text = "來到地球的日子：\(userSelected[1])"
                cell.userGender.text = userSelected[0]
                cell.chatButton.addTarget(self, action: #selector(userInfoButtonClicked(sender:)), for: .touchUpInside)
                
                //可以改用 userdefault
                guard let myselfId = Auth.auth().currentUser?.uid else { return UITableViewCell() }
                if myselfId == friendUserId {
                    cell.moreButton.isHidden = true
                } else {
                    cell.moreButton.isHidden = false
                }
                cell.moreButton.addTarget(self, action: #selector(self.showReportAlert), for: .touchUpInside)

                
                //self.userInfoDetailView.userImage.kf.setImage(with: bigPhotoURL)
                
              
                
                //cell.userImage
                //cell.userDetailTitle.text = userInfo[indexPath.row]
                //cell.userDetailContent.text = userSelected[indexPath.row]
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
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
                
            //cell.userDetailTitle.text = "生日"
            //            var userInfo = ["暱稱","性別","生日","感情狀態","居住地","體型5","我想尋找","專長 興趣","喜歡的國家","自己最近的困擾","想嘗試的事情","自我介紹",]
            //            var userSelected =  ["男","1993-06-06","單身","台北","肌肉結實4","短暫浪漫","Frank Lin","吃飯，睡覺，看電影7","台灣/美國/英國","變胖了想要多運動","高空跳傘，環遊世界","大家好，歡迎使用這個 App，希望大家都可以在這認識新朋友"]
            
//            cell.userDetailTitle.text = userInfo[indexPath.row]
//            cell.userDetailContent.text = userSelected[indexPath.row]
                
                //OK 20181017
                
//                if indexPath.row == 0 {
//                    cell.userDetailTitle.text = userInfo[3]
//                    cell.userDetailContent.text = userSelected[2]
//                } else if indexPath.row == 1 {
//                    cell.userDetailTitle.text = userInfo[4]
//                    cell.userDetailContent.text = userSelected[3]
//                } else if indexPath.row == 2 {
//                    cell.userDetailTitle.text = userInfo[5]
//                    cell.userDetailContent.text = userSelected[4]
//                } else if indexPath.row == 3 {
//                    cell.userDetailTitle.text = userInfo[6]
//                    cell.userDetailContent.text = userSelected[5]
//                } else if indexPath.row == 4 {
//                    cell.userDetailTitle.text = userInfo[7]
//                    cell.userDetailContent.text = userSelected[7]
//                } else {
//                    cell.userDetailTitle.text = userInfo[indexPath.row + 3]
//                    cell.userDetailContent.text = userSelected[indexPath.row + 3]
//                }
                
                //END 20181017
                
            //cell.iconImage.backgroundColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) // FB message borderColor
            
            //原本
            //cell.iconImage.image = UIImage(named: iconImageArray[indexPath.row])
            //原本 END
            
            //            cell.iconImage.image = UIImage.setIconTemplate(iconName: iconImageArray[indexPath.row])
            //
            //
            //            cell.selectedBackgroundView?.backgroundColor = UIColor.orange
            
            //            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
            //
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

extension MapViewController: UITableViewDelegate {
    
}
// swiftlint:disable file_length
//swiftlint:disable all
