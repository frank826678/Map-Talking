//
//  UserDetailTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/12.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class UserDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var userDetailTitle: UILabel!
    @IBOutlet weak var userDetailContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
