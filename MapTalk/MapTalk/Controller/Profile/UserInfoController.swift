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
import NotificationBannerSwift

class UserInfoController: UIViewController {
    
    let decoder = JSONDecoder()
    
    @IBOutlet weak var editTableView: UITableView!
    
    var isEdit = false
    
    var userInfo = ["性別", "生日", "感情狀態", "居住地", "體型", "我想尋找"]
    var userSelected =  ["請選擇性別", "請選擇生日", "單身", "台北", "肌肉結實", "短暫浪漫", "請輸入您的暱稱", "吃飯，睡覺，看電影", "台灣/美國/英國/日本", "變胖了想要多運動", "想找人一起玩高空跳傘，環遊世界", "請在此輸入一些想對大家說的話吧～"]
    
    var infoTitle = ["專長 興趣", "喜歡的國家", "自己最近的困擾", "想找人嘗試的事情", "自我介紹"]
    
    let gender = ["男生", "女生", "其他"]
    let relationship = ["不顯示", "秘密", "單身", "穩定交往", "交往中但保有交友空間", "一言難盡"]
    let city = ["基隆市", "台北市", "新北市", "桃園縣", "新竹市", "新竹縣", "苗栗縣", "台中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "台南市", "高雄市", "屏東縣", "台東縣", "花蓮縣", "宜蘭縣", "澎湖縣", "金門縣", "連江縣"]
    
    let bodyType = ["體型纖細", "勻稱", "中等身材", "肌肉結實", "微肉", "豐滿"]
    let searchTarget = ["網上私聊", "短暫浪漫", "固定情人", "開放式關係", "先碰面再說", "談心朋友"]
    
    var selectedSender: Int = 0
    
    var pickerView: UIPickerView!
    var datePicker: UIDatePicker!
    
    var cell: EditUserDataTableViewCell?
    
    let fullScreenSize = UIScreen.main.bounds.size
    // personInfo: PersonalInfo = PersonalInfo()
    var personInfo: PersonalInfo?
    var date: Date?

    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTableView.delegate = self
        editTableView.dataSource = self
        
        
        editTableView.register(UINib(nibName: "EditContentTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditContent")
        
        editTableView.register(UINib(nibName: "PersonalInformationTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "PersonalInformation")
        
        //可 delete 20181111
        editTableView.register(UINib(nibName: "NickNameTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "NickName")
        editTableView.register(UINib(nibName: "EditUserContentTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditUserData")
        
        //可 delete 20181111
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editClicked))
        
        ref = Database.database().reference() //重要 沒有會 nil
        
        downloadUserInfo()
        
        editTableView.allowsSelection = false
        editTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.topItem?.title = "個人資料"
        
    }
    
    @objc func editClicked() {
        print("點擊了按下 Edit 的按鈕")
        isEdit = true
        editTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = "編輯資料"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveClicked))
        
    }
    
    @objc func saveClicked() {
        print("點擊了按下 Save 的按鈕")
        isEdit = false
        editTableView.reloadData()
        self.navigationController?.navigationBar.topItem?.title = "個人資料"
        
        //上傳到 firebase
        uploadUserInfo()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editClicked))
        
    }
    
    func disableAllInput() {
        
    }
    
    func uploadUserInfo() {
        
        print("*********")
        //print(userSelected)
        print("準備上傳的 userSelected 是\(userSelected)")
        
        guard let userId = Auth.auth().currentUser?.uid else {
            BaseNotificationBanner.warningBanner(subtitle: "目前為匿名模式,請使用 Facebook 登入")
            return }
        
        //此時的 userSelected 是 array
        self.ref.child("UserInfo").child(userId).setValue(userSelected) { (error, _) in
            
            if let error = error {
                
                print("Data could not be saved: \(error).")
                
                BaseNotificationBanner.warningBanner(subtitle: "上傳失敗")
            } else {
                
                print("Data saved successfully!")
                BaseNotificationBanner.successBanner(subtitle: "上傳成功")
            }
        }
        
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
        
    }
    
    func downloadUserInfo() {
        
        print("*********")
        //print(userSelected)
        //print("準備上傳的 userSelected 是\(userSelected)")
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        //此時的 userSelected 是 array
        self.ref.child("UserInfo").child(userId).observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            //print("找到的資料是\(snapshot)")
            
            //NSDictionary
            //var userSelected =  ["男","1993-06-06","單身","台北","臃腫","喝酒"]
            
            //這邊可以試著用 codable
            guard let value = snapshot.value as? NSArray else { return }
            print("*********1")
            
            guard let userInfoJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
            
            do {
                let userInfo = try self.decoder.decode(UserInformation.self, from: userInfoJSONData)
                
                //self.userInformation = userInfo
                
            } catch {
                print(error)
            }
            //代辦
            //print(value)
            
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

extension UserInfoController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //        if section == 0 || section ==  1 || section ==  3 {
        
        if section == 1 {
            return 6
        } else if section == 0 {
            return 1
        } else {
            return 5
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 0.5)
        
        //轉換 title
        // swiftlint:disable force_cast
        let header = view as! UITableViewHeaderFooterView
        // swiftlint:enable force_cast
        
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont(name: "Futura", size: 19)!
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 50
    }
    
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        
        var title = "暱稱"
        
