//
//  ChatOwnerTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/27.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ChatOwnerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageBody: UILabel!
    
    @IBOutlet weak var messageBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBg.layer.cornerRadius = 15.0
        
        messageBg.layer.maskedCorners = [
            CACornerMask.layerMinXMinYCorner,
            CACornerMask.layerMaxXMinYCorner,
            CACornerMask.layerMinXMaxYCorner
        ]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}
