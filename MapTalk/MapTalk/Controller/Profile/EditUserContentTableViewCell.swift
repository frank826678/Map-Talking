//
//  EditUserContentTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/15.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

protocol CellDelegate2: AnyObject {
    
    func editSave(textInput: String,tableViewCell: UITableViewCell)
    
}

class EditUserContentTableViewCell: UITableViewCell {
    
    weak var delegate: CellDelegate2?
    @IBOutlet weak var editContentTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        editContentTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EditUserContentTableViewCell: UITextViewDelegate {
    
    //鍵盤每打一個字 就會縮回去 註解掉沒問題
    func textViewDidChangeSelection(_ textView: UITextView) {

        delegate?.editSave(textInput: textView.text, tableViewCell: self) //delegate 的 func 帶著傳入值

    }

}
