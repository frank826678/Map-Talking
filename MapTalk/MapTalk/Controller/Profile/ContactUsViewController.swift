//
//  ContactUsViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ContactUsViewController: UIViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var backgroundView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //下面這行沒用
        //navigationController?.title = "聯絡我們"
//        self.navigationController?.navigationBar.topItem?.title = "Your Title"
        
        //self.view.backgroundColor = .clear
        //self.view.backgroundColor = #colorLiteral(red: 0.4588235294, green: 0.7137254902, blue: 1, alpha: 1)
        
        //self.view.backgroundColor = UIColor.white
        
        setupLayerGradient(width: fullScreenSize.width, height: fullScreenSize.height)
        
        self.tabBarController?.tabBar.isTranslucent = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.title = "     聯絡我們"
        
    }
    
    func setupLayerGradient(width: CGFloat, height: CGFloat) {
        
        let layerGradient = CAGradientLayer()
        
        //layerGradient.colors = [#colorLiteral(red: 0.1764705882, green: 0.7647058824, blue: 0.9960784314, alpha: 1) , #colorLiteral(red: 0.07058823529, green: 0.4431372549, blue: 1, alpha: 1) ]
        
        //        layerGradient.colors = [
        //            UIColor(red: 70/255.0, green: 95/255.0, blue: 222/255.0, alpha: 0.9).cgColor,
        //            UIColor(red: 235/255.0, green: 121/255.0, blue: 243/255.0, alpha: 0.9).cgColor
        //        ]
        
        //OK 重藍到清藍 alpha 1 - 0.5
        layerGradient.colors = [
            UIColor(red:0.07, green:0.44, blue:1.00, alpha:1).cgColor,
            UIColor(red:0.18, green:0.76, blue:1.00, alpha:1).cgColor
        ]
        
        //        layerGradient.colors = [UIColor(hex: 0x1271ff).CGColor,UIColor(hex: 0x2dc3fe).CGColor]
        //#2dc3fe 淡藍
        //#1271ff 重藍 UIColor(red:0.07, green:0.44, blue:1.00, alpha:1.0)
        
        
        //layerGradient.startPoint = CGPoint(x: 0, y: 0.5)
        //layerGradient.endPoint = CGPoint(x: 1, y: 0.5)
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        layerGradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.backgroundView.layer.addSublayer(layerGradient)
        
        //self.layer.addSublayer(layerGradient)
    }

}
