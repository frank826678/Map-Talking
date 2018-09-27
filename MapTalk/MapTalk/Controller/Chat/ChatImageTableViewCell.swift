//
//  ChatImageTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ChatImageTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var messageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageImageView.layer.cornerRadius = 15.0
        
        messageImageView.layer.maskedCorners = [
            CACornerMask.layerMinXMinYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMaxXMaxYCorner
        ]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
