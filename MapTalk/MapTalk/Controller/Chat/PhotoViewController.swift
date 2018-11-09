//
//  PhotoViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import Photos
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
}

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var photos: [PHAsset] = []
    
    //20181014 照片
    var friendChannel: String = "測試33"
    var friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: "測試11", friendImageUrl: "測試12", friendUID: "測試13", friendChannel: "測試13")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        setBackground()
        
        getPhotos()
        
        //20181014 照片 OK
        NotificationCenter.default.addObserver(self, selector: #selector (getDataFromChatDetail(_:)), name: .sendPersonalChannel, object: nil)
        //nil 可是資料可以過來 anObject：這是設定是否接收特定的物件的通知。如設定nil，則就是不論哪個物件傳送的通知都收，若有設定物件，則只收這物件所發出的通知。
    }
    
    //20181014 照片
    @objc func getDataFromChatDetail(_ noti: Notification) {
        
        guard let friendChannelFromChatDetail = noti.object as? FriendNewInfo else {
                        print("no channel")
                        return  }

        friendNewInfo = friendChannelFromChatDetail
        print("***朋友頻道\(friendNewInfo)")
//        guard let friendChannelFromChatDetail = noti.object as? String else {
//            print("no channel")
//            return  }
//
//        friendChannel = friendChannelFromChatDetail
//
//        print("***朋友頻道\(friendChannel)")

    }
    
    func setBackground() {
        
        backgroundView.layer.cornerRadius = 15.0
        backgroundView.layer.maskedCorners = [
            CACornerMask.layerMinXMinYCorner,
            CACornerMask.layerMaxXMinYCorner
        ]
        
        backgroundView.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        backgroundView.layer.shadowOpacity = 0.5
        backgroundView.layer.shadowRadius = 5.0
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 0 )
        backgroundView.layer.masksToBounds = false
    }
    
    func getPhotos() {
        
        let options = PHFetchOptions()
        options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: true) ]
        
        let result = PHAsset.fetchAssets(with: options)
        
        result.enumerateObjects { (object, _, _) in
            
            self.photos.insert(object, at: 0)
        }
    }
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: .close, object: nil)
    }
    
    func convertImageFromAsset(asset: PHAsset) -> UIImage {
        
        var image = UIImage()
        
        let option = PHImageRequestOptions()
        
        option.isSynchronous = true
        
        PHImageManager.default().requestImage(
        for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (result, _) in
            
            guard let result = result else { return }
            
            image = result
        }
        return image
    }
    
    func uploadImagePic(
        image: UIImage,
        success: @escaping (String) -> Void,
        failure: @escaping (Error) -> Void
        ) {
        
        SVProgressHUD.show()
        
        let storageRef = Storage.storage().reference()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let fileName = String(Date().millisecondsSince1970)
        
        //壓縮照片
        // 舊參數guard let data = UIImageJPEGRepresentation(image, 0.1) as NSData? else { return }
        
        guard let data = image.jpegData(compressionQuality: 0.2) else { return }

        print("成功壓縮照片")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.child(userId).child(fileName).putData(data as Data, metadata: metaData) { (_, error) in
            
            if let error = error {
                
                failure(error)
                
                return
                
            } else {
                
                storageRef.child(userId).child(fileName).downloadURL(completion: { (url, error) in
                    
                    if let error = error {
                        
                        failure(error)
                    }
                    
                    if let url = url {
                        
                        success(url.absoluteString)
                        
                    }
                })
            }
        }
    }
    
    func sendImage(url: String) {
        
        let imageUrl = url
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let userName = Auth.auth().currentUser?.displayName else { return }
        
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        
        let createdTime = Date().millisecondsSince1970
        
        //let chatroomKey = "publicChannel"
       
        print("***朋友頻道\(friendChannel)")
        
        // swiftlint:disable identifier_name
        let ref = Database.database().reference()
        // swiftlint:enable identifier_name
        
        let channel = friendNewInfo.friendChannel
        guard let messageKey = ref.child("chatroom").child("PersonalChannel").child(channel).childByAutoId().key else { return }
        
       // let messageKey = ref.child(chatroomKey).childByAutoId().key
        
        ref.child("chatroom").child("PersonalChannel").child(channel).child(messageKey).setValue([
                "imageUrl": imageUrl,
                "senderId": userId,
                "senderName": userName,
                "senderPhoto": userImage,
                "time": createdTime,
                "content": "傳送了一張照片",
                "friendName": friendNewInfo.friendName,
                "friendImageUrl": friendNewInfo.friendImageUrl,
                "friendUID": friendNewInfo.friendUID
            ]) { (error, _) in
                
                if let error = error {
                    
                    print("Data could not be saved: \(error).")
                    
                } else {
                    
                    print("Data saved successfully!")
                    SVProgressHUD.dismiss()
                }
        }
    }
    
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photoCell", for: indexPath)
            as? PhotoCollectionViewCell else {
                
                return UICollectionViewCell()
        }
        
        cell.photoImage.image = convertImageFromAsset(asset: photos[indexPath.row])
      
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        uploadImagePic(
            image: convertImageFromAsset(asset: photos[indexPath.row]),
            success: { url in
                
                self.sendImage(url: url)
                
        }, failure: { error in
            
            print(error)
        })
        
        NotificationCenter.default.post(name: .close, object: nil)
    }
    
}

extension PhotoViewController: UICollectionViewDelegate {}

extension NSNotification.Name {
    
    static let close = NSNotification.Name("CLOSE_PHOTO_SELECTOR")
    static let sendPersonalChannel = NSNotification.Name("SEND_PERSONAL_CHANNEL")

}
