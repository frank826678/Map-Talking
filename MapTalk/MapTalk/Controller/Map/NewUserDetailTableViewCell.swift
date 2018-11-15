//
//  NewUserDetailTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/17.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class NewUserDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var iconBackground: UIView!
    @IBOutlet weak var contentBackground: UIView!
    @IBOutlet weak var contentTitleLabel: UILabel!
    
    @IBOutlet weak var contentInfoLabel: UILabel!
    override func awakeFromNib() {
        
        super.awakeFromNib()
        setColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        }
    
    func setColor() {

        contentBackground.layer.shadowRadius = 5
        contentBackground.clipsToBounds = false
        contentBackground.layer.shadowColor = UIColor.gray.cgColor
        contentBackground.layer.shadowOpacity = 0.6
        contentBackground.layer.shadowOffset = CGSize.zero
    }
}
