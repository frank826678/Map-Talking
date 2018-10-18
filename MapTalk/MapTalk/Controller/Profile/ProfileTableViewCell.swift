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
    
    @IBOutlet weak var iconBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setColor() {
        
        //iconImage.tintColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)
    
        iconImage.tintColor = UIColor.white
        iconImage.contentMode = .scaleAspectFit
        iconName.textColor = UIColor.white
        
        iconBackgroundView.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
        
        iconBackgroundView.layer.cornerRadius = 25
        iconBackgroundView.clipsToBounds = true
        

        
        //目前12張照片 icon 是用 程式碼控制 template
        //目前12張照片 icon 是用 storyboard 的 renderAs 改成 template
    }
    
//    func setColor() {
//
//        iconImage.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        
//        //目前四張照片 icon 是用 storyboard 的 renderAs 改成 template
//    }
    
    func setIconTemplateImage() {
        var templateImage = #imageLiteral(resourceName: "new3-pencil-50").withRenderingMode(.alwaysTemplate)
        
//        filterButton.setImage(templateImage, for: .normal)
//        iconImage.
//        templateImage = #imageLiteral(resourceName: "new3-two-hearts-filled-40").withRenderingMode(.alwaysTemplate)
//        filterButton.setImage(templateImage, for: .selected)
        
        setButtonColor(with: #colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1)) //顏色已經挑選完成 是根據定位的按鈕的藍色
        
    }
    
    func setButtonColor(with color: UIColor) {
        //filterButton.imageView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //按鈕的圖案的背景 顏色已經挑選完成 是根據定位的按鈕的白色
        
        //filterButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // 按鈕的背景
        
        iconImage.tintColor = color
      //  iconImage.imageView?.tintColor = color
        //        playButton.imageView?.tintColor = color
        //
        //        rewindButton.imageView?.tintColor = color
        //
        //        forwardButton.imageView?.tintColor = color
        //
        //        muteButton.imageView?.tintColor = color
        //
        //        fullScreenButton.imageView?.tintColor = color
    }
    
}
