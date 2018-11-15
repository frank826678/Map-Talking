//
//  ChatImageOwnerTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ChatImageOwnerTableViewCell: UITableViewCell {

    @IBOutlet weak var messageImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageImageView.layer.cornerRadius = 15.0
        
        messageImageView.layer.maskedCorners = [
            CACornerMask.layerMinXMinYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMinXMaxYCorner
        ]
    }
    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
    
}
