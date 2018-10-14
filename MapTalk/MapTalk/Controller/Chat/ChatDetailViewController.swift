//
//  ChatDetailViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ChatDetailViewController: UIViewController {
    
    @IBOutlet weak var chatDetailTableView: UITableView!
    
    
    //@IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var messageBorder: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var photoViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoBtn: UIButton!
    
    //新增的
    var friendName: String?
    var friendUserId: String?
    var friendChannel: String = "測試"
    //
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    var userName = ""
    var userEmail = ""
    var messages: [Message] = []
    
    //201801005
    var friendInfo: [FriendInfo] = []
    //20181014
    //var friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: "測試11", friendImageUrl: "測試12", friendUID: "測試13", friendChannel: "測試13")
    //20181014 END

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        registerCells()
        
        chatDetailTableView.delegate = self
        chatDetailTableView.dataSource = self
        
        ref = Database.database().reference()
        
        setBackground()
        //20181014 照片
        addObservers()
        
        
        //getMessages()
        
        //addObservers()
        
        //NEW
        
        //        guard let friendName = friendName else { return }
        //        guard let friendUserId = friendUserId else { return }
        //
        //        setupData(friendName: friendName)
        //        setupChat(friendUserId: friendUserId)
        
        //END
        
        guard let friendUserId = friendUserId else {
            
            return
            
        }
        
        setChannel(friendUserId: friendUserId) //new
        
        setupChat(friendUserId: friendUserId) //1
        getPersonalMessages(channel: friendChannel)
        
        //20181005
        getFriendInfo(friendUserId: friendUserId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        guard let friendName = friendName else {
        //
        //            return
        //
        //        }
        
        //        guard let friendUserId = friendUserId else {
        //
        //            return
        //
        //        }
        //
        //        //setupData(friendName: friendName)
        //        setupChat(friendUserId: friendUserId)
        
    }
    
    // MARK: - Action
    
    @IBAction func didTouchBackButton() {
        
        dismiss(animated: true
            , completion: nil)
        //        self.navigationController?.popViewController(animated: true)
    }
    
    func registerCells() {
        
        chatDetailTableView.register(UINib(nibName: "ChatDetailTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: "Chat")
        
        chatDetailTableView.register(UINib(nibName: "ChatOwnerTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: "ChatOwner")
        
        chatDetailTableView.register(UINib(nibName: "ChatImageTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: "ChatImage")
        
        chatDetailTableView.register(UINib(nibName: "ChatImageOwnerTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: "ChatImageOwner")
    }
    
    //20181014 照片
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(photoSelectorShowing), name: .close, object: nil
        )
    }
    
//    func sendPersonalChannelToPhotoVC() {
//
//        NotificationCenter.default.post(name: .sendPersonalChannel, object: friendChannel)
//
//    }
    
    //NEW
    private func setChannel(friendUserId: String) {
        
        var channel: String?
        
        let friendId = friendUserId
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        if myselfId > friendId {
            channel = "\(myselfId)_\(friendId)"
        } else {
            channel = "\(friendId)_\(myselfId)"
        }
        
        //讓不管名字是啥都可以照順序排序
        
        guard let myselfIdAndFriendId = channel else { return }
        friendChannel = myselfIdAndFriendId
        
        //20181014 照片
        //sendPersonalChannelToPhotoVC()
    }
    
    private func setupChat(friendUserId: String) {
        
        var channel :String?
        
        //如果沒開過聊天室 開一個新的 如果有 讀取上次的資料
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        guard let myselfName = Auth.auth().currentUser?.displayName else { return }
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        
        let createdTime = Date().millisecondsSince1970
        
        let friendId = friendUserId
        
        if myselfId > friendId {
            channel = "\(myselfId)_\(friendId)"
        } else {
            channel = "\(friendId)_\(myselfId)"
        }
        
        //讓不管名字是啥都可以照順序排序
        
        guard let myselfIdAndFriendId = channel else { return }
        friendChannel = myselfIdAndFriendId
        //尋找 channel 是否已經存在
        ref.child("chatroom").child("PersonalChannel").child(myselfIdAndFriendId).observeSingleEvent(of: .value) { (snapshot) in
            
            // guard let 要做的事情要寫在 return 的前面
            guard let value = snapshot.value as? NSDictionary else {
                
                print("找不到原始資料，創建新頻道")
                //送出的第一句話
                let messageKey = self.ref.child("chatroom").child("PersonalChannel").child(myselfIdAndFriendId).childByAutoId().key
                self.ref.child("chatroom").child("PersonalChannel").child(myselfIdAndFriendId).child(messageKey).setValue([
                    "content": " Hello World~~~~ ",
                    "senderId": myselfId,
                    "senderName": myselfName,
                    "senderPhoto": userImage,
                    "time": createdTime
                ]) { (error, _) in
                    
                    if let error = error {
                        
                        print("Data could not be saved: \(error).")
                        
                    } else {
                        
                        print("** 資料存檔成功 Data saved successfully!")
                        
                    }
                }
                
                return //guard let 的 return
                
            }
            
            print("頻道已存在")
            //讀取上次聊天資料
            
            self.getPersonalMessages(channel:  myselfIdAndFriendId)
            
        }
        
    }
    
    
    //END
    
    func setBackground() {
        
        messageBorder.layer.borderWidth = 1
        messageBorder.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        messageBorder.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1) // FB message borderColor
        messageBorder.layer.borderWidth = 1
        
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1) // FB message borderColor
        
        backgroundView.layer.shadowColor = #colorLiteral(red: 0.862745098, green: 0.862745098, blue: 0.862745098, alpha: 1) // FB message borderColor
        backgroundView.layer.shadowOpacity = 1.0
        backgroundView.layer.shadowRadius = 10.0
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0 )
    }
    
    func getPersonalMessages(channel: String) {
        
        //let chatroomKey = "PersonalChannel"
        
        //self.ref.child("chatroom").child("PersonalChannel").child(myselfIdAndFriendId).child(messageKey)
        
        ref.child("chatroom").child("PersonalChannel").child(channel)
            .observe(.childAdded) { (snapshot) in
                
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
                
                self.chatDetailTableView.beginUpdates()
                
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                
                self.chatDetailTableView.insertRows(at: [indexPath], with: .automatic)
                
                self.chatDetailTableView.endUpdates()
                
                self.chatDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //    func getMessages() {
    //
    //        let chatroomKey = "publicChannel"
    //
    //        ref.child("chatroom").child(chatroomKey)
    //            .observe(.childAdded) { (snapshot) in
    //
    //                guard let value = snapshot.value as? NSDictionary else { return }
    //
    //                guard let senderId = value["senderId"] as? String else { return }
    //
    //                guard let senderName = value["senderName"] as? String else { return }
    //
    //                guard let time = value["time"] as? Int else { return }
    //
    //                let content = value["content"] as? String
    //
    //                let senderPhoto = value["senderPhoto"] as? String
    //
    //                let imageUrl = value["imageUrl"] as? String
    //
    //                let message = Message(
    //                    content: content,
    //                    senderId: senderId,
    //                    senderName: senderName,
    //                    senderPhoto: senderPhoto,
    //                    time: time,
    //                    imageUrl: imageUrl
    //                )
    //
    //                self.messages.append(message)
    //
    //                self.chatDetailTableView.beginUpdates()
    //
    //                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
    //
    //                self.chatDetailTableView.insertRows(at: [indexPath], with: .automatic)
    //
    //                self.chatDetailTableView.endUpdates()
    //
    //                self.chatDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    //        }
    //    }
    
    @IBAction func send(_ sender: Any) {
        
        guard let text = messageTxt.text else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let createdTime = Date().millisecondsSince1970
        
        //friendInfo
        
//        guard let friendName = value["FBName"] as? String else { return }
//
//        guard let friendMmageUrl = value["FBPhotoSmallURL"] as? String  else { return }
        
        //20181005 Start
        let friendName = friendInfo[0].friendName
        let friendNameURL =  friendInfo[0].friendImageUrl
        
        //20181005 End
        
        
        //let chatroomKey = "publicChannel"
        
        //        let messageKey = ref.child(chatroomKey).childByAutoId().key
        //
        //        ref.child("chatroom").child(chatroomKey).child(messageKey)
        //            .setValue
        let messageKey = self.ref.child("chatroom").child("PersonalChannel").child(friendChannel).childByAutoId().key
        self.ref.child("chatroom").child("PersonalChannel").child(friendChannel).child(messageKey).setValue([
            "content": text,
            "senderId": userId,
            "senderName": userName,
            "senderPhoto": userImage,
            "time": createdTime,
            "friendName": friendName,
            "friendImageUrl": friendNameURL,
            "friendUID": friendUserId,
        ]) { (error, _) in
            
            if let error = error {
                
                print("Data could not be saved: \(error).")
                
            } else {
                
                print("Data saved successfully!")
                
                self.messageTxt.text = ""
            }
        }
    }
    
    func getFriendInfo(friendUserId: String) {
        
        self.ref.child("UserData/\(friendUserId)").observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            print("找到的資料是\(snapshot)")
            
            //            let a = snapshot.value as! NSDictionary
            //            print("奇怪東西\(a)")
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            guard let friendName = value["FBName"] as? String else { return }
            
            guard let friendImageUrl = value["FBPhotoSmallURL"] as? String  else { return }
            
            let friendInfo = FriendInfo(friendName: friendName, friendImageUrl: friendImageUrl)
            
            self.friendInfo.append(friendInfo)
            //20181014 傳送發送照片的詳細資料 channel 已經變更好的來自全域變數
            var friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: friendName, friendImageUrl: friendImageUrl, friendUID: friendUserId, friendChannel: self.friendChannel)
            
            NotificationCenter.default.post(name: .sendPersonalChannel, object: friendNewInfo)
            
            print("friendNewInfo\(friendNewInfo)")
            
            //試著加入到同一個 array
            //            let friendDataArray = freindData(info: friendInfo, message: nil)
            //            self.friendDataArray.append(<#T##newElement: freindData##freindData#>)
            
            //old 可以
            print("＊＊＊＊朋友的資料")
            print(self.friendInfo)
            
        })
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        
        photoSelectorShowing()
        // 20181014加上傳送頻道
        //self.performSegue(withIdentifier: "GoPhotoVC", sender: friendChannel)
    }
        // 20181014加上傳送頻道
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        // swiftlint:disable force_cast
//        let sendChannel = sender as! String
//        let controller = segue.destination as! PhotoViewController
//
//        // swiftlint:enable force_cast
//
//        controller.friendChannel = sendChannel
//
//    }

    @objc func photoSelectorShowing() {
        
        photoBtn.isSelected = !photoBtn.isSelected
        
        if photoBtn.isSelected {
            
            photoViewConstraint.constant = -5
            
        } else {
            
            photoViewConstraint.constant = -160
        }
        
        UIView.animate(withDuration: 0.7) {
            
            self.view.layoutIfNeeded()
        }
    }
    
}

extension ChatDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        //return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        guard let userId = Auth.auth().currentUser?.uid else { return UITableViewCell() }
        
        switch message.senderId {
            
        case userId:
            
            if let imageUrl = message.imageUrl {
                
                if let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ChatImageOwner", for: indexPath)
                    as? ChatImageOwnerTableViewCell {
                    
                    // cell.messageImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
                    
                    cell.messageImageView.kf.setImage(with: URL(string: imageUrl))
                    
                    //                    if let userImage = annotation?.userImage {
                    //                        imageView.kf.setImage(with: URL(string: userImage))
                    //                    } else {
                    //                        imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    //                    }
                    
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "ChatOwner", for: indexPath)
                as? ChatOwnerTableViewCell {
                
                cell.messageBody.text = message.content
                
                return cell
            }
            
        default:
            
            if let imageUrl = message.imageUrl {
                
                if let cell = tableView.dequeueReusableCell(
                    withIdentifier: "ChatImage", for: indexPath)
                    as? ChatImageTableViewCell {
                    
                    cell.messageImageView.kf.setImage(with: URL(string: imageUrl))
                    
                    if let photoString = message.senderPhoto {
                        cell.userImage.kf.setImage(with: URL(string: photoString))
                    } else {
                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    }
                    
                    
                    //                    cell.messageImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
                    //
                    //                    if let photoString = message.senderPhoto {
                    //                        cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
                    //                    } else {
                    //                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    //                    }
                    
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "Chat", for: indexPath)
                as? ChatDetailTableViewCell {
                
                cell.messageBody.text = message.content
                if let photoString = message.senderPhoto {
                    cell.userImage.kf.setImage(with: URL(string: photoString))
                    //cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
                } else {
                    cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension ChatDetailViewController: UITableViewDelegate {}

extension Date {
    
    var millisecondsSince1970: Int {
        
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
}
