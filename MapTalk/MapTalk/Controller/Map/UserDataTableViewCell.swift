//
//  UserDataTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/13.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class UserDataTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userBirthday: UILabel!
    @IBOutlet weak var userGender: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
