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
    
    var friendChannel: String = "頻道"
    var friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: "名字", friendImageUrl: "URL", friendUID: "UID", friendChannel: "Channel")
    
    ///取得的資源结果，用了存放的PHAsset
    var assetsFetchResults: PHFetchResult<PHAsset>?
    
    ///縮圖大小
    var assetGridThumbnailSize: CGSize!
    
    /// 带緩存的圖片管理對象
    var imageManager: PHCachingImageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        setBackground()
        
        getNewPhoto ()

        NotificationCenter.default.addObserver(self, selector: #selector (getDataFromChatDetail(_:)), name: .sendPersonalChannel, object: nil)

        //縮圖大小
        assetGridThumbnailSize = CGSize(width: 85, height: 90)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        getPhotoStatus()
    }
    
    func getNewPhoto () {
        
        //確認權限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            //獲取所有资源
            let allPhotosOptions = PHFetchOptions()
            //直接按照時間倒序排列
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
            //只獲取照片
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                     PHAssetMediaType.image.rawValue)
            self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                          options: allPhotosOptions)
            
            // 初始化和重置
            self.imageManager = PHCachingImageManager()
            self.resetCachedAssets()
            
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
            }
        })
        
    }
    
    //重置缓存
    func resetCachedAssets(){
        self.imageManager.stopCachingImagesForAllAssets()
    }
    
    func getPhotoStatus() {
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            
            print("沒打開權限 photoVC")
            
            let alert = UIAlertController.showAlert(
                title: "照片權限已關閉",
                message: "如要變更權限，請至 設定 > Mapping Talk > 允許照片讀取。 我們需要存取您的相簿資訊，同意後即可傳送照片給其他使用者。",
                defaultOption: ["確定"]) { (action) in
                    
                    print("按下確認鍵 請前往打開照片權限")
                    
                    DispatchQueue.main.async {
                        
                        if let url = URL(string:UIApplication.openSettingsURLString) {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                    }
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //20181014 照片
    @objc func getDataFromChatDetail(_ noti: Notification) {
        //20181110
        //self.photoCollectionView.reloadData()
        
        guard let friendChannelFromChatDetail = noti.object as? FriendNewInfo else {
            print("no channel")
            return  }
        
        friendNewInfo = friendChannelFromChatDetail
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
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: .close, object: nil)
    }
    
        func convertNewImageFromAsset(asset: PHAsset) -> UIImage {
    
            var image = UIImage()
            
            let option = PHImageRequestOptions()
            
            option.isSynchronous = true
            
            PHImageManager.default().requestImage(
            for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: option) { (result, _) in
                
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
        
        //壓縮照片 0.2 0.8
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
        
        // swiftlint:disable identifier_name
        let ref = Database.database().reference()
        // swiftlint:enable identifier_name
        
        let channel = friendNewInfo.friendChannel
        guard let messageKey = ref.child("chatroom").child("PersonalChannel").child(channel).childByAutoId().key else { return }

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
        
        //return photos.count
        return self.assetsFetchResults?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photoCell", for: indexPath)
            as? PhotoCollectionViewCell else {
                
                return UICollectionViewCell()
        }
        
        if let asset = self.assetsFetchResults?[indexPath.row] {
            //取得縮圖
            self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                           contentMode: PHImageContentMode.aspectFill,
                                           options: nil) { (image, info) in
                                            
            cell.photoImage.image = image
            
            }
            
            return cell
        }
        
         return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let myAsset = assetsFetchResults?[indexPath.row] else { return }
        
        uploadImagePic(
            image: convertNewImageFromAsset(asset: myAsset),
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
