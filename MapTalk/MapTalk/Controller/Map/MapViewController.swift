//
//  MapViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/20.
//  Copyright © 2018 Frank. All rights reserved.
//

//import UIKit
//import GoogleMaps
//
//class MapViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//    }
//
//
//
//}

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth
import Kingfisher


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var location: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var refference: DatabaseReference!
    var userName: String!
    var locations: [Locations] = []
    var trackLocation: [String: Any] = [ : ]
    
    var userAnnotation: UserAnnotation?
    
    var selfLocation: Locations?
    
    var navigationUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //        map.showsUserLocation = true
        
        refference = Database.database().reference()
        
        if let name = Auth.auth().currentUser?.displayName {
            userName = name
        } else {
            userName = "User"
        }
        userName = Auth.auth().currentUser?.displayName
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        dataBaseLocation()
        
        setButtonTemplateImage()
        setIconCorner()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func dataBaseLocation() {
        refference.child("location").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let location = value["location"] as? NSDictionary else { return }
            guard let latitude = location["lat"] as? Double else { return }
            guard let longitude = location["lon"] as? Double else { return }
            guard let userName = location["userName"] as? String else { return }
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            
            let userlocations = Locations(latitude: latitude, longitude: longitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput)
            
            self.mapView.addAnnotation(userlocations.userAnnotation)
            
            self.locations.append(userlocations)
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            if userlocations.id == userId {
                
                self.selfLocation = userlocations
                
                self.mapView.setRegion(
                    MKCoordinateRegion(
                        center: userlocations.userAnnotation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.1,
                            longitudeDelta: 0.1
                        )
                    ),
                    animated: false
                )
            }
            
            self.dataBaseTrack()
        }
    }
    
    func dataBaseTrack() {
        refference.child("location").observe(.childChanged) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let location = value["location"] as? NSDictionary else { return }
            guard let latitude = location["lat"] as? Double else { return }
            guard let longtitude = location["lon"] as? Double else { return }
            
            guard let userName = location["userName"] as? String else { return }
            
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            
            let userLocations = Locations(latitude: latitude, longitude: longtitude, name: userName, userImage: userImage, id: snapshot.key, message: messageInput)
            
            for (index, user) in self.locations.enumerated() where user.id == userLocations.id {
                
                self.locations[index].latitude = userLocations.latitude
                
                self.locations[index].longitude = userLocations.longitude
                
                self.locations[index].message = userLocations.message
                
                for index in 0..<self.locations.count {
                    self.mapView.removeAnnotation(self.locations[index].userAnnotation)
                    self.mapView.addAnnotation(self.locations[index].userAnnotation)
                }
                
                return
            }
            
            self.mapView.addAnnotation(userLocations.userAnnotation)
            
            
            self.locations.append(userLocations)
        }
    }
    
    @IBAction func locationButtonClick(_ sender: UIButton) {
        
        if let location = selfLocation {
            self.mapView.setRegion(
                MKCoordinateRegion(
                    center: location.userAnnotation.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.1,
                        longitudeDelta: 0.1
                    )
                ),
                animated: false
            )
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            //            let region = MKCoordinateRegion(center: center,
            //                                            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
            
            saveSelfLocation(latitude: center.latitude, longitude: center.longitude)
        }
        
    }
    
    //新寫法 不會有白色的點擋住 但是點擊後不會觸發任何事件 不能做任何動作
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annotationView == nil {
            // 執行下面這行 why 會 nil?
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }

        // if is 在幹嘛？
        if annotation is MKUserLocation {
            // 直接跳開
            return nil
        }
        //新增 20181001
        let userAnnotation = annotation as? UserAnnotation
        
        //新增 20181002
        annotationView?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        //annotationView?.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        

        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFill

        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)

        if let userImage = userAnnotation?.userImage {
            imageView.kf.setImage(with: URL(string: userImage))
        } else {
            imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
        }

        //設定照片圓角
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.borderColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
        imageView.layer.borderWidth = 4

        //增加三角形圖案
        let triangle = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10)) // 50, 10
        triangle.text = "▾"
        triangle.font = UIFont.systemFont(ofSize: 24) //24
        //triangle.textColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
        triangle.textColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)

        triangle.textAlignment = .center

        //annotationView?.image = imageView.image
        annotationView?.addSubview(imageView)
        annotationView?.addSubview(triangle)

        //annotationView?.annotation?.subtitle = "Test"

        let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 105, height: 30))
        annotationLabel.numberOfLines = 3
        annotationLabel.textAlignment = .center
        annotationLabel.font = UIFont(name: "Rockwell", size: 12)

        if let message = userAnnotation?.message {
            annotationLabel.text = message
        } else {
            annotationLabel.text = "媽 我上地圖了 Ya"
        }

        annotationLabel.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        annotationLabel.layer.cornerRadius = 15
        annotationLabel.clipsToBounds = true

        annotationView?.addSubview(annotationLabel)

        let annotationName = UILabel(frame: CGRect(x: -20, y: 65, width: 95, height: 25))
        annotationName.numberOfLines = 3
        annotationName.textAlignment = .center
        annotationName.font = UIFont(name: "Rockwell", size: 12)

        if let name = userAnnotation?.name {
            annotationName.text = name
            annotationName.isHidden = false
        } else {
            annotationName.isHidden = true
        }

        annotationName.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.631372549, blue: 0.7921568627, alpha: 1)
        annotationName.textColor = .white

        annotationName.layer.cornerRadius = 15
        annotationName.clipsToBounds = true
        annotationView?.addSubview(annotationName)

        // 下面這行改了 白點消失 變成純愛心
        //annotationView?.image = #imageLiteral(resourceName: "btn_like_normal")

        //有這行也不 call didselect
        //userAnnotation?.title = userAnnotation?.name

        //https://stackoverflow.com/questions/26713582/didselectannotationview-not-called

