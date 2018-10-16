//
//  ProfileViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/29.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var storyHighlightsTextField: UITextField!
    
//imageArray: [UIImage] = []
    //var iconImageArray: [UIImage] = [UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!]
    //var iconNameArray: [String] = ["個人資料","獲取金幣","設定","聯絡我們"]
    
    //var iconImageArray: [String] = ["new3-pencil-50","new3-cheap-2-50","new3-settings-50-2","new3-new-post-50"]
    
    var iconNameArray: [String] = ["個人資料","聯絡我們"]
    var iconImageArray: [String] = ["new3-pencil-50","new3-new-post-50"]

    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #warning ("TODO: 改成 static 用程式碼控制顏色")
        
        //        self.view.backgroundColor = .clear
        //        self.view.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
        
        setImage()
        
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        profileTableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "Profile")
        
        storyHighlightsTextField.delegate = self
        
        ref = Database.database().reference() //重要 沒有會 nil
        //取消 tableView 虛線
        profileTableView.separatorStyle = UITableViewCell.SeparatorStyle.none


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    func setImage() {
        
        userImage.layer.cornerRadius = 60
        userImage.clipsToBounds = true //沒這行的話 圖片還是方方正正的
        userImage.layer.borderColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
        userImage.layer.borderWidth = 4

        
        //profileTableView.backgroundView?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
        
        guard let userDisplayName = Auth.auth().currentUser?.displayName else { return }
        guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let bigPhotoURL = URL(string: photoSmallURL + "?height=500")
        
        //userImage.kf.setImage(with: URL(string: photoSmallURL))
        userImage.kf.setImage(with: bigPhotoURL)
        userName.text = userDisplayName
    }
    
    // 沒有按鈕 做心情動態的動作 結束編輯後執行
    // 鍵盤推掉後執行
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("輸入的內容為\(storyHighlightsTextField.text)")
        
        if let textFieldInput = storyHighlightsTextField.text {
            
            print("輸入的內容2 為\(textFieldInput)")
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            let userStatus = ["text": textFieldInput]
            
            let childUpdates = ["/location/\(userId)/message": userStatus]
            
            ref.updateChildValues(childUpdates)
        }
        
    }
    
}


extension ProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "Profile", for: indexPath)
            as? ProfileTableViewCell {
            
            //            cell.messageBody.text = message.content
            //            if let photoString = message.senderPhoto {
            //                cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
            //            } else {
            //                cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
            //            }
            
            cell.iconName.text = iconNameArray[indexPath.row]
            
            //cell.iconImage.backgroundColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) // FB message borderColor
            
            //原本
            //cell.iconImage.image = UIImage(named: iconImageArray[indexPath.row])
            //原本 END
            
            cell.iconImage.image = UIImage.setIconTemplate(iconName: iconImageArray[indexPath.row])
            
            
            //cell.selectedBackgroundView?.backgroundColor = UIColor.orange
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            //tableView.separatorStyle = UITableViewCellSeparatorStyleNone
            //            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
            //
            
            return cell
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //configure action when tap cell 1
            print("點了個人資料")
            performSegue(
                withIdentifier: String(describing: EditViewController.self),
                sender: indexPath
            )
            
        } else if indexPath.row == 1 {
            //configure action when tap cell 1
            print("點了聯絡我們")
            performSegue(
                withIdentifier: String(describing: ContactUsViewController.self),
                sender: indexPath
            )
        
        }
        
    }
}

extension ProfileViewController: UITableViewDelegate {}

extension ProfileViewController: UITextFieldDelegate {}

