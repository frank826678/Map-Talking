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
import Lottie

class ChatViewController: UIViewController {
    
    let animationView = LOTAnimationView(name: "servishero_loading")
    let decoder = JSONDecoder()
    
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var chatTableView: UITableView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    var friendsList: [String] = []
    var friendInfo: [FriendInfo] = []
    var messages: [Message] = []
    
    var friendDataArray: [FreindData] = []
    //newMessage 儲存所有資訊
    var newMessage: [NewMessage] = []
    
    var myselfUID: String?
    
    @IBOutlet weak var searchBar: UISearchBar!
    var result: [NewMessage] = []
    var searchStatus = false
    //20181020 偵測網路
    
    var reachability = Reachability(hostName: "www.apple.com")
    
    func checkInternetFunction() -> Bool {
        if reachability?.currentReachabilityStatus().rawValue == 0 {
            print("no internet connected.")
            return false
        } else {
            print("internet connected successfully.")
            return true
        }
    }
    
    func downloadData() {
        if checkInternetFunction() == false {
            
            hintLabel.text = "請打開行動網路或 WI-FI"
            hintLabel.isHidden = false
            
        } else {
            
            hintLabel.isHidden = true
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // swiftlint:disable force_cast
        let ramTBC = tabBarController as! TabBarViewController
        // swiftlint:enable force_cast
        
        ramTBC.selectedIndex = 1
        ramTBC.setSelectIndex(from: 0, to: 1)
        
        //偵測網路
        downloadData()
        
        setImage()
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "Chat")
        //讀取好友清單
        ref = Database.database().reference() //重要 沒有會 nil
        
        //取消 tableView 虛線
        chatTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //20181016 searchbar
        searchBar.delegate = self
        //self.result = self.newMessage
        
        hintLabel.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector (getDataFrom(_:)), name: .blockUser, object: nil)
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        myselfUID = myselfId

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        getFriendList()
        
    }
    
        @objc func getDataFrom(_ noti: Notification) {
    
            friendsList.removeAll()
            newMessage.removeAll()
            getFriendList()
            chatTableView.reloadData()
            print("收到封鎖資料")
        }

    func setAniView() {
        
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        animationView.loopAnimation = true
        animationView.animationSpeed = 0.5
        
        view.addSubview(animationView)
        
        animationView.play()
        
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
        
        guard let photoSmallURL =  Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        userImage.kf.setImage(with: URL(string: photoSmallURL))
    }
    
    func display() {
        
        print("Display Data")
        self.chatTableView.reloadData()
        
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
                
                guard let allFriends = value.allKeys[index] as? String else { return }
                
                //封鎖功能 20181022
                let userDefaults = UserDefaults.standard
                
                guard userDefaults.value(forKey: allFriends) == nil else {
                    
                    print("此用戶被封鎖了ChatVC \(allFriends)")
                    continue
                    
                }
                
                print("以下為allFriends資料")
                
                print(allFriends)
                
                //20181019 下面已經直接把值傳入 應該不需要這個 array 了
                self.friendsList.append(allFriends)
                //這裡有每個朋友的 UID , UID 比較重要 為結構的外層第一筆 （名字 這時候去請求
                print("allFriends資料結束")
                
                //OK
                //self.getFriendLastMessage(friendId: allFriends)
                
                //20181006
                
                self.getNewFriendMessage(friendId: allFriends)
            }
            
            print("----------------")
            print("所有 朋友資料 資料 \(self.friendsList)")
            
        })
        
    }
    
    //let chatroomKey = "publicChannel"
    //每個 channel 都要讀取 讀最後一筆
    
    func getNewFriendMessage(friendId: String) {
        
        var channel: String = "Nothing"
        
        guard let myselfId = Auth.auth().currentUser?.uid else { return }
        
        let friendId = friendId
        
        if myselfId > friendId {
            channel = "\(myselfId)_\(friendId)"
        } else {
            channel = "\(friendId)_\(myselfId)"
        }
        ref.child("chatroom").child("PersonalChannel").child(channel).queryOrdered(byChild: "time").queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
            
            //var message: NewMessage
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            //codable 開始
            guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
            
            do {
                let message = try self.decoder.decode(NewMessage.self, from: messageJSONData)
                print("****codable**** start")
                print(message)
                print("****codable**** END")
                //message = messageCodable
                //self.userInformation = userInfo
                if  message.senderId == self.myselfUID {
                    
                    for (index, user) in self.newMessage.enumerated() where user.friendUID == message.friendUID || user.senderId == message.friendUID {
                        
                        //user.friendUID == message.friendUID || user.senderId == message.friendUID  {
                        
                        // || user.friendUID == message.senderId
                        self.newMessage[index].content = message.content
                        self.newMessage[index].time = message.time
                        
                        self.newMessage.sort(by: { (message1, message2) -> Bool in
                            return message1.time > message2.time
                        })
                        
                        self.chatTableView.reloadData()
                        
                        return //跳出 整個 getNewFriendMessage 的 func
                    }
                    
                } else {
                    
                    
                    for (index, user) in self.newMessage.enumerated()
                        where user.friendUID == message.senderId
                            || user.senderId == message.senderId {
                                
                                //user.friendUID == message.senderId
                                self.newMessage[index].content = message.content
                                self.newMessage[index].time = message.time
                                
                                self.newMessage.sort(by: { (message1, message2) -> Bool in
                                    return message1.time > message2.time
                                })
                                
                                self.chatTableView.reloadData()
                                
                                return
                    }
                    
                }
                
                self.newMessage.append(message)
                
                self.result.append(message)
        
                print("_____")
                print(self.newMessage)
                
                
                self.newMessage.sort(by: { (message1, message2) -> Bool in
                    return message1.time > message2.time
                })
                
                self.chatTableView.reloadData()
                
            } catch {
                print(error)
            }
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if checkInternetFunction() == false {
            hintLabel.isHidden = false
            hintLabel.text = "請打開行動網路或 WI-FI"
        } else {
            
            if newMessage.count == 0 {
                print("顯示空值畫面")
                hintLabel.isHidden = false
                hintLabel.text = "到地圖上認識一些新朋友吧！"
                animationView.isHidden = false
                setAniView()
            } else {
                print("已有對話紀錄")
                hintLabel.isHidden = true
                animationView.isHidden = true
            }
        
        }
        
        if searchStatus == false {
            
            return newMessage.count
        } else {
            return result.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "Chat", for: indexPath)
            as? ChatTableViewCell {
            
            if searchStatus == false {
                
                if  newMessage[indexPath.row].senderId == myselfUID {
                    cell.userName.text = newMessage[indexPath.row].friendName
                    
                    if let photoString = newMessage[indexPath.row].friendImageUrl {
                        cell.userImage.kf.setImage(with: URL(string: photoString))
                    } else {
                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    }
                    
                } else {
                    
                    cell.userName.text = newMessage[indexPath.row].senderName
                    
                    if let photoString = newMessage[indexPath.row].senderPhoto {
                        cell.userImage.kf.setImage(with: URL(string: photoString))
                    } else {
                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    }
                    
                }
                
                cell.userMessage.text = newMessage[indexPath.row].content
                let messageTime = Date.formatMessageTime(time: newMessage[indexPath.row].time)
                cell.messageTime.text = messageTime

            } else {
                
                 if  result[indexPath.row].senderId == myselfUID {
                    cell.userName.text = result[indexPath.row].friendName
                    
                    if let photoString = result[indexPath.row].friendImageUrl {
                        cell.userImage.kf.setImage(with: URL(string: photoString))
                    } else {
                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    }
                    
                } else {
                    
                    cell.userName.text = result[indexPath.row].senderName
                    
                    if let photoString = result[indexPath.row].senderPhoto {
                        cell.userImage.kf.setImage(with: URL(string: photoString))
                    } else {
                        cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                    }
                    
                }
                
                cell.userMessage.text = result[indexPath.row].content
                let messageTime = Date.formatMessageTime(time: newMessage[indexPath.row].time)
                cell.messageTime.text = messageTime

            }
            
            //點擊 cell 後 不反灰
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
            
        }
        
        return UITableViewCell()
    }
}

