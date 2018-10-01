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
                                    "date-micro-filled-100",
                                    "date-wine-glass-50",
                                    "date-dining-room-50","date-documentary-50","date-romance-50",
                                    "date-cafe-50","date-car-50"]
    
    var timeNameArray: [String] = ["現在","隨時","下班後","週末"]
    var timeImageArray: [String] = ["date-present-50",
                                    "date-future-50",
                                    "date-business-50",
                                    "date-calendar-50"]


    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.view.backgroundColor = .clear
        self.view.backgroundColor = #colorLiteral(red: 0.3098039216, green: 0.8588235294, blue: 0.9921568627, alpha: 1)

        
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
            
            cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
            cell?.iconName.text = iconNameArray[indexPath.row]
            
            //cell.iconImage.backgroundColor =  #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) // FB message borderColor
            
            cell?.iconImage.image = UIImage(named: iconImageArray[indexPath.row])

            
            //return cell
        } else {
            
            cell?.backgroundColor = #colorLiteral(red: 0.08870747934, green: 0.8215307774, blue: 1, alpha: 0.8)
            cell?.iconName.text = timeNameArray[indexPath.row]
            
            cell?.iconImage.image = UIImage(named: timeImageArray[indexPath.row])
            
            //return cell
            //cell.backgroundColor = self.randomColor()
        }

        // 設定背景色
//        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.orange : UIColor.brown
        
        return cell!

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