        if section == 0 {
            
            title = "暱稱"
        } else if section == 1 {
            
            title = "基本資料"
        } else if section == 2 {
            
            title = "想和大家分享的事"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "PersonalInformation", for: indexPath)
                as? PersonalInformationTableViewCell {
                
                if isEdit == true {
                    cell.contentTextView.isEditable = true
                } else {
                    cell.contentTextView.isEditable = false
                }
                
                cell.titleLabel.isHidden = true
                cell.contentTextViewTopConstraint.constant = -30
                cell.contentTextView.text = userSelected[6]
                
                cell.delegate = self
                
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
                
                cell.userInfoButton.addTarget(self, action: #selector(userInfoButtonClicked(sender:)), for: .touchUpInside) //要加 .
                
                cell.userInfoButton.setTitle(userSelected[indexPath.row], for: .normal)
                
                cell.userInfoButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
                
                cell.userInfoLabel.text = userInfo[indexPath.row]
                
                return cell
            }
            
        case 2:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "PersonalInformation", for: indexPath)
                as? PersonalInformationTableViewCell {
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                if isEdit == true {
                    cell.contentTextView.isEditable = true
                } else {
                    cell.contentTextView.isEditable = false
                }
                
                cell.titleLabel.isHidden = false
                cell.contentTextViewTopConstraint.constant = 5
                cell.titleLabel.text = infoTitle[indexPath.row]
                
                cell.contentTextView.text = userSelected[indexPath.row + 7 ]
                
                cell.delegate = self
                
                return cell
            }
            
        default:
            
            return  UITableViewCell()
        }
        
        return  UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 || indexPath.section == 0 {
            return 60
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension UserInfoController: UITableViewDelegate {}

extension UserInfoController: UIPickerViewDataSource {
    
    @objc func userInfoButtonClicked(sender: UIButton) {
        
        let buttonRow = sender.tag
        selectedSender = buttonRow
        
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
            
            let pickerDate = Date.formatDate(date: self.datePicker.date)
            
            self.userSelected[1] = pickerDate
            
            print("轉換過的時間為\(pickerDate)")
            //要有 reload data 此時 model 已經改變
            self.editTableView.reloadData()
            
        })
        
        alertController.addAction(UIAlertAction(
            title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        
        alertController.view.addSubview(datePicker)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func selectDatePick(_ sender: Any) {
        //初始化 UIPickerView
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        
        let alertController: UIAlertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default) {
            (_) -> Void in
            
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
            
        })
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel, handler: nil))
        
        
        //350
        pickerView.frame = CGRect(x: -10, y: 0, width: fullScreenSize.width, height: 250)
        alertController.view.addSubview(pickerView)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //設定選擇框的列數 繼承 UIPickerViewDataSource 協議
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
    }
    
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
    }
}

extension UserInfoController: UIPickerViewDelegate {}

extension UserInfoController: PersonalInformationCellDelegate {
    
    //    func textCount(textInput: String, tableViewCell: UITableViewCell) {
    //        print("textcount")
    //    }
    
    func editSave(textInput: String, tableViewCell: UITableViewCell) {
        
        guard let indexPath = editTableView.indexPath(for: tableViewCell) else { return }
        
        if textInput.count > 40 {
            //print("超過 20 字 ＊＊＊")
            BaseNotificationBanner.warningBanner(subtitle: "請勿超過 40 個字")
        }
        
        if indexPath.section == 0 {
            print("名字列")
            userSelected[6] = textInput
            print("新版的\(userSelected[6])")
        } else if indexPath.section == 1 {
            print("已經做好 alert pickerView")
        } else if indexPath.section == 2 {
            print("想和大家分享的事情列表")
            
            if indexPath.row == 0 {
                print("興趣列")
                userSelected[7] = textInput
            } else if indexPath.row == 1 {
                print("國家列")
                userSelected[8] = textInput
            } else if indexPath.row == 2 {
                print("困擾列")
                userSelected[9] = textInput
            } else if indexPath.row == 3 {
                print("嘗試列")
                userSelected[10] = textInput
            } else if indexPath.row == 4 {
                print("自我介紹列")
                userSelected[11] = textInput
            }
            
        } else { print("編輯個人資料錯誤") }
    }
}
