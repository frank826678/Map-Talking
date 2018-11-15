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
import AVFoundation
import SVProgressHUD
import NotificationBannerSwift

class ChatDetailViewController: UIViewController {
    
    let decoder = JSONDecoder()
    
    @IBOutlet weak var chatDetailTableView: UITableView!
    
    @IBOutlet weak var messageTxt: UITextView!
    
    @IBOutlet weak var messageBorder: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var photoViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoBtn: UIButton!
    
    //20181026 send voice record
    var audioRecorder: AVAudioRecorder!
    var numberOfRecords = 0
    @IBOutlet weak var audioButton: UIButton!
    
    //新增的
    var friendName: String?
    var friendUserId: String?
    var friendChannel: String = "測試"
    
    // swiftlint:disable identifier_name
    var ref: DatabaseReference!
    // swiftlint:enable identifier_name
    
    var userName = ""
    var userEmail = ""
    var messages: [Message] = []
    //20181111
    var friendInfo: FriendInfo?
    
    var bigImageURL: String?
    let fullScreenSize = UIScreen.main.bounds.size
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        registerCells()
        
        chatDetailTableView.delegate = self
        chatDetailTableView.dataSource = self
        
        ref = Database.database().reference()
        
        setBackground()
        
        addObservers()
        
        guard let friendUserId = friendUserId else { return }
        
        setChannel(friendUserId: friendUserId) //new
        
        getPersonalMessages(channel: friendChannel)
        
        getFriendInfo(friendUserId: friendUserId)
        
        //先把傳送語音功能關閉
        audioButton.isHidden = true
                
    }
    
    @IBAction func didTouchBackButton() {
        
        dismiss(animated: true, completion: nil)
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
    
    func addObservers() {
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(photoSelectorShowing), name: .close, object: nil
        )
    }
    
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
        
    }
    
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
        
        ref.child("chatroom").child("PersonalChannel").child(channel)
            .observe(.childAdded) { (snapshot) in
                
                guard let value = snapshot.value as? NSDictionary else { return }
                
                guard let messageJSONData = try? JSONSerialization.data(withJSONObject: value) else { return }
                
                do {
                    let message = try self.decoder.decode(Message.self, from: messageJSONData)
                    
                    self.messages.append(message)
                    
                    self.chatDetailTableView.beginUpdates()
                    
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    
                    self.chatDetailTableView.insertRows(at: [indexPath], with: .automatic)
                    
                    self.chatDetailTableView.endUpdates()
                    
                    self.chatDetailTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                    // reloadData ?
                    
                } catch {
                    print(error)
                }
        }
        
    }
    
    @IBAction func send(_ sender: Any) {
        
        guard let text = messageTxt.text else { return }
        if text != "" {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            guard let userName = Auth.auth().currentUser?.displayName else { return }
            
            guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
            
            let createdTime = Date().millisecondsSince1970
            
            guard let friendName = friendInfo?.friendName else { return }
            guard let friendNameURL =  friendInfo?.friendImageUrl else { return }
            
            guard let messageKey = self.ref.child("chatroom").child("PersonalChannel").child(friendChannel).childByAutoId().key else { return }
            self.ref.child("chatroom").child("PersonalChannel").child(friendChannel).child(messageKey).setValue([
                "content": text,
                "senderId": userId,
                "senderName": userName,
                "senderPhoto": userImage,
                "time": createdTime,
                "friendName": friendName,
                "friendImageUrl": friendNameURL,
                "friendUID": friendUserId
            ]) { (error, _) in
                
                if let error = error {
                    
                    print("Data could not be saved: \(error).")
                    
                } else {
                    
                    print("Data saved successfully!")
                    
                    self.messageTxt.text = ""
                }
            }
        } else {
            BaseNotificationBanner.warningBanner(subtitle: "請輸入內容")
            print("沒輸入東西")
        }
        
    }
    
    func getFriendInfo(friendUserId: String) {
        
        //封鎖功能 20181022
        let userDefaults = UserDefaults.standard
        
        guard userDefaults.value(forKey: friendUserId) == nil else {
            
            print("此用戶被封鎖了ChatDetailVC\(friendUserId)")
            return
            
        }
        
        self.ref.child("UserData/\(friendUserId)").observeSingleEvent(of: .value, with: { (snapshot)
            
            in
            
            //print("找到的資料是\(snapshot)")
            
            guard let value = snapshot.value as? NSDictionary else { return }
            
            guard let friendName = value["FBName"] as? String else { return }
            
            guard let friendImageUrl = value["FBPhotoSmallURL"] as? String  else { return }
            
             self.navigationController?.navigationBar.topItem?.title = "     \(friendName)"
            
            //let friendInfo = FriendInfo(friendName: friendName, friendImageUrl: friendImageUrl)
            
            //20181111
            self.friendInfo = FriendInfo(friendName: friendName, friendImageUrl: friendImageUrl)
            //self.friendInfo.append(friendInfo)
            
            //20181014 傳送發送照片的詳細資料 channel 已經變更好的來自全域變數
            let friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: friendName, friendImageUrl: friendImageUrl, friendUID: friendUserId, friendChannel: self.friendChannel)
            
            NotificationCenter.default.post(name: .sendPersonalChannel, object: friendNewInfo)
            
        })
        
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        //20181110
        //NotificationCenter.default.post(name: .sendPersonalChannel, object: nil)
        
        photoSelectorShowing()
        // 20181014加上傳送頻道
        //self.performSegue(withIdentifier: "GoPhotoVC", sender: friendChannel)
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
    
    //傳送錄音檔開始
    
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func getAudioFileURL() -> URL {
        return getDirectory().appendingPathComponent(".m4a")
    }
    
    @IBAction func sendAudio(_ sender: Any) {
        
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
                    
                    cell.messageImageView.kf.setImage(with: URL(string: imageUrl))
                    cell.messageImageView.isUserInteractionEnabled = true
                    
                    cell.messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
                    
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
                    
                    cell.messageImageView.isUserInteractionEnabled = true
                    cell.messageImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
                    
                    return cell
                }
            }
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "Chat", for: indexPath)
                as? ChatDetailTableViewCell {
                
                cell.messageBody.text = message.content
                if let photoString = message.senderPhoto {
                    cell.userImage.kf.setImage(with: URL(string: photoString))
                    
                } else {
                    cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func prtformZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        self.view.endEditing(true)
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.clear //red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.contentMode = .scaleAspectFill
        
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomout)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.alpha = 0
            blackBackgroundView?.backgroundColor = UIColor.black
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            //點黑色地方也會收回 只會收回黑色 imageView 還在
            //            blackBackgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomout)))
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }) { (_: Bool) in
            }
        }
    }
    
    @objc func handleZoomout(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }) { (_: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    @objc func handleZoomTap(tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            prtformZoomInForStartingImageView(startingImageView: imageView)
            
        }
    }
    
}

extension ChatDetailViewController: UITableViewDelegate {}

extension ChatDetailViewController: AVAudioRecorderDelegate {}

