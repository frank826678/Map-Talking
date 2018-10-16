//
//  EditViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

//swiftlint:disable all

class EditViewController: UIViewController {
    
    @IBOutlet weak var editTableView: UITableView!
    //20181014
    var expandingCellHeight: CGFloat = 200
    let expandingIndexRow = 0
    //END
    
    //20181015
    var isEdit = false
    //END
    var userInfo = ["性別","生日","感情狀態","居住地","體型","我想尋找"]
    var userSelected =  ["男生","1993-06-06","單身","台北","肌肉結實","短暫浪漫","Frank Lin","吃飯，睡覺，看電影","台灣/美國/英國","變胖了想要多運動","高空跳傘，環遊世界","大家好，歡迎使用這個 App，希望大家都可以在這認識新朋友"]
    
    let gender = ["男生","女生","第三性別"]
    let relationship = ["不顯示","秘密","單身","穩定交往","交往中但保有交友空間","一言難盡"]
    let city = ["基隆市","台北市","新北市","桃園縣","新竹市","新竹縣","苗栗縣","台中市","彰化縣","南投縣","雲林縣","嘉義市","嘉義縣","台南市","高雄市","屏東縣","台東縣","花蓮縣","宜蘭縣","澎湖縣","金門縣","連江縣"]
    
    let bodyType = ["體型纖細","勻稱","中等身材","肌肉結實","微肉","豐滿"]
    let searchTarget = ["網上私聊","短暫浪漫","固定情人","開放式關係","先碰面再說","談心朋友"]
    
    var selectedSender: Int = 0
    
    var pickerView:UIPickerView!
    var datePicker: UIDatePicker!
    
    var cell: EditUserDataTableViewCell?
    
    let fullScreenSize = UIScreen.main.bounds.size
    // personInfo: PersonalInfo = PersonalInfo()
    var personInfo: PersonalInfo?
    var date: Date?
    //var selectedDate: String = "1980-01-01"
    
    //var friend: String?
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        editTableView.delegate = self
        editTableView.dataSource = self
        
        editTableView.register(UINib(nibName: "EditUserContentTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditUserData")
        editTableView.register(UINib(nibName: "EditContentTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditContent")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editClicked))
        
        ref = Database.database().reference() //重要 沒有會 nil
        
        downloadUserInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.topItem?.title = "     個人資料"
        
    }
    
    @objc func editClicked() {
        print("點擊了按下 Edit 的按鈕")
        isEdit = true
        editTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = "     編輯資料"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveClicked))
        
    }
    
    @objc func saveClicked() {
        print("點擊了按下 Save 的按鈕")
        isEdit = false
        editTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = "     個人資料"
        
        //上傳到 firebase
        uploadUserInfo()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editClicked))
        
    }
    
    func disableAllInput() {
        
    }
    
    func uploadUserInfo() {
        //        //let value = genderChanged.(value)
        //        //let title = genderChanged
        //        print(genderSegment.selectedSegmentIndex)
        //
        //        //應該要有個地方 存自己的年紀性別和經緯度來算距離
        //        guard let datingNumber = datingNumber else { return }
        //        guard let timeNumber = timeNumber else { return }
        //
        //        //有可能沒按到約會類型和時間範圍 要給預設值或是設定?
        //        guard let filterAllData: Filter = Filter(gender: genderSegment.selectedSegmentIndex,
        //                                                 age: ageSegment.selectedSegmentIndex,
        //                                                 location: locationSegment.selectedSegmentIndex,
        //                                                 dating: datingNumber,
        //                                                 time: timeNumber)    else { return }
        //
        //        print("filterALLData 是 \(filterAllData)")
        print("*********")
        //print(userSelected)
        print("準備上傳的 userSelected 是\(userSelected)")
        
        //print("自己的位置是\(centerDeliveryFromMap)")
        //guard let text = messageTxt.text else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        //guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        //let createdTime = Date().millisecondsSince1970
        
        //let messageKey = self.ref.child("FilterData").child("PersonalChannel").child(friendChannel).childByAutoId().key
        
        
        //  "location": filterAllData.location,
        //         "location": ["lat": currentLocation.coordinate.latitude,"lon": currentLocation.coordinate.longitude],
        
        // 或是經緯度先給預設值 只要他有移動位置 就會更新他目前的位置 但是要是第一次進來直接媒合 這邊 setvalue 可能會取代掉正確的位置資訊  這邊可以試著用 update
        // 25°2'51"N   121°31'1"E 北車
        
        //此時的 userSelected 是 array
        self.ref.child("UserInfo").child(userId).setValue(userSelected) { (error, _) in
            
            if let error = error {
                
                print("Data could not be saved: \(error).")
                
            } else {
                
                print("Data saved successfully!")
                
            }
        }
        //20181013 更新 filersearch 的條件 self 的
        
        //self.ref.child("FilterData").child(userId).setValue([
        var myselfGender = 0
        if userSelected[0] == "男生" {
            myselfGender = 0
        } else if userSelected[0] == "女生" {
            myselfGender = 1
        } else {
            myselfGender = 2
        }
        //存自己性別 filter 介面時 用 default 去讀
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(myselfGender, forKey: "myselfGender")
        
        let childUpdates = ["/FilterData/\(userId)/myselfGender": myselfGender]
        
        print("自己上傳的性別是\(myselfGender)")
        
        self.ref.updateChildValues(childUpdates)
        
        //searchFilterData(filterData: filterAllData)
        
    }
    
    func downloadUserInfo() {
        
        print("*********")
        //print(userSelected)
        //print("準備上傳的 userSelected 是\(userSelected)")
        
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //此時的 userSelected 是 array
        self.ref.child("UserInfo").child(userId).observeSingleEvent(of: .value, with: { (snapshot)
            
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
            
            
            self.editTableView.reloadData()
            
        })
        
    }
    
    
}

