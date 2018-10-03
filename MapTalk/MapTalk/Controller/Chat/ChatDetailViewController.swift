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
    //
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name

    var userName = ""
    var userEmail = ""
    var messages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        registerCells()
        
        chatDetailTableView.delegate = self
        chatDetailTableView.dataSource = self
        
        ref = Database.database().reference()

        setBackground()
        
        getMessages()
        
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
        
        setupChat(friendUserId: friendUserId)
        
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
    
    //NEW
    private func setupData(friendName: String) {
        
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
        
        //尋找 channel 是否已經存在
        ref.child("chatroom").child("PersonalChannel").child(myselfIdAndFriendId).observeSingleEvent(of: .value) { (snapshot) in
            
            // guard let 要做的事情要寫在 return 的前面
            guard let value = snapshot.value as? NSDictionary else {
                
                print("找不到原始資料，創建新頻道")
               
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
    
    func getPersonalMessages() {
        
        let chatroomKey = "PersonalChannel"
        
        ref.child("chatroom").child(chatroomKey)
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
    
    func getMessages() {
        
        let chatroomKey = "publicChannel"
        
        ref.child("chatroom").child(chatroomKey)
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
    
    @IBAction func send(_ sender: Any) {
        
        guard let text = messageTxt.text else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let createdTime = Date().millisecondsSince1970
        
        let chatroomKey = "publicChannel"
        
        let messageKey = ref.child(chatroomKey).childByAutoId().key
        
        ref.child("chatroom").child(chatroomKey).child(messageKey)
            .setValue([
                "content": text,
                "senderId": userId,
                "senderName": userName,
                "senderPhoto": userImage,
                "time": createdTime
            ]) { (error, _) in
                
                if let error = error {
                    
                    print("Data could not be saved: \(error).")
                    
                } else {
                    
                    print("Data saved successfully!")
                    
                    self.messageTxt.text = ""
                }
        }
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        
        photoSelectorShowing()
    }
    
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
