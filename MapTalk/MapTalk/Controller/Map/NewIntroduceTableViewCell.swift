//
//  NewIntroduceTableViewCell.swift
//  MapTalk
//
//  Created by Frank on 2018/10/17.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class NewIntroduceTableViewCell: UITableViewCell {

    @IBOutlet weak var introduceBackground: UIView!
    
    @IBOutlet weak var introduceTitleBackground: UIView!
    
    @IBOutlet weak var introduceLabel: UILabel!
    
    @IBOutlet weak var wantToTryLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {

        super.setSelected(selected, animated: animated)
    }
}
