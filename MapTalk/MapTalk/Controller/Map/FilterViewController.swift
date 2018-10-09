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

class FilterViewController: UIViewController {
    
    //@IBOutlet weak var datingTypeCollectionView: UICollectionView!
    
    //@IBOutlet weak var timeCollectionView: UICollectionView!
    
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    @IBOutlet weak var ageSegment: UISegmentedControl!
    
    @IBOutlet weak var locationSegment: UISegmentedControl!
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    var filterData: [Filter] = []
    //var filterAllData: Filter? //若宣告在這不給問號要給啥???
    
    var filterNewData: [FilterData] = []
    
    var gender = ""
    
    var iconNameArray: [String] = ["看夜景","唱歌","喝酒","吃飯","看電影","浪漫","喝咖啡","兜風"]
    //imageArray: [UIImage] = []
    //var iconImageArray: [UIImage] = [UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!]
    
    var iconImageArray: [String] = ["date-crescent-moon-50",
                                    "date-micro-filled-50",
                                    "date-wine-glass-50",
                                    "date-dining-room-50","date-documentary-50","date-romance-50",
                                    "date-cafe-50","date-car-50"]
    
    var filterEnum: [FilterIcon] = [
        
        .moon,
        .microphone,
        .wine,
        .dinner,
        .movie,
        .romance,
        .cafe,
        .cars,
        
        //        case moon = "date-crescent-moon-50"
        //    case microphone = "date-micro-filled-100"
        //    case wine = "date-wine-glass-50"
        //    case dinner = "date-dining-room-50"
        //    case movie = "date-documentary-50"
        //    case romance = "date-romance-50"
        //    case cafe = "date-cafe-50"
        //    case car = "date-car-50"
        
        
    ]
    
    //20181008
    var friendUserName: String?
    
    var friendUserId: String?
    
    var timeNameArray: [String] = ["現在","隨時","下班後","週末"]
    var timeImageArray: [String] = ["date-present-50",
                                    "date-future-50",
                                    "date-business-50",
                                    "date-calendar-50"]
    
    var selectedDateIcon1 : IndexPath = []
    var datingNumber: Int?
    
    var selectedTimeIcon1 : IndexPath = []
    var timeNumber: Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        //20181008
        //可以用
        
//        var pencilImage = UIImage(named: "chat_arrow_up")!
//        // swiftlint:disable force_cast
//        let pencilBtn: UIButton = UIButton(type: UIButton.ButtonType.custom) as! UIButton
//
//        // swiftlint:enable force_cast
//
//        pencilBtn.setImage(pencilImage, for: UIControl.State.normal)
//        pencilBtn.addTarget(self, action: "pencilBtnPressed", for: UIControl.Event.touchUpInside)
//        pencilBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        let pencilBarBtn = UIBarButtonItem(customView: pencilBtn)
//
//        self.navigationItem.setRightBarButtonItems([pencilBarBtn], animated: false)
        
        //END
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(addTapped))


        
        //        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
