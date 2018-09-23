//
//  UserLocation.swift
//  MapTalk
//
//  Created by Frank on 2018/9/23.
//  Copyright © 2018 Frank. All rights reserved.
//

// import Foundation

import UIKit
import MapKit
import Firebase
import FirebaseDatabase

//enum UserType {
//    case man
//    case femail
//}

class UserLocation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var userName: String?
    let discipline: String
    
    init(_ latitude:CLLocationDegrees, _ longitude:CLLocationDegrees, userName: String, discipline: String) {
        self.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        self.userName = userName
        self.discipline = discipline
        super.init()
    }
    
    var subtitle: String? {
        return userName
    }
    
}

struct Locations {
    
    var latitude: Double {
        didSet {
            updateCoordinate()
        }
    }
    
    var longitude: Double {
        didSet {
            updateCoordinate()
        }
    }
    
    var name: String
    
    var userImage: String
    
    let id: String
    
    var message: String? {
        didSet {
            updateMessage()
        }
    }
    
    private let annotation = UserAnnotation()
    
    var userAnnotation: UserAnnotation {
        
        self.annotation.id = self.id
        self.annotation.name = self.name
        self.annotation.userImage = self.userImage
        self.annotation.message = self.message
        self.annotation.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        return annotation
    }
    
    private func updateCoordinate() {
        
        let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        
        annotation.coordinate = coordinate
    }
    
    private func updateMessage() {
        
        annotation.message = self.message
    }
}

class UserAnnotation: MKPointAnnotation {
    
    var name: String?
    var userImage: String?
    var id: String?
    var message: String?
}
