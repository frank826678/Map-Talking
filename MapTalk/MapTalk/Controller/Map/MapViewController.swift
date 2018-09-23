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


class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var ref: DatabaseReference!
    var userName: String!
    var locations: [Locations] = []
    var trackLocation: [String: Any] = [ : ]
    
    var userAnnotation: UserAnnotation?
    
    var selfLocation: Locations?
    
    var navigationUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        //        map.showsUserLocation = true
        
        ref = Database.database().reference()
        
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
    }
    
    func dataBaseLocation() {
        ref.child("location").observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let location = value["location"] as? NSDictionary else { return }
            guard let lat = location["lat"] as? Double else { return }
            guard let lon = location["lon"] as? Double else { return }
            guard let userName = location["userName"] as? String else { return }
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            
            let userlocations = Locations(lat: lat, lon: lon, name: userName, userImage: userImage, id: snapshot.key, message: messageInput)
            
            self.map.addAnnotation(userlocations.userAnnotation)
            
            self.locations.append(userlocations)
            
            guard let userId = Auth.auth().currentUser?.uid else { return }
            if userlocations.id == userId {
                
                self.selfLocation = userlocations
                
                self.map.setRegion(
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
        ref.child("location").observe(.childChanged) { (snapshot) in
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let location = value["location"] as? NSDictionary else { return }
            guard let lat = location["lat"] as? Double else { return }
            guard let lon = location["lon"] as? Double else { return }
            
            guard let userName = location["userName"] as? String else { return }
            
            guard let userImage = location["userImage"] as? String else { return }
            
            var messageInput = "媽 我上地圖了 Ya"
            if let message = value["message"] as? NSDictionary {
                
                guard let text = message["text"] as? String else { return }
                
                messageInput = text
            }
            
            let userLocations = Locations(lat: lat, lon: lon, name: userName, userImage: userImage, id: snapshot.key, message: messageInput)
            
            for (index, user) in self.locations.enumerated() where user.id == userLocations.id {
                
                self.locations[index].lat = userLocations.lat
                
                self.locations[index].lon = userLocations.lon
                
                self.locations[index].message = userLocations.message
                
                for index in 0..<self.locations.count {
                    self.map.removeAnnotation(self.locations[index].userAnnotation)
                    self.map.addAnnotation(self.locations[index].userAnnotation)
                }
                
                return
            }
            
            self.map.addAnnotation(userLocations.userAnnotation)
            
            
            self.locations.append(userLocations)
        }
    }
    
    @IBAction func locationButtonClick(_ sender: UIButton) {
        
        if let location = selfLocation {
            self.map.setRegion(
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
            
            saveSelfLocation(lat: center.latitude, lon: center.longitude)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let userLocation = view.annotation as? UserAnnotation {
            self.userAnnotation = userLocation
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotation = annotation as? UserAnnotation
        
        if annotation is MKUserLocation {
            return nil
        } else {
            let pinIdent = "Pin"
            var pinView: MKMarkerAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(
                withIdentifier: pinIdent) as? MKMarkerAnnotationView {
                dequeuedView.annotation = annotation
                pinView = dequeuedView
                
            } else {
                pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: pinIdent)
            }
            
            pinView.markerTintColor = .clear
            pinView.glyphTintColor = .orange
            
            let imageView = UIImageView()
            
            imageView.contentMode = .scaleAspectFill
            
            imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
//            if let image = annotation?.userImage {
//                imageView.sd_setImage(with: URL(string: image), completed: nil)
//            } else {
//                imageView.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
//            }
            
            
            //設定照片圓角
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 25
            imageView.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            imageView.layer.borderWidth = 4
            
            //增加三角形圖案
            let lbl = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10)) // 50, 10
            lbl.text = "▾"
            lbl.font = UIFont.systemFont(ofSize: 24) //24
            lbl.textColor = #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)
            lbl.textAlignment = .center
            
            pinView.addSubview(imageView)
            pinView.addSubview(lbl)
            
            
            let annotationLabel = UILabel(frame: CGRect(x: -40, y: -35, width: 105, height: 30))
            annotationLabel.numberOfLines = 3
            annotationLabel.textAlignment = .center
            annotationLabel.font = UIFont(name: "Rockwell", size: 12)
            
            //annotationLabel.text = "媽 我上地圖了 Ya"
            
            if let message = annotation?.message {
                annotationLabel.text = message
            } else {
                annotationLabel.text = "媽 我上地圖了 Ya"
            }
            
            annotationLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            annotationLabel.layer.cornerRadius = 15
            annotationLabel.clipsToBounds = true
            
            pinView.addSubview(annotationLabel)
            
            let annotationName = UILabel(frame: CGRect(x: -20, y: 65, width: 95, height: 25))
            annotationName.numberOfLines = 3
            annotationName.textAlignment = .center
            annotationName.font = UIFont(name: "Rockwell", size: 12)
            
            if let name = annotation?.name {
                annotationName.text = name
                annotationName.isHidden = false
            } else {
                annotationName.isHidden = true
            }
            
            annotationName.backgroundColor = #colorLiteral(red: 0.2666666667, green: 0.631372549, blue: 0.7921568627, alpha: 1)
            annotationName.textColor = .white
            
            annotationName.layer.cornerRadius = 15
            annotationName.clipsToBounds = true
            pinView.addSubview(annotationName)
            
            pinView.clusteringIdentifier = pinIdent
            return pinView
        }
    }
    
    
    func saveSelfLocation(lat: Double, lon: Double) {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let userImage = Auth.auth().currentUser?.photoURL?.absoluteString else { return }
        ref.child("location").child(userId).child("location").setValue([
            "lat": lat,
            "lon": lon,
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
                
                self.ref.updateChildValues(childUpdates)
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        editAlert.addAction(submitAction)
        editAlert.addAction(cancel)
        
        self.present(editAlert, animated: true)
    }
    
}