//        let play = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playTapped))
//
//        navigationItem.rightBarButtonItems = [add, play]

        
        // self.view.backgroundColor = .clear
        // self.view.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
        
        
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
        
        
        
        //self.filterCollectionView.register(headerNib, forCellReuseIdentifier: "FilterHeader")
        
        //let cellNib = UINib(nibName: "TypeCollectionViewCell", bundle: nil)
        //self.typeCollectionView.register(cellNib, forCellWithReuseIdentifier: "typeCell")
        
        
        
        //        datingTypeCollectionView.delegate = self
        //        datingTypeCollectionView.dataSource = self
        //
        //        timeCollectionView.delegate = self
        //        timeCollectionView.dataSource = self
        //
        //        datingTypeCollectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        //
        //        timeCollectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        
        //        datingTypeCollectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil),
        //                               forCellReuseIdentifier: "Date")
        
        
    }
    
    @objc func addTapped() {
        print("點擊了按下 Save 的按鈕")
    }
    
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        
        switch genderSegment.selectedSegmentIndex
        {
        case 0:
            print("男生")
            
            //filterData[0].gender = "男生"
            //            filterAllData = Filter(gender: <#String#>, age: <#String#>, location: <#String#>, dating: <#String#>, time: <#String#>)
            
        case 1:
            print("女生")
            
        case 2:
            print("全部")
            
        default:
            
            
            print("男生")
            break;
        }
        
    }
    
    
    @IBAction func ageChanged(_ sender: UISegmentedControl) {
        switch ageSegment.selectedSegmentIndex
        {
        case 0:
            print("18 - 25")
            
        case 1:
            print("26 - 35")
            
        case 2:
            print("36 以上")
            
        default:
            
            
            print("年齡")
            break;
        }
        
    }
    
    
    @IBAction func locationChanged(_ sender: UISegmentedControl) {
        
        switch locationSegment.selectedSegmentIndex
        {
        case 0:
            print("3 KM")
            
        case 1:
            print("15 KM")
            
        case 2:
            print("30 KM")
            
        default:
            
            print("距離")
            break;
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func getFilterData() {
        //let value = genderChanged.(value)
        //let title = genderChanged
        print(genderSegment.selectedSegmentIndex)
        
        //應該要有個地方 存自己的年紀性別和經緯度來算距離
        guard let datingNumber = datingNumber else { return }
        guard let timeNumber = timeNumber else { return }
        
        //有可能沒按到約會類型和時間範圍 要給預設值或是設定?
        guard let filterAllData: Filter = Filter(gender: genderSegment.selectedSegmentIndex,
                                                 age: ageSegment.selectedSegmentIndex,
                                                 location: locationSegment.selectedSegmentIndex,
                                                 dating: datingNumber,
                                                 time: timeNumber)    else { return }
        
        print("filterALLData 是 \(filterAllData)")
        
        //guard let text = messageTxt.text else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let createdTime = Date().millisecondsSince1970
        
        //let messageKey = self.ref.child("FilterData").child("PersonalChannel").child(friendChannel).childByAutoId().key
        self.ref.child("FilterData").child(userId).setValue([
            "senderId": userId,
            "senderName": userName,
            "senderPhoto": userImage,
            "time": createdTime,
            "gender": filterAllData.gender,
            "age": filterAllData.age,
            "location": filterAllData.location,
            "dating": filterAllData.dating,
            "datingTime": filterAllData.time
        ]) { (error, _) in
            
            if let error = error {
                
                print("Data could not be saved: \(error).")
                
            } else {
                
                print("Data saved successfully!")
                
            }
        }
        
        searchFilterData(filterData: filterAllData)
        
    }
    
    func searchFilterData(filterData: Filter) {
        
        //        refference.child("location").observe(.childAdded) { (snapshot) in
        
        
        //抓一個最難他達到的條件的下來判斷 讓資料量減少
        
//        ref.child("FilterData").queryOrdered(byChild: "dating").queryEqual(toValue: filterData.dating).observe(.childChanged) { (snapshot) in
            
        
        //        ref.child("FilterData").queryOrdered(byChild: "dating").queryEqual(toValue: filterData.dating).observeSingleEvent(of: .value, with: { (snapshot)

        
        ref.child("FilterData").queryOrdered(byChild: "dating").queryEqual(toValue: filterData.dating).observe(.childAdded) { (snapshot) 
            
            in
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            
            // childChanged 不能監控自身的變化嗎？ 改了 dating 沒反應 改 datingtime 可以
            // Q2: 是否要執行過一次 才會持續的監控 childChanged
            // 應該把相同的都先抓下來 依序判斷是否相同 跳出 alert
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            //print(value)
            
            // swiftlint:disable identifier_name
            guard let age = value["age"] as? Int else { return }
            // swiftlint:enable identifier_name

            guard let dating = value["dating"] as? Int else { return }
            
            guard let datingTime = value["datingTime"] as? Int else { return }
            
            guard let gender = value["gender"] as? Int else { return }
            
            guard let location = value["location"] as? Int else { return }
            
            guard let senderName = value["senderName"] as? String else { return }

            guard let senderId = value["senderId"] as? String else { return }
            
            guard let time = value["time"] as? Int else { return }
            
            guard let senderPhoto = value["senderPhoto"] as? String else { return }
            
            let filterData = FilterData(gender: gender,
                                        age: age,
                                        location: location,
                                        dating: dating,
                                        datingTime: datingTime,
                                        time: time,
                                        senderId: senderId,
                                        senderName: senderName,
                                        senderPhotoURL: senderPhoto)
            
            //先用名字 到時候再加上性別 和時間
            if senderId != userId {
            
                self.filterNewData.append(filterData)
                
                self.showMessageAlert(title: "登愣！！！ 發現和 \(senderName) 有相同的喜好", message: "認識一下吧！", senderId: senderId, senderName: senderName)
                print("選取的人的 userID 是 \(senderId)")

                
            } else {
                print("自己的資料不用存")
            }
//            self.friendUserName = senderName
//            self.friendUserId = senderId
//
//            guard let friendUserName = self.friendUserName  else { return }
            
            
            
            
            //            guard let senderId = value["senderId"] as? String else { return }
            //
            //            guard let senderName = value["senderName"] as? String else { return }
            //
            //            guard let time = value["time"] as? Int else { return }
            //
            //            let content = value["content"] as? String
            //
            //            let senderPhoto = value["senderPhoto"] as? String
            //
            //            let imageUrl = value["imageUrl"] as? String
            //
            //            let message = Message(
            //                content: content,
            //                senderId: senderId,
            //                senderName: senderName,
            //                senderPhoto: senderPhoto,
            //                time: time,
            //                imageUrl: imageUrl
            //            )
            
            print(" *** 準備印 searchFilterData 的資料 ")
            print(value)
            
            //search 完去比對資料配對
            
//                    self.showMessageAlert(title: "傳訊息給\(self.friendUserName) 嗎～？", message: "認識一下吧！")
//                    print("選取的人的 userID 是 \(self.friendUserId)")
            
        } //)
        
    }
    
    
    
    @IBAction func saveButtonClick(_ sender: UIButton) {
        
        getFilterData()
        
    }
    
    func showMessageAlert(title: String, message: String,senderId: String,senderName: String) {
        
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
            
            //新增對方到 firebase 的好友列表
            
            //guard let friendId =  self.friendUserId else { return }
            
            guard let myselfId = Auth.auth().currentUser?.uid else { return }
            //guard let friendName = self.friendUserName else { return }
            
            guard let myselfName = Auth.auth().currentUser?.displayName else { return }
            
            
            //refference.child("UserFriendList").child(myselfId).child(friendId).setValue([])
            
            // 我媒合到 friend 在我自己的節點下 存朋友的 ID 並且 朋友的狀態為 發出邀請中
            // 被我媒合的到的朋友 在朋友的節點下 存下自己的 ID 並且 朋友的狀態為 收到邀請中
            // 朋友應該監控自己下方的節點 邀請中 如果有 要跳出 alert 提醒有人要跟你當朋友
            
            let myChildUpdates = ["/UserData/\(myselfId)/FriendsList/\(senderId)": ["FriendUID": "\(senderId)","FriendName": "\(senderName)","Accept": "發出邀請中","Friend_Email": "emailTest"]]
            
            let friendChildUpdates = ["/UserData/\(senderId)/FriendsList/\(myselfId)": ["FriendUID": "\(myselfId)","FriendName": "\(myselfName)","Accept": "收到邀請中","Friend_Email": "emailTest"]]
            
            
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

extension FilterViewController: UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 8
            
        } else {
            return 4
        }
        
        //return 12
        //        if(collectionView == self.datingTypeCollectionView) {
        //            //cell.backgroundColor = UIColor.black
        //            return 8
        //        } else {
        //            return 4
        //            //cell.backgroundColor = self.randomColor()
        //        }
        
        
        
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
        
        
        //        if(collectionView == self.datingTypeCollectionView) {
        //            //cell.backgroundColor = UIColor.black
        //            //cell?.iconName.text =
        //            //cell?.iconImage
        //
        //            //cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
        //            cell?.iconName.text = iconNameArray[indexPath.row]
        //
        //            //cell.iconImage.backgroundColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) // FB message borderColor
        //
        //            //原本寫法
        //            //            cell?.iconImage.image = UIImage(named: iconImageArray[indexPath.row])
        //
        //            //傳輸照片的同時 把照片 set 成 template
        //            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
        //            //cell?.iconImage.image = UIImage(named: filterEnum[indexPath.row.])
        //
        //
        //            //return cell
        //        } else {
        //
        //            //cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
        //            cell?.iconName.text = timeNameArray[indexPath.row]
        //
        //            cell?.iconImage.image = UIImage(named: timeImageArray[indexPath.row])
        //
        //            //return cell
        //            //cell.backgroundColor = self.randomColor()
        //        }
        
        
        
        // 設定背景色
        //        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.orange : UIColor.brown
        
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: 103, height: 40)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //        var reusableview:UICollectionReusableView!
        //        //分区头
        //        if kind == UICollectionView.elementKindSectionHeader{
        //            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        //                                                                           withReuseIdentifier: "HeaderView", for: indexPath)
        //            //设置头部标题
        //            let label = reusableview.viewWithTag(1) as! UILabel
        //            label.text = books[indexPath.section].title
        //        }
        //            //分区尾
        //        else if kind == UICollectionView.elementKindSectionFooter{
        //            reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
        //                                                                           withReuseIdentifier: "FooterView", for: indexPath)
        //
        //        }
        //        return reusableview
        
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
        
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        //selectedCell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if  indexPath.section == 0 {
            
            if selectedDateIcon1 == indexPath {
                
                // selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                collectionView.cellForItem(at: selectedDateIcon1)?.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
                
                print("相同")
                
            } else {
                
                //selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                collectionView.cellForItem(at: selectedDateIcon1)?.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            }
            
            
            
        }
        if   indexPath.section == 1 {
            
            if selectedTimeIcon1 == indexPath {
                
                // selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                collectionView.cellForItem(at: selectedTimeIcon1)?.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
                
                print("相同")
                
                
            } else {
                
                //selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                collectionView.cellForItem(at: selectedTimeIcon1)?.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                
            }
        }
        
        
        if indexPath.section == 0 {
            print("你選擇了 Dating \(indexPath.section) 組的")
            print("第 \(indexPath.item ) 張圖片")
            selectedDateIcon1 = indexPath
            datingNumber = indexPath.item
            #warning ("TODO: 點擊後變色 且只能點一個 點了其中一個其他的就不能點 或者再把原本的取消才能再點下一個，或是點擊後再點其他的 本來的會消失 只顯示另外ㄧ個")
            //let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
            
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            //            let selectedCell:UICollectionViewCell = myCollectionView.cellForItemAtIndexPath(indexPath)!
            //            selectedCell.contentView.backgroundColor = UIColor(red: 102/256, green: 255/256, blue: 255/256, alpha: 0.66)
            //
            
            #warning ("TODO: 儲存他按了哪一個")
            
        }
        else {
            print("你選擇了 time \(indexPath.section) 組的")
            print("第 \(indexPath.item) 張圖片")
            
            selectedTimeIcon1 = indexPath
            timeNumber = indexPath.item
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            #warning ("TODO: 儲存他按了哪一個")
        }
        
        
    }
    
}

//extension FilterViewController: UICollectionViewDelegateFlowLayout{
//
//}

// MARK: - 設定 CollectionView Cell 與 Cell 之間的間距、距確 Super View 的距離等等
extension FilterViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    //    }
    
    ///  設定 CollectionViewCell 的寬、高
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - indexPath: _
    /// - Returns: _
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.size.width) / 4 , height: (self.view.frame.size.width) / 4)
        
        
        //        return CGSize(width: (self.view.frame.size.width - 30) / 2 , height: (self.view.frame.size.width - 30) / 2)
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