extension EditViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        if section == 0 || section ==  1 || section ==  3 {
        
        if section == 1 {
            return 6
        } else {
            return 1
        }
        
    }
    
    // 設置每個 section 的 title 為一個 UIView
    // 如果實作了這個方法 會蓋過單純設置文字的 section title
    private func tableView(tableView: UITableView,
                           viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // 設置 section header 的高度
    private func tableView(tableView: UITableView,
                           heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        var title = "暱稱"
        
        if section == 0 {
            
            title = "暱稱"
            
        } else if section == 1 {
            
            title = "基本資料"
            
        } else if section == 2 {
            
            title = "專長 興趣"
            
        } else if section == 3 {
            
            title = "喜歡的國家"
            
        } else if section == 4 {
            
            title = "自己最近的困擾"
            
        } else if section == 5 {
            
            title = "想嘗試的事情"
            
        } else {
            
            title = "自我介紹"
            
        }
        
        return title
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                //cell.contentTextView.text = "FRANK"
                
                //cell.baseView.contentTextView.text = userSelected[6]
                //self.cell = cell
                //userSelected[6] = cell.baseView.contentTextView.text
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[6]
                //cell.editContentTextView.delegate = self
                
                return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditContent", for: indexPath)
                as? EditContentTableViewCell {
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.userInfoButton.isEnabled = true
                } else {
                    cell.userInfoButton.isEnabled = false
                }
                
                cell.userInfoButton.tag = indexPath.row
                
                //全域 sender
                //                selectedSender = indexPath.row
                cell.userInfoButton.addTarget(self, action: #selector(userInfoButtonClicked(sender:)), for: .touchUpInside) //要加 .
                //cell.userInfoButton.titleLabel?.text = "123"
                cell.userInfoButton.setTitle(userSelected[indexPath.row], for: .normal)//设置按钮显示的文字
                //cell.userInfoButton..titleLabel?.font = UIFont.systemFont(ofSize: 23)
                //OK
                cell.userInfoButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
                
                
                cell.userInfoLabel.text = userInfo[indexPath.row]
                
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                 cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                //cell.contentTextView.text = "吃飯，睡覺"
                //cell.baseView.contentTextView.text = "吃飯，睡覺"
                //cell.baseView.contentTextView.toolbarPlaceholder = userSelected[7]
                //cell.baseView.contentTextView.text = userSelected[7]
                //userSelected[7] = cell.baseView.contentTextView.text
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[7]
                return cell
            }
            
        case 3:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                //cell.contentTextView.text = "台灣"
                //cell.baseView.contentTextView.text = "台灣"
                //cell.baseView.contentTextView.text = userSelected[8]
                //userSelected[8] = cell.baseView.contentTextView.text
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[8]
                
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                //cell.contentTextView.text = "變胖了"
                //cell.baseView.contentTextView.text = "變胖了"
                //cell.baseView.contentTextView.text = userSelected[9]
                //userSelected[9] = cell.baseView.contentTextView.text
                
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[9]
                
                return cell
            }
            
        case 5:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                //cell.contentTextView.text = "跳海"
                //cell.baseView.contentTextView.text = "跳海"
                //cell.baseView.contentTextView.text = userSelected[10]
                
                //沒用 why
                //userSelected[10] = cell.baseView.contentTextView.text
                
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[10]
                
                return cell
            }
            
        case 6:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserContentTableViewCell {
                
                //cell.contentTextView.text = "大家好 我是法克"
                //cell.baseView.contentTextView.text = "大家好 我是法克"
                
                //cell.baseView.contentTextView.text = userSelected[11]
                
                //沒用 why
                //userSelected[11] = cell.baseView.contentTextView.text
                
                //                cell.delegate = self
                //                cell.baseView.delegate = self
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.editContentTextView.isUserInteractionEnabled = true
                } else {
                    
                    cell.editContentTextView.isUserInteractionEnabled = false
                    
                }
                cell.delegate = self
                cell.editContentTextView.text = userSelected[11]
                
                return cell
            }
            
            
            //return UITableViewCell()
            
        default:
            
            return  UITableViewCell()   //要有() 也因為上面有 -> UITableViewCell 所以一定要有一個回傳值
        }
        
        return  UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //目前 EditUserDataTableViewCell 沒有拉 限制高度
        
        //        return 80
        //return self.view.frame.width * (53 / 375)
        
        //        if indexPath.row == expandingIndexRow {
        //            return expandingCellHeight
        //        } else {
        //            return 100
        //        }
        
        //自我介紹列讓系統偵測  原本是全部都 automaticDimension
        //        if indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5  {
        //        return 80
        //        }    //return 100
        //        else {
        //            return UITableView.automaticDimension
        //        }
        
        if indexPath.section == 1 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
        
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        //userSelected[indexPath.row] = cell.baseView.contentTextView.text
    //
    //        if let cell = tableView.dequeueReusableCell(
    //            withIdentifier: "EditUserData", for: indexPath)
    //            as? EditUserDataTableViewCell {
    //
    //           userSelected[indexPath.row] = cell.baseView.contentTextView.text
    //
    //           editTableView.reloadData()
    //        }
    //
    //    }
    
}

