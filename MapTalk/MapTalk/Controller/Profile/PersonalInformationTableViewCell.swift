//
//  PersonalInformationTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/23.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

protocol PersonalInformationCellDelegate: AnyObject {
    
    func editSave(textInput: String,tableViewCell: UITableViewCell)
    
}

class PersonalInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    weak var delegate: PersonalInformationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension PersonalInformationTableViewCell: UITextViewDelegate {
    
    //鍵盤每打一個字 就會縮回去 註解掉沒問題
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        delegate?.editSave(textInput: textView.text, tableViewCell: self) //delegate 的 func 帶著傳入值
        
    }
    
}
