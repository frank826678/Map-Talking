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
        
        editTableView.register(UINib(nibName: "EditUserDataTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditUserData")
        editTableView.register(UINib(nibName: "EditContentTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "EditContent")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.navigationController?.navigationBar.topItem?.title = "     編輯資料"
        
        
    }
    
}

extension EditViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //        if section == 0 || section ==  1 || section ==  3 {
        
        if section == 1 {
            return 6
        } else {
            return 1
        }
        
    }
    
    // 設置每個 section 的 title 為一個 UIView
    // 如果實作了這個方法 會蓋過單純設置文字的 section title
    private func tableView(tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // 設置 section header 的高度
    private func tableView(tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // 每個 section 的標題
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        var title = "暱稱"
        
        if section == 0 {
            
            title = "暱稱"
            
        } else if section == 1 {
            
            title = "基本資料"
            
        } else if section == 2 {
            
            title = "專長 興趣"
            
        } else if section == 3 {
            
            title = "喜歡的國家"
            
        }  else if section == 4 {
            
            title = "自己最近的困擾"
            
        } else if section == 5 {
            
            title = "想嘗試的事情"
            
        }  else  {
            
            title = "自我介紹"
            
        }
        
        
        return title
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if let cell = tableView.dequeueReusableCell(
            withIdentifier: "EditUserData", for: indexPath)
            as? EditUserDataTableViewCell {
            
                //cell.contentTextView.text = "FRANK"
                cell.baseView.contentTextView.text = "FRANK"
                
                
            return cell
            }
            
        case 1:
            
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditContent", for: indexPath)
                as? EditContentTableViewCell {
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserDataTableViewCell {
                
                //cell.contentTextView.text = "吃飯，睡覺"
                cell.baseView.contentTextView.text = "吃飯，睡覺"
                
                return cell
            }
            
        case 3:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserDataTableViewCell {
                
                //cell.contentTextView.text = "台灣"
                cell.baseView.contentTextView.text = "台灣"
                
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserDataTableViewCell {
                
                //cell.contentTextView.text = "變胖了"
                cell.baseView.contentTextView.text = "變胖了"
                
                return cell
            }
            
        case 5:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserDataTableViewCell {
                
                //cell.contentTextView.text = "跳海"
                cell.baseView.contentTextView.text = "跳海"
                
                return cell
            }
            
        case 6:
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditUserData", for: indexPath)
                as? EditUserDataTableViewCell {
                
                //cell.contentTextView.text = "大家好 我是法克"
                cell.baseView.contentTextView.text = "大家好 我是法克"
                cell.delegate = self
                cell.baseView.delegate = self
                return cell
            }

            
            //return UITableViewCell()
            
        default:
            
            return  UITableViewCell()   //要有() 也因為上面有 -> UITableViewCell 所以一定要有一個回傳值
        }
        
        return  UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return 100
    }
}

extension EditViewController: UITableViewDelegate{}

extension EditViewController: CellDelegate {
    
//    func updateLocalData(data: Any) {
//
//        guard let text = data as? String else {
//
//            return
//        }
//
//        guard let currentUser =  Auth.auth().currentUser else {
//
//            return
//
//        }
//
//        #warning ("改view")
//
//        guard let sectionIndex = allData.firstIndex(where: {$0.dataType == .previousComments(comments.count)}) else {
//
//            return
//        }
//
//        comments.append(
//            CommentModel(
//                postDate: Date(),
//                user: UserModel.groupMember(
//                    image: "currentUser.photoURL",
//                    name: currentUser.displayName!
//                ),
//                comment: text
//            )
//        )
//
//        allData[sectionIndex] = DataType(
//            dataType: .previousComments(comments.count),
//            data: comments)
//
//        self.tableView.reloadData()
//    }
    
    func reszing(heightGap: CGFloat) {
        
        editTableView.contentInset.bottom += heightGap
        editTableView.contentOffset.y += heightGap
        
    }
    
//    func cellButtonTapping(_ cell: UITableViewCell) {
//
//        guard let currentUser =  Auth.auth().currentUser else {
//
//            return
//
//        }
//
//        #warning ("update 這邊 order 的 data")
//
//        guard let sectionIndex = allData.firstIndex(where: {$0.dataType == .productItems(products.count)}) else {
//
//            return
//        }
//
//        for (index) in products.indices {
//
//            guard let cell = tableView.cellForRow(
//                at: IndexPath(row: index, section: sectionIndex)
//                ) as? ProductItemTableViewCell else {
//
//                    return
//            }
//
//            products[index].numberOfItem -= order[index].numberOfItem
//            order[index].numberOfItem = 0
//
//            cell.updateView(product: products[index])
//
//        }
//
//        #warning ("更新 firebase 的資料後重新 fetch")
//        joinMember.append(
//            UserModel(
//                userImage: currentUser.photoURL!.absoluteString,
//                userName: currentUser.displayName!,
//                numberOfEvaluation: 2,
//                buyNumber: 3,
//                averageEvaluation: 5.0
//            )
//        )
//
//        let banner = NotificationBanner(title: "加團成功", subtitle: "詳細資訊請到歷史紀錄區查詢", style: .success)
//        banner.show()
//
//        #warning ("加團失敗的警告")
//
//        guard let index = allData.firstIndex(where: {$0.dataType == .joinGroup}),
//            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? JoinGroupTableViewCell else {
//
//                return
//        }
//
//        cell.collectionView.reloadData()
//
//        tableView.reloadData()
//    }
    
}
