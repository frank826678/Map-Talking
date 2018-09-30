//
//  FilterCollectionViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/30.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconName: UILabel!
    
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setColor()
    }
    
    func setColor() {
        
        iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        //目前四張照片 icon 是用 storyboard 的 renderAs 改成 template
    }

}
