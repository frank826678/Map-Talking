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
//swiftlint:disable all
class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
}

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var photos: [PHAsset] = []
    
    //    {
    //        //20181110
    ////        didSet {
    ////            self.photoCollectionView.reloadData()
    ////        }
    //    }
    
    //20181014 照片
    var friendChannel: String = "測試33"
    var friendNewInfo: FriendNewInfo = FriendNewInfo(friendName: "測試11", friendImageUrl: "測試12", friendUID: "測試13", friendChannel: "測試13")
    
    ///取得的资源结果，用了存放的PHAsset
    var assetsFetchResults: PHFetchResult<PHAsset>?
    
    ///缩略图大小
    var assetGridThumbnailSize: CGSize!
    
    /// 带缓存的图片管理对象
    var imageManager: PHCachingImageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        setBackground()
        
        //if PhotoViewController
        
        getNewPhoto ()
        //fetchGallaryResources()
        //getPhotos()
        
        //20181014 照片 OK
        NotificationCenter.default.addObserver(self, selector: #selector (getDataFromChatDetail(_:)), name: .sendPersonalChannel, object: nil)
        //nil 可是資料可以過來 anObject：這是設定是否接收特定的物件的通知。如設定nil，則就是不論哪個物件傳送的通知都收，若有設定物件，則只收這物件所發出的通知。
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assetGridThumbnailSize = CGSize(width: 85, height: 90)
        //根据单元格的尺寸计算我们需要的缩略图大小
        //        let scale = UIScreen.main.scale
        //        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        //        assetGridThumbnailSize = CGSize(width:cellSize.width*scale ,
        //                                        height:cellSize.height*scale)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //fetchGallaryResources()
        //getPhotoStatus()
        
    }
    
    func getNewPhoto () {
        
        //申请权限
        PHPhotoLibrary.requestAuthorization({ (status) in
            if status != .authorized {
                return
            }
            
            //则获取所有资源
            let allPhotosOptions = PHFetchOptions()
            //按照创建时间倒序排列
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                                 ascending: false)]
            //只获取图片
            allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                     PHAssetMediaType.image.rawValue)
            self.assetsFetchResults = PHAsset.fetchAssets(with: PHAssetMediaType.image,
                                                          options: allPhotosOptions)
            
            // 初始化和重置缓存
            self.imageManager = PHCachingImageManager()
            self.resetCachedAssets()
            
            //collection view 重新加载数据
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
        print("***朋友頻道\(friendNewInfo)")
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
        
        
        // 要權限
        //        let result = PHAsset.fetchAssets(with: options)
        //
        //        result.enumerateObjects { (object, _, _) in
        //
        //            self.photos.insert(object, at: 0)
        //        }
    }
    
    func fetchGallaryResources () {
        
        //        let status = PHPhotoLibrary.authorizationStatus()
        //
        //        if status == .denied || status == .restricted {
        //
        //
        //        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .denied || status == .restricted {
            
            print("沒打開權限 photoVC")
            
            let alert = UIAlertController.showAlert(
                title: "照片權限已關閉",
                message: "如要變更權限，請至 設定 > Mapping Talk > 勾選照片讀取。 我們需要存取您的相簿資訊，同意後即可傳送照片給其他使用者。",
                defaultOption: ["確定"]) { (action) in
                    
                    print("按下確認鍵 請前往打開照片權限")
            }
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            PHPhotoLibrary.requestAuthorization { (authStatus) in
                if authStatus == .authorized {
                    let imageAsset = PHAsset.fetchAssets(with: .image, options: nil)
                    for index in 0..<imageAsset.count{
                        
                        // self.photos.insert(object, at: 0)
                        //OK
                        //self.photos.append((imageAsset[index]))
                        self.photos.insert(imageAsset[index], at: 0)
                        
                    }
                    //self.photoCollectionView.reloadData()
                }
                
            }
        }
    }
    
    @IBAction func closeBtnClick(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: .close, object: nil)
    }
    
        func convertNewImageFromAsset(asset: PHAsset) -> UIImage {
    
            var image = UIImage()
            
            let option = PHImageRequestOptions()
            
            option.isSynchronous = true
            
            PHImageManager.default().requestImage(
            for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (result, _) in
                
                guard let result = result else { return }
                
                image = result
            }
            return image

            
//            var image = UIImage()
//
//            let option = PHImageRequestOptions()
//
//            option.isSynchronous = true
//            //targetSize: PHImageManagerMaximumSize,
//            // cell 放的照片為 85,90
//            let size = CGSize(width: 85*2, height: 90*2)
//
//            //let newSize = CGSize(width: PHImageManagerMaximumSize.width * 0.8, height: PHImageManagerMaximumSize.height * 0.8)
//
//            PHImageManager.default().requestImage(
//            for: asset, targetSize: size, contentMode: .aspectFit, options: option) { (result, _) in
//
//                guard let result = result else { return }
//
//                image = result
//            }
//            return image
            
        }
    
    
    //需要換掉 func
    //    func convertImageFromAsset(asset: PHAsset) -> UIImage {
    //
    //        var image = UIImage()
    //
    //        let option = PHImageRequestOptions()
    //
    //        option.isSynchronous = true
    //        //targetSize: PHImageManagerMaximumSize,
    //        // cell 放的照片為 85,90
    //        let size = CGSize(width: 85*2, height: 90*2)
    //
    //        let newSize = CGSize(width: PHImageManagerMaximumSize.width * 0.8, height: PHImageManagerMaximumSize.height * 0.8)
    //
    //        PHImageManager.default().requestImage(
    //        for: asset, targetSize: newSize, contentMode: .aspectFit, options: option) { (result, _) in
    //
    //            guard let result = result else { return }
    //
    //            image = result
    //        }
    //        return image
    //    }
    
    
    //    func getAssetThumbnail(asset: PHAsset, size: CGFloat) -> UIImage {
    //        let retinaScale = UIScreen.main.scale
    //        let retinaSquare = CGSizeMake(size * retinaScale, size * retinaScale)
    //        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
    //        let square = CGRectMake(0, 0, CGFloat(cropSizeLength), CGFloat(cropSizeLength))
    //        let cropRect = CGRectApplyAffineTransform(square, CGAffineTransformMakeScale(1.0/CGFloat(asset.pixelWidth), 1.0/CGFloat(asset.pixelHeight)))
    //
    //        let manager = PHImageManager.defaultManager()
    //        let options = PHImageRequestOptions()
    //        var thumbnail = UIImage()
    //
    //        options.synchronous = true
    //        options.deliveryMode = .HighQualityFormat
    //        options.resizeMode = .Exact
    //        options.normalizedCropRect = cropRect
    //
    //        manager.requestImageForAsset(asset, targetSize: retinaSquare, contentMode: .AspectFit, options: options, resultHandler: {(result, info)->Void in
    //            thumbnail = result!
    //        })
    //        return thumbnail
    //    }
    
    
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
            //获取缩略图
            self.imageManager.requestImage(for: asset, targetSize: assetGridThumbnailSize,
                                           contentMode: PHImageContentMode.aspectFill,
                                           options: nil) { (image, nfo) in
                                            
            cell.photoImage.image = image
                                            
            print(image ?? "")
            }
            
//            (cell.contentView.viewWithTag(1) as! UIImageView).image = image
//            print(image ?? "")

            
            //會跑很多記憶體 掛掉 convertImageFromAsset
            //cell.photoImage.image = convertImageFromAsset(asset: photos[indexPath.row])
            
            return cell
        }
        
         return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let myAsset = self.assetsFetchResults![indexPath.row]
        
//        image: convertImageFromAsset(asset: photos[indexPath.row]),
//        success: { url in
        
//        self.imageManager.requestImage(for: myAsset, targetSize: assetGridThumbnailSize,
//                                       contentMode: PHImageContentMode.aspectFill,
//                                       options: nil) { (image, nfo) in
//
//                                        //cell.photoImage.image = image
//
//                                        self.uploadImagePic(
//                    image: image!,
//                    success: { url in
//
//                        self.sendImage(url: url)
//
//                }, failure: { error in
//
//                    print(error)
//                })
//        }
        
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
