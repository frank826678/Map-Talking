//
//  EditContentTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class EditContentTableViewCell: UITableViewCell {

    @IBOutlet weak var userInfoLabel: UILabel!
    
    @IBOutlet weak var userInfoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
