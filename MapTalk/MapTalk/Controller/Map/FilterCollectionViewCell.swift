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
        //setTemplate()
        setColor()
        
    }
    
    private func setColor() {
        
        iconImage.tintColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        iconImage.contentMode = .scaleAspectFit
        iconName.textColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
        
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
    
//    func set(name: String) {
//
//    }
    
}
