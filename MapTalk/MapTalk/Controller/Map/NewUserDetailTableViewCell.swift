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
        // Initialization code
        setColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setColor() {
//        //contentBackground.clipsToBounds = false
//        contentBackground.layer.masksToBounds = false
//
//        contentBackground.backgroundColor = UIColor.white
//        //contentBackground.layer.applySketchShadow(color: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1), alpha: 1, x: 0, y: 0, blur: 20, spread: 20,corner: 60)
//
//        contentBackground.layer.applySketchRectShadow(color: #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1), alpha: 0.8, x: 0, y: 0, blur: 5, spread: 5)
        
        //contentBackground.layer.cornerRadius = 55
        contentBackground.layer.shadowRadius = 5
        contentBackground.clipsToBounds = false
        contentBackground.layer.shadowColor = UIColor.gray.cgColor
        contentBackground.layer.shadowOpacity = 0.6
        contentBackground.layer.shadowOffset = CGSize.zero
        
    }
    
}
