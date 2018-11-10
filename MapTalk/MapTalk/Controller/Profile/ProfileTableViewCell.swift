//
//  ProfileTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/9/30.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImage: UIImageView!
    
    @IBOutlet weak var iconName: UILabel!
    
    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var iconBackgroundView: UIView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        setColor()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    private func setColor() {
        
        iconImage.tintColor = UIColor.white
        
        iconImage.contentMode = .scaleAspectFit
        
        iconName.textColor = UIColor.white
        
        iconBackgroundView.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
        
        iconBackgroundView.layer.cornerRadius = 25
        
        iconBackgroundView.clipsToBounds = true
        
        //目前12張照片 icon 是用 程式碼控制 template
        //目前12張照片 icon 是用 storyboard 的 renderAs 改成 template
    }
    
    func setIconTemplateImage() {
        var templateImage = #imageLiteral(resourceName: "new3-pencil-50").withRenderingMode(.alwaysTemplate)
        
        setButtonColor(with: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)) //顏色已經挑選完成 是根據定位的按鈕的藍色
        
    }
    
    func setButtonColor(with color: UIColor) {
        
        iconImage.tintColor = color
    }
}
