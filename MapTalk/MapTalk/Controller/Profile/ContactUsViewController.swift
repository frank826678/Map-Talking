//
//  ContactUsViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController {
    
    let fullScreenSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var updateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var contactButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupLayerGradient(width: fullScreenSize.width, height: fullScreenSize.height)
        
        self.tabBarController?.tabBar.isTranslucent = false
        
        setCorner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.title = "聯絡我們"
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isTranslucent = true
    }
    
    @IBAction func contactButtonClicked(_ sender: UIButton) {
        sendEmail()
    }
    
    func setupLayerGradient(width: CGFloat, height: CGFloat) {
        
        let layerGradient = CAGradientLayer()
        
        layerGradient.colors = [
            UIColor(red: 188/255.0, green: 229/255.0, blue: 255/255.0, alpha: 1).cgColor,
            UIColor(red: 219/255.0, green: 234/255.0, blue: 255/255.0, alpha: 1).cgColor
        ]
        
        layerGradient.startPoint = CGPoint(x: 0.5, y: 0)
        layerGradient.endPoint = CGPoint(x: 0.5, y: 1)
        
        layerGradient.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        self.backgroundView.layer.addSublayer(layerGradient)
    }
    
    func setCorner() {
        
            versionLabel.layer.cornerRadius = 20
            versionLabel.clipsToBounds = true
            versionLabel.layer.backgroundColor = UIColor.white.cgColor
            
            updateLabel.layer.cornerRadius = 20
            updateLabel.clipsToBounds = true
            updateLabel.layer.backgroundColor = UIColor.white.cgColor

            nameLabel.layer.cornerRadius = 20
            nameLabel.clipsToBounds = true
            nameLabel.layer.backgroundColor = UIColor.white.cgColor

            contactButton.layer.cornerRadius = 20
            contactButton.clipsToBounds = true
            contactButton.backgroundColor = UIColor.white

    }

}

extension ContactUsViewController: MFMailComposeViewControllerDelegate {
    
    func configureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["frank826678@gmail.com"])
        mailComposerVC.setSubject("App 問題回報")
        
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title: "無法寄送信件", message: "請再試一次", preferredStyle: UIAlertController.Style.alert)
        let dismiss = UIAlertAction(title: "確認", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func sendEmail() {
        let mailComposeViewController = configureMailController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            showMailError()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
