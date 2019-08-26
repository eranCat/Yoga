//
//  InternetPickerViewController.swift
//  YogaLessons
//
//  Created by Eran karaso on 23/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SDWebImage

class InternetImagePickerVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return .init()
    }
    
}

extension InternetImagePickerVC:UISearchControllerDelegate{
    
}

struct DownloadableImage:Codable {
    let link:String
}
