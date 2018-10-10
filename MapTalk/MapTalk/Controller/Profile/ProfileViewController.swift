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
    
    var iconNameArray: [String] = ["編輯資料","獲取金幣","設定","聯絡我們"]
    //imageArray: [UIImage] = []
    //var iconImageArray: [UIImage] = [UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!]

    var iconImageArray: [String] = ["new3-pencil-50","new3-cheap-2-50","new3-settings-50-2","new3-new-post-50"]
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }

    
    func setImage() {
        
        userImage.layer.cornerRadius = 60
        userImage.clipsToBounds = true //沒這行的話 圖片還是方方正正的
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
    
//    @IBAction func changeMessage(_ sender: UIButton) {
//
//        let editAlert = UIAlertController(title: "Message:", message: nil, preferredStyle: .alert)
//
//        editAlert.addTextField()
//
//        let submitAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
//
//            if let alertTextField = editAlert.textFields?.first?.text {
//
//                print("alertTextField: \(alertTextField)")
//
//                guard let userId = Auth.auth().currentUser?.uid else { return }
//
//                let userStatus = ["text": alertTextField]
//
//                let childUpdates = ["/location/\(userId)/message": userStatus]
//
//                self.ref.updateChildValues(childUpdates)
//            }
//        })
//
//        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
//
//        editAlert.addAction(submitAction)
//        editAlert.addAction(cancel)
//
//        self.present(editAlert, animated: true)
//    }
    
    /*
    func setButtonTemplateImage() {
        var templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
        filterButton.setImage(templateImage, for: .normal)
        
        templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
        filterButton.setImage(templateImage, for: .selected)
        
        setButtonColor(with: #colorLiteral(red: 0.137254902, green: 0.462745098, blue: 0.8980392157, alpha: 1)) //顏色已經挑選完成 是根據定位的按鈕的藍色
        
    }
    
    func setButtonColor(with color: UIColor) {
        //filterButton.imageView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //按鈕的圖案的背景 顏色已經挑選完成 是根據定位的按鈕的白色
        
        filterButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // 按鈕的背景
        
        filterButton.imageView?.tintColor = color
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
 
 */
}


extension ProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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

            
            cell.selectedBackgroundView?.backgroundColor = UIColor.orange
            
//            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
//
            
            return cell
        }
        
        return UITableViewCell()

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //configure action when tap cell 1
            print("點了編輯資料")
            performSegue(
                withIdentifier: String(describing: EditViewController.self),
                sender: indexPath
            )

        } else if indexPath.row == 1 {
            //configure action when tap cell 1
             print("點了獲取金幣")
            performSegue(
                withIdentifier: String(describing: ADCoinViewController.self),
                sender: indexPath
            )

        } else if indexPath.row == 2 {
            //configure action when tap cell 1
            print("點了設定")
            performSegue(
                withIdentifier: String(describing: SettingViewController.self),
                sender: indexPath
            )


        } else if indexPath.row == 3 {
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

