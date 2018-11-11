//
//  FilterViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/30.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MapKit //為了拿到 CLLocationCoordinate2D
import NotificationBannerSwift

protocol sendAlertstatus: AnyObject {
    func checkBool(flag: Bool)
}

class FilterViewController: UIViewController {
    
    weak var delegate: sendAlertstatus?
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    @IBOutlet weak var maxAgeSlider: UISlider!
    @IBOutlet weak var minAgeSlider: UISlider!
    @IBOutlet weak var maxAgeSliderValue: UILabel!
    @IBOutlet weak var minAgeSliderValue: UILabel!
    @IBOutlet weak var locationSlider: UISlider!
    @IBOutlet weak var locationSliderValue: UILabel!
    let step: Float = 1
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    var filterData: [Filter] = []
    
    var filterNewData: [FilterData] = []
    
    var gender = ""
    
    var iconNameArray: [String] = ["看夜景", "唱歌", "喝酒", "吃飯", "看電影", "浪漫", "喝咖啡", "兜風"]
    
    var iconImageArray: [String] = ["date-crescent-moon-50",
                                    "date-micro-filled-50",
                                    "date-wine-glass-50",
                                    "date-dining-room-50", "date-documentary-50", "date-romance-50",
                                    "date-cafe-50", "date-car-50"]
    
    var filterEnum: [FilterIcon] = [
        
        .moon,
        .microphone,
        .wine,
        .dinner,
        .movie,
        .romance,
        .cafe,
        .cars
    ]
    
    var friendUserName: String?
    
    var friendUserId: String?
    
    var timeNameArray: [String] = ["現在", "隨時", "下班後", "週末"]
    var timeImageArray: [String] = ["date-present-50",
                                    "date-future-50",
                                    "date-business-50",
                                    "date-calendar-50"]
    
    var selectedDateIcon1: IndexPath = []
    var datingNumber: Int?
    
    var selectedTimeIcon1: IndexPath = []
    var timeNumber: Int?
    
    //20181009
    var centerDeliveryFromMap: CLLocationCoordinate2D?
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var currentCenter: CLLocationCoordinate2D?
    
