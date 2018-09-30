//
//  ChatViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/26.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
   
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()

        // Do any additional setup after loading the view.
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
        chatTableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "Chat")
        
     }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        case String(describing: ChatDetailViewController.self):
            
            guard let detailController =  segue.destination as? ChatDetailViewController,
                let indexPath = sender as? IndexPath else {
                    
                    return
            }
            
           // 對方 controller 的資料
           // detailController.article = datas[indexPath.row]
            
        default:
            
            return super.prepare(for: segue, sender: sender)
        }
    }
    
    func setImage() {
        
        userImage.layer.cornerRadius = 25
        userImage.clipsToBounds = true
        
    }
    
//    func setButtonTemplateImage() {
//        var templateImage = #imageLiteral(resourceName: "btn_play").withRenderingMode(.alwaysTemplate)
//        playButton.setImage(templateImage, for: .normal)
//
//        templateImage = #imageLiteral(resourceName: "btn_stop").withRenderingMode(.alwaysTemplate)
//        playButton.setImage(templateImage, for: .selected)
//
//    }

    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "Chat", for: indexPath)
            as? ChatTableViewCell {
            
//            cell.messageBody.text = message.content
//            if let photoString = message.senderPhoto {
//                cell.userImage.sd_setImage(with: URL(string: photoString), completed: nil)
//            } else {
//                cell.userImage.image = #imageLiteral(resourceName: "profile_sticker_placeholder02")
//            }
            
            cell.userMessage.text = "要吃飯了沒？？？"
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}

extension ChatViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return 150.0
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(
            withIdentifier: String(describing: ChatDetailViewController.self),
            sender: indexPath
        )
    }
    
}