extension EditViewController: UITableViewDelegate{}

//extension EditViewController: CellDelegate {
//
//    /*
//    func updated(height: CGFloat) {
//        expandingCellHeight = height
//
//        // Disabling animations gives us our desired behaviour
//        UIView.setAnimationsEnabled(false)
//        /* These will causes table cell heights to be recaluclated,
//         without reloading the entire cell */
//        editTableView.beginUpdates()
//        editTableView.endUpdates()
//        // Re-enable animations
//        UIView.setAnimationsEnabled(true)
//
//        let indexPath = IndexPath(row: expandingIndexRow, section: 0)
//
//        editTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//
//    }
//
//    */
//    func editSave(textInput: String, tableViewCell: UITableViewCell) {
//        //editTableView.indexPath(for: tableViewCell)
//
//        guard let indexPath = editTableView.indexPath(for: tableViewCell) else { return }
//        if indexPath.section == 0 {
//            print("名字列")
//            userSelected[6] = textInput
//        } else if indexPath.section == 1 {
//            print("已經做好 alert pickerView")
//        } else if indexPath.section == 2 {
//            print("興趣列")
//            userSelected[7] = textInput
//        } else if indexPath.section == 3 {
//            print("國家列")
//            userSelected[8] = textInput
//        } else if indexPath.section == 4 {
//            print("困擾列")
//            userSelected[9] = textInput
//        } else if indexPath.section == 5 {
//            print("嘗試列")
//            userSelected[10] = textInput
//        } else if indexPath.section == 6 {
//            print("自我介紹列")
//            userSelected[11] = textInput
//        } else {
//            print("錯誤")
//        }
//
//        //userSelected[(indexPath?.row)!] = textInput
//        editTableView.reloadData()
//    }
//
//    //    func editSave(textInput: String) {
//    //
////       // userSelected[11] = cell.baseView.contentTextView.text
////
//    //}
//
//
//    //    func updateLocalData(data: Any) {
//    //
//    //        guard let text = data as? String else {
//    //
//    //            return
//    //        }
//    //
//    //        guard let currentUser =  Auth.auth().currentUser else {
//    //
//    //            return
//    //
//    //        }
//    //
//    //        #warning ("改view")
//    //
//    //        guard let sectionIndex = allData.firstIndex(where: {$0.dataType == .previousComments(comments.count)}) else {
//    //
//    //            return
//    //        }
//    //
//    //        comments.append(
//    //            CommentModel(
//    //                postDate: Date(),
//    //                user: UserModel.groupMember(
//    //                    image: "currentUser.photoURL",
//    //                    name: currentUser.displayName!
//    //                ),
//    //                comment: text
//    //            )
//    //        )
//    //
//    //        allData[sectionIndex] = DataType(
//    //            dataType: .previousComments(comments.count),
//    //            data: comments)
//    //
//    //        self.tableView.reloadData()
//    //    }
//
//    func reszing(heightGap: CGFloat) {
//       // UIView.setAnimationsEnabled(false)
//
//        //old
//        editTableView.contentInset.bottom += heightGap
//        editTableView.contentOffset.y += heightGap
//        //END
//
////        editTableView.beginUpdates()
////        editTableView.endUpdates()
////
////        UIView.setAnimationsEnabled(true)
////
////        let indexPath = IndexPath(row: expandingIndexRow, section: 0)
////
////        editTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
//
//    }
//
//    //    func cellButtonTapping(_ cell: UITableViewCell) {
//    //
//    //        guard let currentUser =  Auth.auth().currentUser else {
//    //
//    //            return
//    //
//    //        }
//    //
//    //        #warning ("update 這邊 order 的 data")
//    //
//    //        guard let sectionIndex = allData.firstIndex(where: {$0.dataType == .productItems(products.count)}) else {
//    //
//    //            return
//    //        }
//    //
//    //        for (index) in products.indices {
//    //
//    //            guard let cell = tableView.cellForRow(
//    //                at: IndexPath(row: index, section: sectionIndex)
//    //                ) as? ProductItemTableViewCell else {
//    //
//    //                    return
//    //            }
//    //
//    //            products[index].numberOfItem -= order[index].numberOfItem
//    //            order[index].numberOfItem = 0
//    //
//    //            cell.updateView(product: products[index])
//    //
//    //        }
//    //
//    //        #warning ("更新 firebase 的資料後重新 fetch")
//    //        joinMember.append(
//    //            UserModel(
//    //                userImage: currentUser.photoURL!.absoluteString,
//    //                userName: currentUser.displayName!,
//    //                numberOfEvaluation: 2,
//    //                buyNumber: 3,
//    //                averageEvaluation: 5.0
//    //            )
//    //        )
//    //
//    //        let banner = NotificationBanner(title: "加團成功", subtitle: "詳細資訊請到歷史紀錄區查詢", style: .success)
//    //        banner.show()
//    //
//    //        #warning ("加團失敗的警告")
//    //
//    //        guard let index = allData.firstIndex(where: {$0.dataType == .joinGroup}),
//    //            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? JoinGroupTableViewCell else {
//    //
//    //                return
//    //        }
//    //
//    //        cell.collectionView.reloadData()
//    //
//    //        tableView.reloadData()
//    //    }
//
//}

