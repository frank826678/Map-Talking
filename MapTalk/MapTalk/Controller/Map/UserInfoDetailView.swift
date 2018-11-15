//
//  UserInfoDetailView.swift
//  MapTalk
//
//  Created by Frank on 2018/10/12.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class UserInfoDetailView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var userInfoDetailTableView: UITableView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userImageShadowView: UIView!
    
    @IBOutlet weak var backgroundTapView: UIView!
 
    @IBAction func chatButtonClick(_ sender: UIButton) {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.clear
        
        Bundle.main.loadNibNamed("UserInfoDetailView", owner: self, options: nil)
        addSubview(contentView)
        
        contentView.fixInView(self)
        setImage()
    }
    
    func setImage() {
        
        userImage.layer.cornerRadius = 50
        userImage.clipsToBounds = true
        userImageShadowView.layer.cornerRadius = 55
        userImageShadowView.layer.shadowRadius = 15
        userImageShadowView.clipsToBounds = false
        userImageShadowView.layer.shadowColor = UIColor.gray.cgColor
        userImageShadowView.layer.shadowOpacity = 0.6
        userImageShadowView.layer.shadowOffset = CGSize.zero
    }
    
}

extension UIView {
    func fixInView(_ container: UIView!) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
