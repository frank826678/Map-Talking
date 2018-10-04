//
//  ChatViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/26.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

// 模擬機測試會有一句話顯示兩次的問題 要做外面可以顯示對方的最後一筆資料 並且可以按照順序排

class ChatViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    //    var userName = ""
    //    var userEmail = ""
    var messages: [Message] = []
    var friendsList: [String] = []
    var friendInfo: [FriendInfo] = []
    
//    struct freindData {
//        let info: FriendInfo
//        let message:  Message
//    }
//
//    var friendDataArray: [freindData]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
        
        // Do any additional setup after loading the view.
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "Chat")
        //讀取好友清單
        ref = Database.database().reference() //重要 沒有會 nil
        
        getFriendList()
        //getFriendLastMessage()
        
        //simpleQueues()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //getFriendLastMessage()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case String(describing: ChatDetailViewController.self):
            
            guard let detailController =  segue.destination as? ChatDetailViewController,
                let indexPath = sender as? IndexPath else {
                    
                    return
            }
            
            // 對方 controller 的資料
            // detailController.article = datas[indexPath.row]
            
        default:
            
            return super.prepare(for: segue, sender: sender)
        }
    }
    
    func setImage() {
        
        userImage.layer.cornerRadius = 25
        userImage.clipsToBounds = true
        
    }
    
    //    func getFriendList() {
    //
    //
    //
    //    }
    
    func simpleQueues() {
        
//        let queue = DispatchQueue(label: "123")
//        queue.sync {
//            getFriendList()
//        }
//
//        getFriendLastMessage()
        
    }
    
    func getFriendList() {
        
        //找出所有好友列表 剛進本業就要做的事情
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("UserData").child(myselfId).child("FriendsList").observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            //            print("以下為value資料")
            //            print(value)
            //            print("value資料結束")
            let allkeyCount = value.allKeys.count
            print(allkeyCount)
            
            print("------")
            //let key = value?.allKeys.first
            for index in 0 ..< allkeyCount {
                //guard let member = value[value.allKeys[0]] as? NSDictionary else { return }
                //guard let member = value[value.allKeys[index]] as? NSDictionary else { return }
                
                guard let allFriends = value.allKeys[index] as? String else { return }
                
                print("以下為allFriends資料")
                
                print(allFriends)
                
                self.friendsList.append(allFriends)
                //這裡有每個朋友的名字 這時候去請求
                print("allFriends資料結束")
                self.getFriendLastMessage(friendId: allFriends)
            
            }
            
            print("----------------")
            print("所有 朋友資料 資料 \(self.friendsList)")
            
            
        })
        
    }
    
    //待修
    func getFriendLastMessage(friendId: String) {
        
        var channel :String = "Nothing"
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        //            for index in 0 ... friendsList.count-1 {
        //
        //                let friendId = friendsList[index]
        //
        //                if myselfId > friendId {
        //                    channel = "\(myselfId)_\(friendId)"
        //                } else {
        //                    channel = "\(friendId)_\(myselfId)"
        //                }
        
        
            
            let friendId = friendId
            
            if myselfId > friendId {
                channel = "\(myselfId)_\(friendId)"
            } else {
                channel = "\(friendId)_\(myselfId)"
            }
            
            //channel = "sgo1OooTVwbZ2PinrIY81YXN8Gl2_H6jIdMSaFydwRkuZGMGPneHZ3xf1"
        //        self.ref.child("UserData").queryEqual(toValue: friendId).observeSingleEvent(of: .value, with: { (snapshot)
        
        self.ref.child("UserData/\(friendId)").observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            print("找到的資料是\(snapshot)")
            
//            let a = snapshot.value as! NSDictionary
//            print("奇怪東西\(a)")
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            guard let friendName = value["FBName"] as? String else { return }
    
            guard let friendMmageUrl = value["FBPhotoSmallURL"] as? String  else { return }
            
            let friendInfo = FriendInfo(friendName: friendName, friendImageUrl: friendMmageUrl)
            
            self.friendInfo.append(friendInfo)
            
            print("＊＊＊＊朋友的資料")
            print(self.friendInfo)
             self.chatTableView.reloadData()
            
        })
            
            //可以找到最後一筆資料
            ref.child("chatroom").child("PersonalChannel").child(channel).queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
                
                //用 UID 去找是誰 到 UserData 去找
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                guard let senderId = value["senderId"] as? String else { return }
                
                guard let senderName = value["senderName"] as? String else { return }
                
                guard let time = value["time"] as? Int else { return }
                
                let content = value["content"] as? String
                
                let senderPhoto = value["senderPhoto"] as? String
                
                let imageUrl = value["imageUrl"] as? String
                
                let message = Message(
                    content: content,
                    senderId: senderId,
                    senderName: senderName,
                    senderPhoto: senderPhoto,
                    time: time,
                    imageUrl: imageUrl
                )
                
                self.messages.append(message)
                
                print("_____")
                print(self.messages)
                
                self.chatTableView.reloadData()
                
                //                        self.chatTableView.beginUpdates()
                //
                //                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                //
                //                        self.chatTableView.insertRows(at: [indexPath], with: .automatic)
                //
                //                        self.chatTableView.endUpdates()
                //
                //                        self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            
        }
        
        //let chatroomKey = "publicChannel"
        //每個 channel 都要讀取 讀最後一筆
        
        
    
}
    
    //    func setButtonTemplateImage() {
    //        var templateImage = #imageLiteral(resourceName: "btn_play").withRenderingMode(.alwaysTemplate)
    //        playButton.setImage(templateImage, for: .normal)
    //
    //        templateImage = #imageLiteral(resourceName: "btn_stop").withRenderingMode(.alwaysTemplate)
    //        playButton.setImage(templateImage, for: .selected)
    //
    //    }

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "Chat", for: indexPath)
            as? ChatTableViewCell {
            
            //            cell.messageBody.text = message.content
            //            if let photoString = message.senderPhoto {
            //                cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
            //            } else {
            //                cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
            //            }
            
            //cell.userMessage.text = "要吃飯了沒？？？"
            cell.userMessage.text = messages[indexPath.row].content
            cell.userName.text = friendInfo[indexPath.row].friendName
            
            if let photoString = friendInfo[indexPath.row].friendImageUrl
            {
                cell.userImage.kf.setImage(with: URL(string: photoString))
            } else {
                cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
            }

            
//            @IBOutlet weak var userImage: UIImageView!
//
//            @IBOutlet weak var userName: UILabel!
//
//            @IBOutlet weak var userMessage: UILabel!
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //
    //        return 150.0
    //    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(
            withIdentifier: String(describing: ChatDetailViewController.self),
            sender: indexPath
        )
    }
    
}
