//
//  EditUserDataTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/10.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

protocol CellDelegate: AnyObject {
    
    //func cellButtonTapping(_ cell: UITableViewCell)
    func reszing(heightGap: CGFloat)
    func editSave(textInput: String,tableViewCell: UITableViewCell)
    //func updateLocalData(data: Any)
}


class EditUserDataTableViewCell: UITableViewCell {

    //@IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var baseView: ProfileContentView!
    //UIView!
    
    weak var delegate: CellDelegate?
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.contentTextView.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resizeTextView(heightGap: CGFloat) {
        
        delegate?.reszing(heightGap: heightGap)
        
    }

    
}

extension EditUserDataTableViewCell: UITextViewDelegate{
    
    func adjustTextViewHeight() {
        
        let fixedWidth = baseView.contentTextView.frame.size.width
        
        let newSize = baseView.contentTextView.sizeThatFits(
            CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        )
        
        if baseView.contentTextView.contentSize.height > baseView.contentTextView.frame.size.height {
            
            let heightGap = newSize.height - baseView.contentTextView.frame.size.height
            
            self.frame.size.height += heightGap
            
            baseView.contentTextView.frame.size.height = newSize.height
            baseView.frame.size.height += heightGap
            
            delegate?.reszing(heightGap: heightGap)
            
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.adjustTextViewHeight()
        
    }
    //
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.editSave(textInput: textView.text, tableViewCell: self)
    }
    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        <#code#>
//    }
    
}
