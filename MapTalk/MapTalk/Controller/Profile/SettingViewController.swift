//
//  SettingViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.backgroundView.backgroundColor = .clear
        self.backgroundView.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
        
        logOutButton.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
        logOutButton.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        logOutButton.layer.borderWidth = 2

        
        deleteAccountButton.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.topItem?.title = "     設定"
        
    }
}