extension ChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let controller = UIStoryboard.chatStoryboard().instantiateViewController(
            withIdentifier: String(describing: ChatDetailViewController.self)
            ) as? ChatDetailViewController else { return }
        if searchStatus == false {
            
            if newMessage[indexPath.row].senderId ==  myselfUID { controller.friendUserId = self.newMessage[indexPath.row].friendUID
            } else {
                controller.friendUserId = self.newMessage[indexPath.row].senderId
            }
        } else {
            if result[indexPath.row].senderId ==  myselfUID { controller.friendUserId = self.result[indexPath.row].friendUID
            } else {
                controller.friendUserId = self.result[indexPath.row].senderId
            }
            
        }
        self.show(controller, sender: nil)
        print("跳頁成功")
        
    }
}

extension ChatViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("[ViewController searchBar] searchText: \(searchText)")
        
        // 没有搜索内容顯示全部内容
        if searchText == "" {
            self.result = self.newMessage
            searchStatus = false
        } else {
            
            self.result = []
            searchStatus = true
            for index in 0...self.newMessage.count-1 {
                
                if  newMessage[index].senderId == myselfUID {
                    guard let friendName = newMessage[index].friendName else { return }
                    let friendResult = friendName.contains(searchText)
                    if friendResult == true {
                        self.result.append(newMessage[index])
                    } else {
                        print("名字不同")
                    }
                    
                    
                } else {
                    
                    let friendName = newMessage[index].senderName
                    let friendResult = friendName.contains(searchText)
                    if friendResult == true {
                        self.result.append(newMessage[index])
                    } else {
                        print("名字不同")
                    }
                    
                }
                
            }
        }
        
       
        self.chatTableView.reloadData()
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        
        print("搜索歷史")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //無搜索內容
        searchBar.text = ""
        self.result = self.newMessage
        self.chatTableView.reloadData()
    }
}
