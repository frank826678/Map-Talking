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
    @IBOutlet weak var iconBackgroundView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setColor()
        
    }
    
    private func setColor() {
        
        iconImage.tintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        iconImage.contentMode = .scaleAspectFit
        iconName.textColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        //iconBackgroundView.layer.cornerRadius = iconBackgroundView.frame.width/2
       
        iconBackgroundView.layer.cornerRadius = 40
        iconBackgroundView.clipsToBounds = true
        //目前12張照片 icon 是用 程式碼控制 template
        //目前12張照片 icon 是用 storyboard 的 renderAs 改成 template
    }
    
    private func setTemplate() {
        //  var templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
        
        //要改的是照片 不是 外觀的 image
        //iconImage.image?.withRenderingMode(.alwaysTemplate)
        iconImage.tintColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        iconImage.contentMode = .scaleAspectFit
        
    }
}
