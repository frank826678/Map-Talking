//
//  FilterViewController.swift
//  MapTalk
//
//  Created by Frank on 2018/9/30.
//  Copyright © 2018 Frank. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {
    
    @IBOutlet weak var datingTypeCollectionView: UICollectionView!
    
    @IBOutlet weak var timeCollectionView: UICollectionView!
    
    var iconNameArray: [String] = ["看夜景","唱歌","喝酒","吃飯","看電影","浪漫","喝咖啡","兜風"]
    //imageArray: [UIImage] = []
    //var iconImageArray: [UIImage] = [UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!,UIImage(named: "new3-pencil-50")!]
    
    var iconImageArray: [String] = ["date-crescent-moon-50",
                                    "date-micro-filled-50",
                                    "date-wine-glass-50",
                                    "date-dining-room-50","date-documentary-50","date-romance-50",
                                    "date-cafe-50","date-car-50"]
    
    var filterEnum: [FilterIcon] = [
        
        .moon,
        .microphone,
        .wine,
        .dinner,
        .movie,
        .romance,
        .cafe,
        .cars,
        
        //        case moon = "date-crescent-moon-50"
        //    case microphone = "date-micro-filled-100"
        //    case wine = "date-wine-glass-50"
        //    case dinner = "date-dining-room-50"
        //    case movie = "date-documentary-50"
        //    case romance = "date-romance-50"
        //    case cafe = "date-cafe-50"
        //    case car = "date-car-50"
        
        
    ]
    
    var timeNameArray: [String] = ["現在","隨時","下班後","週末"]
    var timeImageArray: [String] = ["date-present-50",
                                    "date-future-50",
                                    "date-business-50",
                                    "date-calendar-50"]
    
    var selectedDateIcon1 : IndexPath = []
    var selectedTimeIcon1 : IndexPath = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        // self.view.backgroundColor = .clear
        // self.view.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)
        
        
        // swiftlint:disable identifier_name
        let nib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        // swiftlint:enable identifier_name
        
        datingTypeCollectionView.delegate = self
        datingTypeCollectionView.dataSource = self
        
        timeCollectionView.delegate = self
        timeCollectionView.dataSource = self
        
        
        
        datingTypeCollectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        timeCollectionView.register(nib, forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        
        //        datingTypeCollectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil),
        //                               forCellReuseIdentifier: "Date")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
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

extension FilterViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 12
        if(collectionView == self.datingTypeCollectionView) {
            //cell.backgroundColor = UIColor.black
            return 8
        } else {
            return 4
            //cell.backgroundColor = self.randomColor()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell
        
        if(collectionView == self.datingTypeCollectionView) {
            //cell.backgroundColor = UIColor.black
            //cell?.iconName.text =
            //cell?.iconImage
            
            //cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
            cell?.iconName.text = iconNameArray[indexPath.row]
            
            //cell.iconImage.backgroundColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) // FB message borderColor
            
            //原本寫法
            //            cell?.iconImage.image = UIImage(named: iconImageArray[indexPath.row])
            
            //傳輸照片的同時 把照片 set 成 template
            cell?.iconImage.image = UIImage.setIconTemplate(iconName: filterEnum[indexPath.row].rawValue)
            //cell?.iconImage.image = UIImage(named: filterEnum[indexPath.row.])
            
            
            //return cell
        } else {
            
            //cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
            cell?.iconName.text = timeNameArray[indexPath.row]
            
            cell?.iconImage.image = UIImage(named: timeImageArray[indexPath.row])
            
            //return cell
            //cell.backgroundColor = self.randomColor()
        }
        
        
        
        // 設定背景色
        //        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.orange : UIColor.brown
        
        return cell!
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("******請看這******")
        
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        
        //selectedCell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        if selectedDateIcon1 == indexPath {
            
            // selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            collectionView.cellForItem(at: selectedDateIcon1)?.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            print("相同")
            
        } else {
            
            //selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            collectionView.cellForItem(at: selectedDateIcon1)?.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        }
        
        if selectedTimeIcon1 == indexPath {
            
            // selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            collectionView.cellForItem(at: selectedTimeIcon1)?.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            print("相同")
            
        } else {
            
            //selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            collectionView.cellForItem(at: selectedTimeIcon1)?.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        }
        
        
        
        if(collectionView == self.datingTypeCollectionView) {
            print("你選擇了 Dating \(indexPath.section + 1) 組的")
            print("第 \(indexPath.item + 1) 張圖片")
            selectedDateIcon1 = indexPath
            #warning ("TODO: 點擊後變色 且只能點一個 點了其中一個其他的就不能點 或者再把原本的取消才能再點下一個，或是點擊後再點其他的 本來的會消失 只顯示另外ㄧ個")
            //let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
            
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            //            let selectedCell:UICollectionViewCell = myCollectionView.cellForItemAtIndexPath(indexPath)!
            //            selectedCell.contentView.backgroundColor = UIColor(red: 102/256, green: 255/256, blue: 255/256, alpha: 0.66)
            //
            
            #warning ("TODO: 儲存他按了哪一個")
            
        }
        else {
            print("你選擇了 time \(indexPath.section + 1) 組的")
            print("第 \(indexPath.item + 1) 張圖片")
            
            selectedTimeIcon1 = indexPath
            selectedCell.contentView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
            
            #warning ("TODO: 儲存他按了哪一個")
        }
        
        
    }
    
}

//extension FilterViewController: UICollectionViewDelegateFlowLayout{
//
//}

// MARK: - 設定 CollectionView Cell 與 Cell 之間的間距、距確 Super View 的距離等等
extension FilterViewController: UICollectionViewDelegateFlowLayout {
    
    /// 設定 Collection View 距離 Super View上、下、左、下間的距離
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    //        return UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
    //    }
    
    ///  設定 CollectionViewCell 的寬、高
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - indexPath: _
    /// - Returns: _
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (self.view.frame.size.width) / 4 , height: (self.view.frame.size.width) / 4)
        
        
        //        return CGSize(width: (self.view.frame.size.width - 30) / 2 , height: (self.view.frame.size.width - 30) / 2)
        
    }
    
    /// 滑動方向為「垂直」的話即「上下」的間距(預設為重直)
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    /// 滑動方向為「垂直」的話即「左右」的間距(預設為重直)
    ///
    /// - Parameters:
    ///   - collectionView: _
    ///   - collectionViewLayout: _
    ///   - section: _
    /// - Returns: _
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