//        annotationView?.canShowCallout = true

        //annotationView?.annotation?.title = userAnnotation?.name
        return annotationView
    }
    
    //原本寫法 有白色的點 會擋住 但是可以跑 didselect 點擊後有事件會發生
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//        let annotation = annotation as? UserAnnotation
//
//        if annotation is MKUserLocation {
//            return nil
//        } else {
//            let pinIdent = "Pin"
//            var pinView: MKMarkerAnnotationView
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(
//                withIdentifier: pinIdent) as? MKMarkerAnnotationView {
//                dequeuedView.annotation = annotation
//                pinView = dequeuedView
//                // 這邊不執行
//
//            } else {
//                // 執行這邊
//                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: pinIdent)
//            }
//
//            //此行為改 map 的 bubble 顏色 試著把 bubble 拿掉
//            //pinView.markerTintColor = .clear
//
//            //pinView.markerTintColor = .groupTableViewBackground
//
//            pinView.markerTintColor = .clear
//            pinView.glyphTintColor = .orange
//
//            let imageView = UIImageView()
//
//            imageView.contentMode = .scaleAspectFill
//
//            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//
//            //將 URL 轉換成圖片
////            if let image = annotation?.userImage {
////                imageView.sd_setImage(with: URL(string: image), completed: nil)
////            } else {
////                imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
////            }
//
//            if let userImage = annotation?.userImage {
//                imageView.kf.setImage(with: URL(string: userImage))
//            } else {
//                imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
//            }
//
//
//            //設定照片圓角
//            imageView.clipsToBounds = true
//            imageView.layer.cornerRadius = 25
//            imageView.layer.borderColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
//            imageView.layer.borderWidth = 4
//
//            //增加三角形圖案
//            let triangle = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10)) // 50, 10
//            triangle.text = "▾"
//            triangle.font = UIFont.systemFont(ofSize: 24) //24
//            //triangle.textColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
//            triangle.textColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
//
//            triangle.textAlignment = .center
//
//            pinView.addSubview(imageView)
//            pinView.addSubview(triangle)
//
//
//            let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 105, height: 30))
//            annotationLabel.numberOfLines = 3
//            annotationLabel.textAlignment = .center
//            annotationLabel.font = UIFont(name: "Rockwell", size: 12)
//
//            //annotationLabel.text = "媽 我上地圖了 Ya"
//
//            if let message = annotation?.message {
//                annotationLabel.text = message
//            } else {
//                annotationLabel.text = "媽 我上地圖了 Ya"
//            }
//
//            annotationLabel.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
//            annotationLabel.layer.cornerRadius = 15
//            annotationLabel.clipsToBounds = true
//
//            pinView.addSubview(annotationLabel)
//
//            let annotationName = UILabel(frame: CGRect(x: -20, y: 65, width: 95, height: 25))
//            annotationName.numberOfLines = 3
//            annotationName.textAlignment = .center
//            annotationName.font = UIFont(name: "Rockwell", size: 12)
//
//            if let name = annotation?.name {
//                annotationName.text = name
//                annotationName.isHidden = false
//            } else {
//                annotationName.isHidden = true
//            }
//
//            annotationName.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.631372549, blue: 0.7921568627, alpha: 1)
//            annotationName.textColor = .white
//
//            annotationName.layer.cornerRadius = 15
//            annotationName.clipsToBounds = true
//            pinView.addSubview(annotationName)
//
//            //處理白色 Pin 針 錯誤。
//            //pinView.isHidden = true //會全部不見
//
//            mapView.view(for: annotation!)?.isHidden = true //沒作用
//
//            //yourMapView.view(for: yourAnnotation)?.isHidden = true
//
//            //annotationView.canShowCallout = NO;
//
//            //使用 image view 直接放照片應該可以解決白點問題 但是目前拿到照片的方法是從網路上 String 存回來 KF 顯示的 所以上面才用 add subView
//            // pinView.image = nil 失敗
//            //pinView.image = #imageLiteral(resourceName: "btn_like_normal") 用了一張照片 會被擋在後面 白點還是不會消失
//
//
//            pinView.canShowCallout = false //沒作用
//            //annotationView!.canShowCallout = false
//
//           // 下面這行註解掉的話，距離太近時就不會自動合併，在 icon 旁邊出現 2,3 之類的
//           // pinView.clusteringIdentifier = pinIdent
//
//
//            return pinView
//        }
//    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //新增下面這行 20181001
        //           self.showAlert(title: "新增\(navigationUserName!) 為好友？", message: "認識一下吧！")
        
        if self.userAnnotation != nil {
            
            navigationUserName = userAnnotation?.name!
            self.showAlert(title: "傳訊息給\(navigationUserName!) 嗎～？", message: "認識一下吧！")
            
        } else {
            navigationUserName = "使用者"
        }
        
        
        
        if let userLocation = view.annotation as? UserAnnotation {
            self.userAnnotation = userLocation
        }
        
    }
    
    
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
//        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//        test.title = "Emojis"
//        test.subtitle = nil
//        return test
//    }
//
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
//        annotationView.clusteringIdentifier = "identifier"
//        return annotationView
//    }

    
    
    func saveSelfLocation(latitude: Double, longitude: Double) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        refference.child("location").child(userId).child("location").setValue([
            "lat": latitude,
            "lon": longitude,
            "userName": userName,
            "userImage": userImage])
    }
    
    @IBAction func test(_ sender: Any) {
        if self.userAnnotation != nil {
            navigationUserName = userAnnotation?.name!
            self.showAlert(title: "即將導航到\(navigationUserName!)", message: "系好安全帶")
        } else {
            navigationUserName = "使用者"
        }
        
    }
    
    func giveDirections(coordinate: CLLocationCoordinate2D, userName: String) {
        let requestCllocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(requestCllocation) { (placemarks, _) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = userName
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確認", style: .default) { (action) in
            self.giveDirections(coordinate: (self.userAnnotation?.coordinate)!, userName: self.navigationUserName!)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func changeMessage(_ sender: UIButton) {
        
        let editAlert = UIAlertController(title: "Message:", message: nil, preferredStyle: .alert)
        
        editAlert.addTextField()
        
        let submitAction = UIAlertAction(title: "Send", style: .default, handler: { (_) in
            
            if let alertTextField = editAlert.textFields?.first?.text {
                
                print("alertTextField: \(alertTextField)")
                
                guard let userId = Auth.auth().currentUser?.uid else { return }
                
                let userStatus = ["text": alertTextField]
                
                let childUpdates = ["/location/\(userId)/message": userStatus]
                
                self.refference.updateChildValues(childUpdates)
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        editAlert.addAction(submitAction)
        editAlert.addAction(cancel)
        
        self.present(editAlert, animated: true)
    }
    
    func setIconCorner() {
        
        location.clipsToBounds = true
        location.layer.cornerRadius = 25
        filterButton.clipsToBounds = true
        filterButton.layer.cornerRadius = 25

    }
    
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
    
}

//extension MapViewController: ClusterDelegate {
//
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> ClusterAnnotation {
//        let annotation = ClusterAnnotation(memberAnnotations: memberAnnotations)
//        annotation.title = "Emojis"
//        return annotation
//    }
//
//}

//extension MapViewController: MKMapViewDelegate {
//
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
//        let test = MKClusterAnnotation(memberAnnotations: memberAnnotations)
//        test.title = "Emojis"
//        test.subtitle = nil
//        return test
//    }
//}
