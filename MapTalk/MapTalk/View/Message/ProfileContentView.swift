//
//  ProfileContentView.swift
//  MapTalk
//
//  Created by Frank on 2018/10/10.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ProfileContentView: UIView {
    
    @IBOutlet weak var contentTextView: UITextView!
    
//    @IBOutlet weak var messgaeTxtView: UITextView!
//    @IBOutlet weak var sendMessageBot: UIButton!
    
    weak var delegate: CellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setup()
    }
    
//    private func setup() {
//
//        setupImageView()
//    }
//
//    private func setupImageView() {
//
//        messgaeTxtView.cornerSetup(cornerRadius: 4)
//        messgaeTxtView.text = "跟主揪說點什麼吧..."
//        messgaeTxtView.textColor = UIColor.lightGray
//
//    }
//
//    @IBAction func sendCommentTappng(_ sender: Any) {
//
//        guard messgaeTxtView.text != "",
//            let text = messgaeTxtView.text else {
//
//                return
//        }
//
//        delegate?.updateLocalData(data: text)
//
//        messgaeTxtView.text = ""
//
//    }
    
}
