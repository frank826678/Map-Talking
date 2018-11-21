//
//  PersonalInformationTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/23.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

protocol PersonalInformationCellDelegate: AnyObject {
    
    func editSave(textInput: String, tableViewCell: UITableViewCell)
}

class PersonalInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var contentTextViewTopConstraint: NSLayoutConstraint!
    weak var delegate: PersonalInformationCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        contentTextView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
    
}

extension PersonalInformationTableViewCell: UITextViewDelegate {
    
   
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        delegate?.editSave(textInput: textView.text, tableViewCell: self) 
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        guard let textViewText = textView.text else {

            return true

        }

        let count = textViewText.count + text.count - range.length

        return count <= 41

    }
    
}
