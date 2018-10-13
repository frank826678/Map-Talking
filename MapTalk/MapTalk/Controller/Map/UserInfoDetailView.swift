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
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userInfoDetailTableView: UITableView!
    @IBOutlet weak var chatButton: UIButton!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBAction func chatButtonClick(_ sender: UIButton) {
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
        userImage.layer.cornerRadius = 60
        userImage.clipsToBounds = true
        userImage.layer.borderColor = #colorLiteral(red: 0.2596536937, green: 0.4559627229, blue: 0.9940910533, alpha: 1)
        //userImage.layer.borderWidth = 4
        
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UserInfoDetailView", owner: self, options: nil)
        addSubview(contentView)
        
        //contentView.frame = self.bounds
        //contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        contentView.fixInView(self)
    }
    
    //設定陰影
    func shadowSetup(
        cgSize: CGSize = CGSize(width: 1, height: 1),
        shadowRadius: CGFloat = 4,
        shadowOpacity: Float = 0.2
        ) {
        
        self.layer.shadowOffset = cgSize
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = shadowOpacity
        
    }
    
    private func setCellShadow() {
        
        // 要 masksToBounds，不然圓角不會出來
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowRadius = 4.0
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        
    }

    
}

extension UIView {
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