extension EditViewController: UIPickerViewDataSource {
    
    //@IBAction
    //let test = "3" Extensions must not contain stored properties
    
    @objc func userInfoButtonClicked(sender: UIButton) {
        
        let buttonRow = sender.tag
        selectedSender = buttonRow
        //let result = articles[buttonRow]
        if buttonRow == 1 {
            dateButtonPressed(buttonRow)
        } else {
            selectDatePick(buttonRow)
            
        }
        print(buttonRow) //OK 可以知道點了哪一個
    }
    
    func dateButtonPressed(_ sender: Any) {
        
        datePicker = UIDatePicker(frame: CGRect(
            x: -10, y: 0,
            width: fullScreenSize.width, height: 250))
        
        datePicker.datePickerMode = .date
        
        datePicker.date = Date()
        
        let alertController: UIAlertController = UIAlertController(
            title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(
        title: "確定", style: UIAlertAction.Style.default) { (_) -> Void in
            
            print("選取的時間是\(self.datePicker.date)")
            let pickerDate = DateManager.share.formatDate(date: self.datePicker.date)
            
            self.userSelected[1] = pickerDate
            
            //date = pickerDate
            
            //            guard let cell = self.editTableView.cellForRow(at: IndexPath(row: 0, section: 1))
            //                as? EditContentTableViewCell else { return }
            //
            
            
            //            let pickerDate = DateManager.share.transformDate(date: self.datePicker.date)
            //
            //            self.date = pickerDate
            //
            //            print(pickerDate)
            //
            //            let titleDate = DateManager.share.formatDate(forTaskPage: pickerDate)
            //
            //            self.dateButton.setTitle(titleDate, for: .normal)
            
            print("轉換過的時間為\(pickerDate)")
            //要有 reload data 此時 model 已經改變
            self.editTableView.reloadData()
            
        })
        
        alertController.addAction(UIAlertAction(
            title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        
        alertController.view.addSubview(datePicker)
        
        //self.show(alertController, sender: nil)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //    func dateButtonPressed(_ sender: Any) {
    //
    //        datePicker = UIDatePicker(frame: CGRect(
    //            x: 0, y: 0,
    //            width: UIScreen.main.bounds.width - 5, height: 250))
    //
    //        datePicker.datePickerMode = .date
    //
    //        datePicker.date = Date()
    //
    //        let alertController: UIAlertController = UIAlertController(
    //            title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
    //
    //        alertController.addAction(UIAlertAction(
    //        title: "OK", style: UIAlertAction.Style.default) { (_) -> Void in
    //
    //            //let pickerDate = DateManager.share.transformDate(date: self.datePicker.date)
    //
    //            //self.date = pickerDate
    //
    //            //print(pickerDate)
    //
    //            //let titleDate = DateManager.share.formatDate(forTaskPage: pickerDate)
    //
    //            //self.dateButton.setTitle(titleDate, for: .normal)
    //        })
    //
    //        alertController.addAction(UIAlertAction(
    //            title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    //
    //        alertController.view.addSubview(datePicker)
    //
    //        self.show(alertController, sender: nil)
    //    }
    
    func selectDatePick(_ sender: Any) {
        //初始化UIPickerView
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        //设置选择框的默认值
        //pickerView.selectRow(0, inComponent:0, animated:true)
        //把UIPickerView放到alert里面（也可以用datePick）
        
        let alertController: UIAlertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default){
            (alertAction)->Void in
            
            print("確定送出為\(self.pickerView.selectedRow(inComponent: 0))的 row")
            let rowInt = self.pickerView.selectedRow(inComponent: 0)
            
            //var userSelected =  ["男","1993-06-06","單身","台北","臃腫","喝酒"]
            
            if self.selectedSender == 0 {
                
                self.userSelected[0] = self.gender[rowInt]
                
            } else if self.selectedSender == 2 {
                
                self.userSelected[2] = self.relationship[rowInt]
                
            } else if self.selectedSender == 3 {
                
                self.userSelected[3] = self.city[rowInt]
                
            } else if self.selectedSender == 4 {
                
                self.userSelected[4] = self.bodyType[rowInt]
                
            } else if self.selectedSender == 5 {
                
                self.userSelected[5] = self.searchTarget[rowInt]
                
            }
            
            self.editTableView.reloadData()
            
            print("目前的 userSelected 是\(self.userSelected)")
            //print("date select:" + String(self.pickerView.selectedRow(inComponent: 0)+1))
            //            personInfo?.gender = gender[rowInt]
            //                    personInfo?.relationship = relationship[rowInt]
            //                    personInfo?.city = city[rowInt]
            //                    personInfo?.bodyType = bodyType[rowInt]
            //
            //                    personInfo?.searchTarget = searchTarget[rowInt]
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler:nil))
        //let width = frameView.frame.width;
        
        //350
        pickerView.frame = CGRect(x: -10, y: 0, width: fullScreenSize.width, height: 250)
        alertController.view.addSubview(pickerView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //@IBOutlet weak var frameView: UIView!
    
    //设置选择框的列数为3列,继承于UIPickerViewDataSource协议
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //设置选择框的行数为9行，继承于UIPickerViewDataSource协议
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        
        if selectedSender == 0 {
            return gender.count
        } else if selectedSender == 2 {
            return relationship.count
        } else if selectedSender == 3 {
            return city.count
        } else if selectedSender == 4 {
            return bodyType.count
        } else if selectedSender == 5 {
            return searchTarget.count
        } else {
            return 12
        }
        
        //return 12
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(_ pickerView: UIPickerView, titleForRow rowInt: Int,
                    forComponent component: Int) -> String? {
        //新增日期結束
        if selectedSender == 0 {
            return gender[rowInt]
        } else if selectedSender == 2 {
            return relationship[rowInt]
        } else if selectedSender == 3 {
            return city[rowInt]
        } else if selectedSender == 4 {
            return bodyType[rowInt]
        } else if selectedSender == 5 {
            return searchTarget[rowInt]
        } else {
            
            return String(rowInt+1)+""+String("個月")
            
        }
        
        
        //return String(rowInt+1)+""+String("個月")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow rowInt: Int, inComponent component: Int) {
        //        if component == 0 {
        //            // whatDay 設置為陣列 week 的第 row 項資料
        //            whatDay = week[row]
        //        } else {
        //            // 否則就是改變第二列
        //            // whatMeal 設置為陣列 meals 的第 row 項資料
        //            whatMeal = meals[row]
        //        }
        
        // 將改變的結果印出來
        //personInfo = PersonalInfo()
        
        //        if selectedSender == 0 {
        //
        //        } else if selectedSender == 2 {
        //            return relationship[rowInt]
        //        } else if selectedSender == 3 {
        //            return city[rowInt]
        //        } else if selectedSender == 4 {
        //            return bodyType[rowInt]
        //        } else if selectedSender == 5 {
        //            return searchTarget[rowInt]
        //        }
        
        //        personInfo = PersonalInfo(gender: gender[rowInt], relationship: relationship[rowInt], city: city[rowInt]
        //            , bodyType: bodyType[rowInt], searchTarget: searchTarget[rowInt])
        //
        //
        //        personInfo?.gender = gender[rowInt]
        //        personInfo?.relationship = relationship[rowInt]
        //        personInfo?.city = city[rowInt]
        //        personInfo?.bodyType = bodyType[rowInt]
        //
        //        personInfo?.searchTarget = searchTarget[rowInt]
        
        //
        
        //        let gender: String
        //
        //        let relationship: String
        //
        //        let city: String
        //
        //        let bodyType: String
        //
        //        let searchTarget: String
        
        //friend = "123"
        //print("目前有選擇的是 \(personInfo) ，\(personInfo?.gender),\(friend)")
    }
    
}

extension EditViewController: UIPickerViewDelegate {}

extension EditViewController: CellDelegate2 {
    
    func editSave(textInput: String, tableViewCell: UITableViewCell) {
        guard let indexPath = editTableView.indexPath(for: tableViewCell) else { return }
        if indexPath.section == 0 {
            print("名字列")
            userSelected[6] = textInput
            print("新版的\(userSelected[6])")
        }else if indexPath.section == 1 {
            print("已經做好 alert pickerView")
        } else if indexPath.section == 2 {
            print("興趣列")
            userSelected[7] = textInput
        } else if indexPath.section == 3 {
            print("國家列")
            userSelected[8] = textInput
        } else if indexPath.section == 4 {
            print("困擾列")
            userSelected[9] = textInput
        } else if indexPath.section == 5 {
            print("嘗試列")
            userSelected[10] = textInput
        } else if indexPath.section == 6 {
            print("自我介紹列")
            userSelected[11] = textInput
        } else {
            print("錯誤")
        }
        
        //editTableView.reloadData() 鍵盤會縮回去 
        
    }
}
//swiftlint:disable all
