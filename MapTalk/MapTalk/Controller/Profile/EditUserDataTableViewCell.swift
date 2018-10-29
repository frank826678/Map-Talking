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
    func editSave(textInput: String, tableViewCell: UITableViewCell)
    //20181014
    
    //func updated(height: CGFloat)
    
    //END
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
        
        //試著解決字超出問題 //
        baseView.contentTextView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resizeTextView(heightGap: CGFloat) {
        
        delegate?.reszing(heightGap: heightGap)
        
    }
    
}

extension EditUserDataTableViewCell: UITextViewDelegate {
    
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
            //20181014
            self.baseView.layoutIfNeeded()
            baseView.setNeedsLayout()
            //20181014
            delegate?.reszing(heightGap: heightGap)
            
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.adjustTextViewHeight()
        //20181014 editSave 寫在這裡會每一個字都只能輸入一次鍵盤就會被收下去
//        delegate?.editSave(textInput: textView.text, tableViewCell: self)
        
        //let height = textView.newHeight(withBaseHeight: 200)
        //delegate?.updated(height: height)
        
        //END
    }
    
    //編輯中無法存檔 一定要點一下空白處 是否要改 func
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.editSave(textInput: textView.text, tableViewCell: self)
    }
    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        <#code#>
//    }
    
}
