//
//  UserDataTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/13.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class UserDataTableViewCell: UITableViewCell {

    //@IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBirthday: UILabel!
    @IBOutlet weak var userGender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        userImage.layer.cornerRadius = 50
//        userImage.clipsToBounds = true
//        userImage.layer.borderWidth = 4
//        userImage.layer.borderColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
        
        //userImage.layer.opacity = 0.5
        
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
