//
//  EditViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/10/1.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    @IBOutlet weak var editTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        editTableView.delegate = self
        editTableView.dataSource = self
        
        editTableView.register(UINib(nibName: "EditNameTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditName")
        editTableView.register(UINib(nibName: "EditInfoTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditInfo")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.topItem?.title = "     編輯資料"
        
        
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension EditViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if let cell = tableView.dequeueReusableCell(
            withIdentifier: "EditName", for: indexPath)
            as? EditNameTableViewCell {
            
            //            cell.messageBody.text = message.content
            //            if let photoString = message.senderPhoto {
            //                cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
            //            } else {
            //                cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
            //            }
            
            //            cell.userMessage.text = "要吃飯了沒？？？"
            
            return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditInfo", for: indexPath)
                as? EditInfoTableViewCell {
                return cell
            }

            
            //return UITableViewCell()
            
        default:
            
            return  UITableViewCell()   //要有() 也因為上面有 -> UITableViewCell 所以一定要有一個回傳值
        }
        
        return  UITableViewCell()
    }
}

extension EditViewController: UITableViewDelegate{}