    //20181028
    var flag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(addTapped))
        
        // swiftlint:disable identifier_name
        let nib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        // swiftlint:enable identifier_name
        
        filterCollectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
        
        let headerNib = UINib(nibName: "FilterHeaderCollectionViewCell", bundle: nil)
        
        filterCollectionView.register(headerNib, forCellWithReuseIdentifier: "FilterHeaderCell")
        
        filterCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FilterHeaderCell")
        
        ref = Database.database().reference() //重要 沒有會 nil
        
        setAgeSlider()
        setLocationSlider()
        detectUserInfo()
        
        //是否跳過 alert 判斷
        guard let myselfId = Auth.auth().currentUser?.uid else {
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式 請登出後使用 Facebook 登入")
            return }
        
        //20181009
        locManager.requestWhenInUseAuthorization()
        currentLocation = locManager.location

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //showLocationAlert()
        
        delegate?.checkBool(flag: true)
        
        if flag == true {
            print("已經跑過這個 showLocationAlert() 選項了 filterVC")
        } else {
            guard let myselfId = Auth.auth().currentUser?.uid else {
                BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式 請登出後使用 Facebook 登入")
                return }
            showLocationAlert()
            //flag = true
        }
        
    }
    
    //20181028 增加 alert 告訴他我正在使用他的位置
    
    func showLocationAlert() {
        
        guard let myselfId = Auth.auth().currentUser?.uid else {
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式 請登出後使用 Facebook 登入")
            return }
        let alertController =  UIAlertController.showAlert(
            title: "是否向其他人顯示自己位置？",
            message: "按下『 顯示 』 或是 『 隱藏 』來改變狀態，需要顯示才能正常使用地圖功能。",
            defaultOption: ["顯示", "隱藏"]) { [weak self] (action) in
                
                switch action.title {
                    
                case "顯示":
                    
                    let userStatus = ["status": "appear"]
                    
                    let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                    
                    self?.ref.updateChildValues(childUpdatesStatus)
                    print("按下顯示3 MapViewController")
                    
                case "隱藏":
                    
                    let userStatus = ["status": "disappear"]
                    
                    let childUpdatesStatus = ["/location/\(myselfId)/status": userStatus]
                    
                    self?.ref.updateChildValues(childUpdatesStatus)
                    print("按下隱藏2 MapViewController")
                    
                default:
                    break
                    
                }
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func detectUserInfo() {
        
        let userDefaults = UserDefaults.standard
        
        let myselfGender = userDefaults.value(forKey: "myselfGender")
        
        if myselfGender == nil {
            BaseNotificationBanner.warningBanner(subtitle: "請先到個人資料頁填寫資訊")
            
        } else {
            //BaseNotificationBanner.sucessBanner(subtitle: "請選擇想媒合的條件～")
        }
        
    }
    func setAgeSlider() {
        //minAgeSlider
        //max
        minAgeSlider.minimumValue = 18
        minAgeSlider.maximumValue = 65
        //minAgeSlider.minimumValue = 0
        
        //locationSlider.value = 30
        //minAgeSlider.setValue(18,animated:true)
        
        //minAgeSlider.tintColor = UIColor.lightGray
        //minAgeSlider.maximumTrackTintColor = maxAgeSlider.tintColor
        
        maxAgeSlider.minimumValue = 18
        //maxAgeSlider.setValue(30,animated:true)
        maxAgeSlider.maximumValue = 65
        //maxAgeSlider.minimumValue = 0
        maxAgeSlider.setValue(30, animated: true)
        
        // UISlider 是否可以在變動時同步執行動作
        // 設定 false 時 則是滑動完後才會執行動作
        
        minAgeSlider.isContinuous = true
        minAgeSlider.addTarget(self, action: #selector(minAgeSliderDidchange(_:)), for: UIControl.Event.valueChanged)
        
        maxAgeSlider.isContinuous = true
        maxAgeSlider.addTarget(self, action: #selector(maxAgeSliderDidchange(_:)), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func minAgeSliderDidchange(_ slider: UISlider) {
        
        let roundedStepValue = round(slider.value / step) * step
        slider.value = roundedStepValue
        
        
        minAgeSlider.maximumValue = maxAgeSlider.value
        
        minAgeSliderValue.text = "\(Int(minAgeSlider.value))"
        print(slider.value)
    }
    
    @objc func maxAgeSliderDidchange(_ slider: UISlider) {
        
        let roundedStepValue = round(slider.value / step) * step
        slider.value = roundedStepValue
        
        //        minAgeSlider.maximumValue = maxAgeSlider.value
        //        maxAgeSlider.minimumValue = minAgeSlider.value
        maxAgeSlider.minimumValue = minAgeSlider.value
        
        //locationSliderValue.text = String(Int(slider.value))
        maxAgeSliderValue.text = " \(Int(maxAgeSlider.value))"
        print(slider.value)
    }
    
    func setLocationSlider() {
        
        locationSlider.minimumValue = 1
        locationSlider.maximumValue = 100
        locationSlider.setValue(30, animated: true)
        
        locationSlider.isContinuous = true
        
        locationSlider.addTarget(self, action: #selector(locationSliderDidchange(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func locationSliderDidchange(_ slider: UISlider) {
        
        let roundedStepValue = round(slider.value / step) * step
        slider.value = roundedStepValue
        
        //locationSliderValue.text = String(Int(slider.value))
        locationSliderValue.text = " \(Int(slider.value)) 公里 "
        print(slider.value)
        
    }
    
    @objc func addTapped() {
        
        getFilterData()
        
        print("點擊了按下 Save 的按鈕")
    }
    
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        
        switch genderSegment.selectedSegmentIndex {
        case 0:
            print("男生")
            
        case 1:
            print("女生")
            
        case 2:
            print("全部")
            
        default:
            print("男生")
            break
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        }
    
    func getFilterData() {
        
        print(genderSegment.selectedSegmentIndex)
        
        //應該要有個地方 存自己的年紀性別和經緯度來算距離
        guard let datingNumber = datingNumber else { return }
        guard let timeNumber = timeNumber else { return }
        
        //有可能沒按到約會類型和時間範圍 要給預設值或是設定?
        guard let filterAllData: Filter = Filter(gender: genderSegment.selectedSegmentIndex,
                                                 age: Int(minAgeSlider.value),
                                                 location: Int(locationSlider.value),
                                                 dating: datingNumber,
                                                 time: timeNumber)    else { return }
        
        print("filterALLData 是 \(filterAllData)")
        print("*********")
        print("自己的位置是\(centerDeliveryFromMap)")
        //guard let text = messageTxt.text else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式 請登出後使用 Facebook 登入")
            return }
        
        guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let createdTime = Date().millisecondsSince1970
        
        //let messageKey = self.ref.child("FilterData").child("PersonalChannel").child(friendChannel).childByAutoId().key
        
        //  "location": filterAllData.location,
        //         "location": ["lat": currentLocation.coordinate.latitude,"lon": currentLocation.coordinate.longitude],
        
        // 或是經緯度先給預設值 只要他有移動位置 就會更新他目前的位置 但是要是第一次進來直接媒合 這邊 setvalue 可能會取代掉正確的位置資訊  這邊可以試著用 update
        // 25°2'51"N   121°31'1"E 北車 "location": ["lat": 25.251,"lon": 121.311],
        let taipeiTraonLat: Double = 25.251
        let taipeiTraonLon: Double = 121.311
        
        let userDefaults = UserDefaults.standard
        
        let myselfGender = userDefaults.value(forKey: "myselfGender")
        
        self.ref.child("FilterData").child(userId).setValue([
            "senderId": userId,
            "senderName": userName,
            "senderPhoto": userImage,
            "time": createdTime,
            "gender": filterAllData.gender,
            "age": filterAllData.age,
            "location": ["lat": taipeiTraonLat, "lon": taipeiTraonLon], //value 要用 double
            "dating": filterAllData.dating,
            "datingTime": filterAllData.time,
            "myselfGender": myselfGender
        ]) { (error, _) in
            
            if let error = error {
                
                print("Data could not be saved: \(error).")
                
            } else {
                
                print("Data saved successfully!")
                BaseNotificationBanner.successBanner(subtitle: "上傳資料成功～稍後將顯示結果")
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
        searchFilterData(filterData: filterAllData)
        
    }
    
    func searchFilterData(filterData: Filter) {
        
        //抓一個最難他達到的條件的下來判斷 讓資料量減少
        
        ref.child("FilterData").queryOrdered(byChild: "dating").queryEqual(toValue: filterData.dating).observe(.childAdded) { (snapshot) 
            
            in
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            print("測試用20181013")
                        
            guard let value = snapshot.value as? NSDictionary else { return }
            
            //print(value)
            
            // swiftlint:disable identifier_name
            guard let age = value["age"] as? Int else { return }
            // swiftlint:enable identifier_name
            
            guard let dating = value["dating"] as? Int else { return }
            
            guard let datingTime = value["datingTime"] as? Int else { return }
            
            guard let gender = value["gender"] as? Int else { return }
            
            guard let location = value["location"] as? NSDictionary else { return }
            
            guard let userLatitude = location["lat"] as? Double else { return }
            
            guard let userLongitude = location["lon"] as? Double else { return }
            
            guard let senderName = value["senderName"] as? String else { return }
            
            guard let senderId = value["senderId"] as? String else { return }
            
            guard let time = value["time"] as? Int else { return }
            
            guard let senderPhoto = value["senderPhoto"] as? String else { return }
            
            guard let myselfGender = value["myselfGender"] as? Int else { return }
            
            let friendFilterData = FilterData(gender: gender, myselfGender: myselfGender,
                                              age: age, location: Location(latitude: userLatitude, longitude: userLongitude) ,
                                              dating: dating,
                                              datingTime: datingTime,
                                              time: time,
                                              senderId: senderId,
                                              senderName: senderName,
                                              senderPhotoURL: senderPhoto)
            //上面增加自己的性別
            
            //距離的計算
            
            //let myLocation = CLLocation(latitude: 25.998443,longitude: 120.174183)
            //下面的預設值是台北車站
            
            //            let myLocation = CLLocation(latitude: self.currentCenter?.latitude ?? 25.048134,longitude: self.currentCenter?.longitude ?? 121.517314
            //            )
            
            let myLocation =  CLLocation(latitude: self.centerDeliveryFromMap?.latitude ?? 25.048134, longitude: self.centerDeliveryFromMap?.longitude ?? 121.517314)
            
            let friendLocation = CLLocation(latitude: friendFilterData.location.latitude, longitude: friendFilterData.location.longitude)
            
            let distance = myLocation.distance(from: friendLocation) / 1000
            
            let roundDistance = round(distance * 100) / 100
            //print("***自己目前的實際所在地\(self.currentCenter?.latitude),\(self.currentCenter?.longitude )***")
            
            print("***自己目前的實際所在地\(myLocation)")
            print("***算出目前跟朋友的距離***\(senderName)")
            print("\(roundDistance) km")
            //打死算距離
            
            //時間的限制 用現在時間 減 下載下來資料的時間 小於 24 小時內才比對 （24 小時 友 86400 秒 + 000）一小時 3600 000
            let createdTime = Date().millisecondsSince1970
            let in24hr = createdTime - friendFilterData.time
            
            // 測試時間 1538924236062 Your time zone: Sunday, October 7, 2018 10:57:16.062 PM GMT+08:00
            //先用名字 到時候再加上性別 和時間 (上面的搜尋是搜尋 約會類型相同的人) filterData 是自己的本地端要去搜尋的資料
            if userId != senderId &&  filterData.time == friendFilterData.datingTime && in24hr  < 86400000 && filterData.gender == friendFilterData.myselfGender {
                
                self.filterNewData.append(friendFilterData)
                
                self.showMessageAlert(title: "登愣！！！ 發現和 \(senderName) 有相同的喜好", message: "認識一下吧！", senderId: senderId, senderName: senderName)
                print("選取的人的 userID 是 \(senderId)")
                
            } else {
                print("自己的資料不用存")
            }
            //            self.friendUserName = senderName
            //            self.friendUserId = senderId
            //
            //            guard let friendUserName = self.friendUserName  else { return }
            
            print(" *** 準備印 searchFilterData 的資料 ")
            print(value)
            
            print(" *** 準備印 filterData 的資料 ")
            print(friendFilterData)
            
            //search 完去比對資料配對
            
            //                    self.showMessageAlert(title: "傳訊息給\(self.friendUserName) 嗎～？", message: "認識一下吧！")
            //                    print("選取的人的 userID 是 \(self.friendUserId)")
            
        } //)
        
    }
    
    func showMessageAlert(title: String, message: String, senderId: String, senderName: String) {
        
        //把全域變數拿掉
        
        //要直接跳到 chatDetail 頁面
        //可以跳過去 但是返回上一頁會直接跳回 map 主頁
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default) { (_) in
            
            //collectionView.deselectItem(at: indexPath, animated: true)
            
            // 換頁並且改變 detail頁的 friendUserId 的值
            guard let controller = UIStoryboard.chatStoryboard().instantiateViewController(
                withIdentifier: String(describing: ChatDetailViewController.self)
                ) as? ChatDetailViewController else { return }
            
            //controller.article = articles[indexPath.row]
            
            controller.friendUserId = senderId
            
            self.show(controller, sender: nil)
            print("跳頁成功")
            
            //新增對方到 firebase 的好友列表
            
            //guard let friendId =  self.friendUserId else { return }
            
            guard let myselfId = Auth.auth().currentUser?.uid else { return }
            //guard let friendName = self.friendUserName else { return }
            
            guard let myselfName = Auth.auth().currentUser?.displayName else { return }
            
            //refference.child("UserFriendList").child(myselfId).child(friendId).setValue([])
            
            // 我媒合到 friend 在我自己的節點下 存朋友的 ID 並且 朋友的狀態為 發出邀請中
            // 被我媒合的到的朋友 在朋友的節點下 存下自己的 ID 並且 朋友的狀態為 收到邀請中
            // 朋友應該監控自己下方的節點 邀請中 如果有 要跳出 alert 提醒有人要跟你當朋友
            
            let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(senderId)": ["FriendUID": "\(senderId)", "FriendName": "\(senderName)", "Accept": "發出邀請中", "Friend_Email": "emailTest"]]
            
            let friendChildUpdates = ["/UserData/\(senderId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)", "FriendName": "\(myselfName)", "Accept": "收到邀請中", "Friend_Email": "emailTest"]]
            
            //            self.refference.child.updateChildValues(["/UserData/\(myselfId)/FriendsList/\(friendId)": ["accept": "發送邀請中","friend_email": "emailTest"]])
            //
            self.ref.updateChildValues(myChildUpdates)
            self.ref.updateChildValues(friendChildUpdates)
            
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}

extension FilterViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 8
        } else {
            return 4
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell
        
        if indexPath.section == 0 {
            
            cell?.iconName.text = iconNameArray[indexPath.row]
            
            //傳輸照片的同時 把照片 set 成 template
            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
            //cell?.iconImage.image = UIImage(named: filterEnum[indexPath.row.])
            
        } else {
            
            cell?.iconName.text = timeNameArray[indexPath.row]
            
            cell?.iconImage.image = UIImage(named: timeImageArray[indexPath.row])
            
        }
        
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: 103, height: 40)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let headerCellView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier:
            "FilterHeaderCell", for: indexPath) as? FilterHeaderCollectionViewCell {
            
            if indexPath.section == 0 {
                headerCellView.headerLabel.text = "約會類型"
                
            } else {
                headerCellView.headerLabel.text = "時間範圍"
            }
            
            headerCellView.headerBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
            return headerCellView
        }
        
        return UICollectionReusableView()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("******請看這******")
        
        let selectedCell: FilterCollectionViewCell = (collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell)!
        
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell
        
        //selectedCell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if  indexPath.section == 0 {
            let cell = collectionView.cellForItem(at: selectedDateIcon1)
                as? FilterCollectionViewCell
            if selectedDateIcon1 == indexPath {
                
                cell?.iconBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                cell?.iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell?.iconName.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
                print("相同")
                
            } else {
                
                cell?.iconBackgroundView.backgroundColor = UIColor.clear
                cell?.iconImage.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                cell?.iconName.textColor =  #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
            
        }
        if   indexPath.section == 1 {
            
            let cell = collectionView.cellForItem(at: selectedTimeIcon1)
                as? FilterCollectionViewCell
            
            if selectedTimeIcon1 == indexPath {
                
                cell?.iconBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                cell?.iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell?.iconName.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                print("相同")
                
            } else {
                
                cell?.iconBackgroundView.backgroundColor = UIColor.clear
                cell?.iconImage.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                cell?.iconName.textColor =  #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            }
        }
        
        if indexPath.section == 0 {
            print("你選擇了 Dating \(indexPath.section) 組的")
            print("第 \(indexPath.item ) 張圖片")
            selectedDateIcon1 = indexPath
            datingNumber = indexPath.item
            
            selectedCell.iconBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            selectedCell.iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            selectedCell.iconName.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        } else {
            print("你選擇了 time \(indexPath.section) 組的")
            print("第 \(indexPath.item) 張圖片")
            
            selectedTimeIcon1 = indexPath
            timeNumber = indexPath.item
            
            selectedCell.iconBackgroundView.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            selectedCell.iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            selectedCell.iconName.textColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        }
        
    }
    
}

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.size.width) / 4, height: (self.view.frame.size.width) / 4)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
