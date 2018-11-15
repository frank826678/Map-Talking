//
//  ChatTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/26.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userMessage: UILabel!
    
    @IBOutlet weak var messageTime: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        userImage.layer.cornerRadius = 25
        userImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
}
